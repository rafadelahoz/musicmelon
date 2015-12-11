package;

import utils.tiled.TiledObjectGroup;
import utils.tiled.TiledObject;
import flixel.util.FlxPoint;

class MovingPlatformBuilder
{
    public static function build( Width : Int, Height : Int, ?g : TiledObjectGroup = null, o : TiledObject, X : Float, Y : Float, World : PlayState ) : MovingPlatform
    {
        var movingPlatform : MovingPlatform = null;

        // Fetch properties
        var sprite : String = MovingPlatformBuilder.parseSprite( o );
        var fps : Int = MovingPlatformBuilder.parseFPS( o );
        var speed : Int = MovingPlatformBuilder.parseSpeed( o );
        var color : Int = MovingPlatformBuilder.parseColor( o );
        var path : Path = MovingPlatformBuilder.generatePath( g, o );

        movingPlatform = new MovingPlatform(X, Y, World, path);
        movingPlatform.init( Width, Height, sprite, fps, speed, color );

        return movingPlatform;
    }

    private static function parseSprite( o : TiledObject ) : String
    {
        var sprite : String = o.custom.get( "sprite" );
        return sprite;
    }

    private static function parseFPS( o : TiledObject ) : Int
    {
        if ( o.custom.contains( "fps" ) )
        {
            return Std.parseInt( o.custom.get( "fps" ) );
        }
        else
        {
            return MovingPlatform.DefaultFPS;
        }
    }

    private static function parseSpeed( o : TiledObject ) : Int
    {
        if ( o.custom.contains( "speed" ) )
        {
            return Std.parseInt( o.custom.get( "speed" ) );
        }
        else
        {
            return MovingPlatform.DefaultSpeed;
        }
    }

    private static function parseColor( o : TiledObject ) : Int
    {
        var color : Int;

        var colorStr : String = o.custom.get( "color" );
        if ( colorStr == null ) return 0xFFFFFF;

        if ( colorStr.indexOf( "0x" ) == -1 )
            colorStr = "0x" + colorStr;

        color = Std.parseInt( colorStr );

        return color;
    }

    private static function parsePath( o : TiledObject ) : String
    {
        return o.custom.get( "path" );
    }

    private static function generatePath( g : TiledObjectGroup, o : TiledObject ) : Path
    {
        var pathId : String = MovingPlatformBuilder.parsePath( o );
        var path : Path = null;
        if ( pathId != null )
        {
            path = MovingPlatformBuilder.buildPath( pathId, g );
        }

        return path;
    }

    private static function buildPath( id : String, group : utils.tiled.TiledObjectGroup ) : Path
    {
        var o : TiledObject = null;

        // Locate path by id on group
        for ( obj in group.objects )
        {
            if ( obj.type.toLowerCase( ) == "path" && obj.name == id )
            {
                o = obj;
                break;
            }
        }

        if ( o == null )
        {
            trace( "Path " + id + " not found" );
            return new Path("not found! (" + id + ")", new Array<FlxPoint>());
        }

        // Parse its nodes
        var x : Int = o.x;
        var y : Int = o.y;

        var points : Array<FlxPoint> = o.points;

        for ( point in points )
            point.add( x, y );

        var path : Path = new Path(id, points);

        return path;
    }

}

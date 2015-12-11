package;

import flixel.util.FlxPath;

class MovingPlatform extends Entity
{
    public static var DefaultFPS : Int = 8;
    public static var DefaultSpeed : Int = 100;

    private var path : FlxPath;
    private var pathData : Path;
    private var fps : Int;
    private var speed : Int;

    public function new( X : Float, Y : Float, World : PlayState, Path : Path )
    {
        super( X, Y, World );

        pathData = Path;
        path = null;
    }

    public function init( Width : Int, Height : Int, ?Sprite : String, Fps : Int, Speed : Int, Color : Int )
    {
        if ( Sprite == null )
            makeGraphic( Width, Height, 0xFFEB3BB7 );
        else
            // Load the specified spritesheet with the given width and height
            trace(Sprite);
            loadGraphic( "assets/images/" + Sprite + ".png", true, Width, Height );

        fps = Fps;
        speed = Speed;
        color = Color;

        // what
        if ( pathData != null )
            path = new FlxPath(this, pathData.nodes, Speed, FlxPath.LOOP_FORWARD, false);
    }

    override public function update( )
    {
        super.update( );
    }
}

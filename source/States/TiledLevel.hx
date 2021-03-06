package;

import haxe.io.Path;

import flixel.FlxG;
import flixel.FlxObject;
import utils.tiled.TiledMap;
import utils.tiled.TiledObject;
import utils.tiled.TiledObjectGroup;
import utils.tiled.TiledTileSet;
import utils.tiled.TiledImage;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class TiledLevel extends TiledMap
{
    private inline static var spritesPath = "assets/images/";
    private inline static var tilesetPath = "assets/tilesets/";

    public var overlayTiles : FlxGroup;
    public var foregroundTiles : FlxGroup;
    public var backgroundTiles : FlxGroup;
    public var collidableTileLayers : Array<FlxTilemap>;

    public var meltingsPerSecond : Float;

    public function new( tiledLevel : Dynamic )
    {
        super( tiledLevel );

        overlayTiles = new FlxGroup();
        foregroundTiles = new FlxGroup();
        backgroundTiles = new FlxGroup();
        collidableTileLayers = new Array<FlxTilemap>();

        FlxG.camera.setBounds( 0, 0, fullWidth, fullHeight, true );

        /* Read config info */

        /* Read tile info */
        for ( tileLayer in layers )
        {
            var tilesetName : String = tileLayer.properties.get( "tileset" );
            if ( tilesetName == null )
                throw "'tileset' property not defined for the " + tileLayer.name + " layer. Please, add the property to the layer.";

            // Locate the tileset
            var tileset : TiledTileSet = null;
            for ( ts in tilesets )
            {
                if ( ts.name == tilesetName )
                {
                    tileset = ts;
                    break;
                }
            }

            if ( tileset == null )
                throw "Tileset " + tilesetName + " could not be found. Check the name in the layer 'tileset' property or something.";

            var processedPath = buildPath( tileset );

            var tilemap : FlxTilemap = new FlxTilemap();
            tilemap.widthInTiles = width;
            tilemap.heightInTiles = height;
            tilemap.loadMap( tileLayer.tileArray, processedPath, tileset.tileWidth, tileset.tileHeight, 0, 1, 1, 1 );

            if ( tileLayer.properties.contains( "overlay" ) )
            {
                overlayTiles.add( tilemap );
            }
            else if ( tileLayer.properties.contains( "solid" ) )
            {
                collidableTileLayers.push( tilemap );
            }
            else
            {
                backgroundTiles.add( tilemap );
            }
        }
    }

    public function loadObjects( state : PlayState ) : Void
    {
        for ( group in objectGroups )
        {
            for ( o in group.objects )
            {
                loadObject( o, group, state );
            }
        }
    }

    private function loadObject( o : TiledObject, g : TiledObjectGroup, state : PlayState ) : Void
    {
        var x : Int = o.x;
        var y : Int = o.y;

        // The Y position of objects created from tiles must be corrected by the object height
        if ( o.gid != -1 )
        {
            y -= o.height;
        }

        switch (o.type.toLowerCase( ))
        {
            case "start":
                addPlayer(x, y, state);

            case "oneway":
				// Create the oneway solid at the appropriate position, with the appropriate size
                spawnOneway(x, y, o.width, o.height, state);

            case "ladder":
                // Create the stair based on the position decided in TiledMap. The staircase is made a bit higher to
                // detect collisions from the top.
                var ladder : FlxObject = new FlxObject(x + (o.width/2-1), y-1, 2, o.height+1);
                // ladder.allowCollisions = FlxObject.UP;
                ladder.immovable = true;
                state.ladders.add(ladder);

                // Spawn the appropriate oneway solid at the top of the stair
                spawnOneway(x, y, o.width, 1, state);

            case "spring":
            // Create the spring according to the position decided in TiledMap
            var spring : Spring = new Spring(x, y, state);
            var mask : FlxPoint = new FlxPoint(o.width - o.width/3, o.height - o.height /3);
            spring.init(o.width, o.height, o.custom.get("sprite"), mask, Std.parseInt(o.custom.get("fps")));
            state.springs.add(spring);

            /** Collectibles **/
            case "collectible":
                switch (o.name.toLowerCase())
                {
                    case "musicnote":
                        // We create a variable to contain the file name
                        var file : String;
                        // We either get the file name from the map or assign it a default sound
                        if (o.custom.contains("file"))
                            file = o.custom.get("file");
                        else
                            file = "default.wav";

                        // We create the musical note with the object data and add it to the map
                        var musicnote : MusicNote = new MusicNote(x, y, state, file);
                        state.addNote(musicnote);
                }

            /** Elements **/
            /*	case "decoration":
				var gid = o.gid;
				var tiledImage : TiledImage = getImageSource(gid);
				if (tiledImage == null)
				{
					trace("Could not locate image source for gid=" + gid + "!");
				}
				else
				{
					var decoration : Decoration = new Decoration(x, y, state, tiledImage);
					state.decoration.add(decoration);
				}*/

            /** Enemies **/
				case "footzone":
					var zone : FlxObject = new FlxObject(x, y, o.width, o.height);
					zone.immovable = false;
					state.footzones.add(zone);
				case "enemy":
					// Instantiate the enemy
					var enemy : Enemy = EnemyBuilder.build(g, o, x, y, state);
					// And add it to the world
					state.enemies.add(enemy);
        }
    }

    public function spawnOneway(x : Float, y : Float, width : Float, height : Float, state : PlayState)
    {
        var oneway : FlxObject = new FlxObject(x, y, width, height);
        // Configure it to allow collisions from the top, only
        oneway.allowCollisions = FlxObject.UP;
        // It should not move when handling collisions
        oneway.immovable = true;
        // And add it
        state.oneways.add(oneway);
    }

    function getImageSource( gid : Int ) : TiledImage
    {
        var image : TiledImage = imageCollection.get( gid );
        image.imagePath = "assets/tilesets/detail/" + image.sourceImage;
        return image;
    }

    public function initEnemy( e : Enemy, o : TiledObject ) : Void
    {
        var variation : Int = getVariation( o );

        // e.init(variation);
    }

    public function getVariation( o : TiledObject ) : Int
    {
        var worldTypeStr : String = o.custom.get( "variation" );
        if ( worldTypeStr != null )
            return Std.parseInt( worldTypeStr );
        else
            return 0;
    }

    public function addPlayer( x : Int, y : Int, state : PlayState ) : Void
    {
		if (state.player == null)
		{
			var player : Player = new Player(x, y, state);
			state.add(player);
			state.addPlayer( player );
		}
		else
		{
			state.player.x = x;
			state.player.y = y;
		}
    }

    public function collideWithLevel( obj : FlxObject, ?notifyCallback : FlxObject -> FlxObject -> Void, ?processCallback : FlxObject -> FlxObject -> Bool ) : Bool
    {
        if ( collidableTileLayers != null )
        {
            for ( map in collidableTileLayers )
            {
                // Remember: Collide the map with the objects, not the other way around!
                return FlxG.overlap( map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate );
            }
        }

        return false;
    }

    private function buildPath( tileset : TiledTileSet, ?spritesCase : Bool = false ) : String
    {
        var imagePath = new Path(tileset.imageSource);
        var processedPath = (spritesCase ? spritesPath : tilesetPath) +
                            imagePath.file + "." + imagePath.ext;

        return processedPath;
    }

    public function destroy( )
    {
        backgroundTiles.destroy( );
        foregroundTiles.destroy( );
        overlayTiles.destroy( );
        for ( layer in collidableTileLayers )
            layer.destroy( );
    }
}
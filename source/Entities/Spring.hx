package;

import flixel.util.FlxPoint;

class Spring extends Entity
{

    private var fps : Int;
    private var DefaultFPS : Int = 8;

    public function new( X : Float, Y : Float, World : PlayState )
    {
        super( X, Y, World );
    }

    /**
	 * Initializes the spring with the given parameters
	 * @param Width			Width of the spring & spring sprite
	 * @param Height 		Height of the spring  & spring sprite
	 * @param Sprite		Filename (without path or extension) of the spritesheet for the spring
	 * @param Mask			FlxPoint with (w, h) of collision mask. Will be centered on Width, Height
	 * @param FPS			Frames-per-second for the spring animation
	 */

    public function init( Width : Int, Height : Int, ?Sprite : String = null, ?Mask : FlxPoint, ?FPS : Int = -1 )
    {
        // If no sprite is specified, just make a placeholder rectangle
        if ( Sprite == null )
        {
            makeGraphic( Width, Height, 0xFFEB3BB7 );
        }
        else // If a sprite is specified, use it!
        {
            // If no fps is provided, use the default
            fps = FPS;
            if ( fps < 0 )
                fps = DefaultFPS;

            // Load the specified spritesheet with the given width and height
            loadGraphic( "assets/images/" + Sprite + ".png", true, Width, Height );

            if ( Mask != null )
            {
                setSize( Mask.x, Mask.y );
                centerOffsets( true );
            }

            // Add the animation with the appropriate fps
            animation.add( "stepped", [1, 0], fps, false );
        }
    }

    public function onStepped( )
    {
        animation.play( "stepped" );
    }
}

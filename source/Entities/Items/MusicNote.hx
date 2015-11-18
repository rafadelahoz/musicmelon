package;

import flixel.system.debug.Log;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.system.FlxSound;

/**
*   This class represents a collectible with the graphic of a musical note
*   and that has a sound attached to it. When the player collects it the
*   sound is played and added to the list of notes the player can use.
**/
class MusicNote extends Collectible
{
    /**
    *   Sound played when the note is collected
    **/
    private var _sound : FlxSound;
	private var sfxPath : String;

    public function new( X : Float, Y : Float, World : PlayState, File : String )
    {
        super( X, Y, World );

        // We load the graphic of a musical note
        loadGraphic( "assets/images/musicnote_sheet.png", true, 16, 16 );

		sfxPath = "assets/sounds/" + File;
		
        // We create a new sound from a wav file
        //TODO Is this multiplatform?
        _sound = FlxG.sound.load( sfxPath );

        //We add an iddle animation to the note based on its graphic
        animation.add( "idle", [0] );
    }

    /**
    *   Function that plays the sound on top of the default collectible action
    **/
    override public function onCollected( ) : Void
    {
        //TODO It is not playing on surface o.o
        _sound.play( true );
        super.onCollected( );
		
		world.onNoteCollected(sfxPath);
    }

    /**
    *   Function called when the note is destroyed, it unloads the sound associated to it
    **/
    override public function destroy( )
    {
        _sound = FlxDestroyUtil.destroy( _sound );
        super.destroy( );
    }
}

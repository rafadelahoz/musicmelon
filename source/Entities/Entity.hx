package;

import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * Parent to elements living in the PlayState
 **/
class Entity extends FlxSprite
{
	var world : PlayState;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y);
		
		world = World;
	}
	
	// Response to music heard
	public function onNoteHeard(noteMask : FlxObject)
	{
		// Override me!
	}
	
	// Called when pausing the game
	public function onPause()
	{
		// Override me!
	}
}
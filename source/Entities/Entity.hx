package;

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
}
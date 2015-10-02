package;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
	var world : PlayState;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y);
		
		world = World;
	}
}
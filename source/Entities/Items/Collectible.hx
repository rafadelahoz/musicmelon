package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;

class Collectible extends Entity
{
	var tween : FlxTween;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		tween = null;
	}
	
	override public function update()
	{
		if (scale.x <= 0) kill();
		
		super.update();
	}
	
	// This is to be overidden
	public function onCollisionWithPlayer(player : Player) : Void
	{
		if (alive) {
			// Collected!
			onCollected();
		}
	}
	
	public function onCollected():Void 
	{
		if (tween != null)
			tween.cancel();
		
		alive = false;
		blend = BlendMode.ADD;
		tween = FlxTween.tween(scale, { x:0, y:2 }, 0.175);
		velocity.y = -150;
	}
}
package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class FxPlayedNote extends FlxSprite
{
	public var LifeTime : Float = 1;

	public function new(X : Float, Y : Float, Facing : Int)
	{
		super(X, Y);
		
		facing = Facing;
		var f : Int = (facing == FlxObject.LEFT ? -1 : 1);
		
		loadGraphic("assets/images/small_note.png");
		
		var vx : Float = FlxRandom.intRanged(60, 140) * f;
		var vy : Float = FlxRandom.intRanged(60, 140);
		
		var x0 : Float = 0;
		var x1 : Float = vx;
		var y0 : Float = -vy;
		var y1 : Float = 0;
		
		if (FlxRandom.chanceRoll(50))
		{
			x0 = vx; x1 = 0;
			y0 = 0;  y1 = -vy;
		}
		
		velocity.x = x0;
		velocity.y = y0;
		FlxTween.tween(velocity, {x : x1, y : y1}, LifeTime/3, { ease: FlxEase.sineInOut, type: FlxTween.PINGPONG });
		FlxTween.tween(this, {alpha: 0}, LifeTime, { ease: FlxEase.sineIn, complete : function(_t:FlxTween) {
			kill();
		}});
		
		solid = false;
	}
}
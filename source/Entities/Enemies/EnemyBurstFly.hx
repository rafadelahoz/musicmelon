package;

import flixel.util.FlxPoint;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import utils.MathUtils;

using flixel.util.FlxVelocity;

class EnemyBurstFly extends Enemy
{
	// Configurable vars
	public var idleBaseTime : Float = 2.5;
	public var chargeSpeed : Float = 50;
	public var floaty : Bool = true;
	
	public var idleVarTimeFactor : Float = 0.15;
	public var chaseDistance : Int = 100;
	public var chargeTime : Float = 0.6;
	
	public var randomTargetRadius : Int = 24;
	var retarget : Bool = false;

	var brain : StateMachine;
	
	var canTurn : Bool;
	var timer : FlxTimer;
	var tween : FlxTween;
	var mobileTarget : Bool;
	var target : FlxPoint;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
	}

	override public function onInit()
	{
		collideWithLevel = false;
		
		animation.add("charge", [0, 1], FlxRandom.intRanged(fps, fps*2));
		
		timer = new FlxTimer();
		
		brain = new StateMachine(null, onStateChange);
		brain.transition(idle, "idle");
	}
	
	override public function onPause()
	{
		tween.active = false;
		timer.active = false;
	}
	
	override public function update() : Void
	{
		if (world.paused || stunned)
		{
			tween.active = false;
			timer.active = false;
			return;
		}
		else
		{
			tween.active = true;
			timer.active = true;
		}
			
		brain.update();
		super.update();
	}
	
	public function onStateChange(newState : String) : Void
	{
		switch (newState)
		{
			case "idle":
				velocity.set();
				// Animation
				animation.play("idle");

				// Start the idle floaty motion
				if (floaty)
				{
					tween = FlxTween.tween(this, {x: x, y: y + 4}, 0.5, { type: FlxTween.PINGPONG, ease: FlxEase.quadInOut });
				}
				
				// Charge after some time
				timer.start(decideIdleTime(), function (_timer : FlxTimer) {
					brain.transition(charge, "charge");
				});
			case "charge":
				// Animation
				animation.play("charge");

				// Stop the idle motion
				if (floaty)
				{
					tween.cancel();
					tween.destroy();
				}
				
				// Choose your target
				// Chase the player if it is near enough
				if (getMidpoint().distanceTo(player.getMidpoint()) < chaseDistance)
				{
					target = player.getMidpoint();
					mobileTarget = true;
				}
				else // Move to a random near point
				{
					target = chooseRandomTarget();
					mobileTarget = false;
				}
				
				timer.start(chargeTime, function (_timer : FlxTimer) {
					brain.transition(idle, "idle");
				});
		}
	}
	
	public function idle()
	{
		// Floaty floaty
	}
	
	public function charge()
	{
		moveTowardsPoint(target, chargeSpeed);
		if (retarget && mobileTarget)
			target = player.getMidpoint();
	}
	
	public function chooseRandomTarget() : FlxPoint
	{
		var angle : Float = FlxRandom.intRanged(0, 359);
		angle = MathUtils.degToRad(angle);
		var length : Float = FlxRandom.intRanged(0, randomTargetRadius);
		
		var target : FlxPoint = new FlxPoint();
		target.x = Math.cos(angle) * length;
		target.y = Math.sin(angle) * length;
		
		return target;
	}
	
	public function decideIdleTime() : Float
	{
		var maxVarTime : Float = idleBaseTime*idleVarTimeFactor;
		var varTime : Float = FlxRandom.floatRanged(-maxVarTime, maxVarTime);
		return idleBaseTime + varTime;
	}
}
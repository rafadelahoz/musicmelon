package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxRect;
import flixel.util.FlxTimer;

class EnemyFoot extends Enemy
{
	public static var IdleTime : Float = 2;
	public static var StompTime : Float = 0.3;
	public static var AheadTime : Float = 0.2;
	public static var QuickFallTime : Float = 0.3;
	public static var FallAcceleration : Int = 500;
	public static var RiseAcceleration : Int = 500;

	public var brain : StateMachine;
	public var timer : FlxTimer;
	public var moving : Bool;
	public var onGround : Bool;

	public function new(X : Float, Y : Float, World : PlayState, ?Fall : Bool = false)
	{
		super(X, Y, World);
		
		makeGraphic(16, 16, 0xFFFFFFFF);
		
		facePlayer = false;
		collideWithLevel = true;
		
		brain = new StateMachine(null, onStateChange);
		timer = new FlxTimer();
		moving = false;
		
		maxVelocity.set(240, 240);
		
		world.feet.add(this);
		
		if (!Fall)
			brain.transition(idle, "idle");
		else
			timer.start(QuickFallTime, function(_t:FlxTimer) {
				brain.transition(fall, "quick-fall");
			});
	}
	
	override public function destroy()
	{
		world.feet.remove(this);
		super.destroy();
	}
	
	override public function update()
	{
		brain.update();
		super.update();
	}
	
	public function onStateChange(newState : String)
	{
		switch (newState)
		{
			case "idle", "quick-idle":
				moving = false;
				
				var quick : Bool = (newState == "quick-idle");
				
				// Position outside camera
				y = FlxG.camera.scroll.y - 32;
				// Setup a timer to start falling
				timer.start(getIdleTime(quick), function(_t:FlxTimer) {
					brain.transition(fall, "fall");
				});
				// Don't collide while idling
				collideWithLevel = false;
			case "fall", "quick-fall":
				moving = true;
				// Slow yourself down!
				velocity.set();
				acceleration.y = FallAcceleration;
				
				// Position a little ahead the player position (when not quick-falling)
				x = player.x + (newState == "fall" ? player.velocity.x * AheadTime : 0);
				// And at the top of the camera view
				y = FlxG.camera.scroll.y;
				
				if (!ValidSpawnPosition(x, this, world))
				{
					trace("no!");
					brain.transition(idle, "idle");
				}
				else
				{
					// Don't collide while falling
					collideWithLevel = true;
					// We have not touched ground yet
					onGround = false;
				}
			case "rise":
				moving = true;
				// Stop any ongoing timer
				timer.cancel();
				// Don't collide while rising
				collideWithLevel = false;
		}
	}
	
	/* States */
	
	public function idle()
	{
	}
	
	public function fall()
	{
		collideWithLevel = (getMidpoint().distanceTo(player.getMidpoint()) < FlxG.height / 2);
	
		color = 0xFFFF4141;
		if (!onGround)
		{
			acceleration.y = FallAcceleration;
		}
		else
		{
			acceleration.y = 0;
		}
	}
	
	public function rise()
	{
		color = 0xFF4141FF;
		acceleration.y = -RiseAcceleration;
		if (y + height < FlxG.camera.scroll.y)
		{
			brain.transition(idle, "idle");
		}
	}
	
	/* Handlers */
	override public function onCollisionWithWorld(level : FlxObject)
	{
		if (!onGround && acceleration.y > 0)
		{
			onGround = true;
			
			FlxG.camera.shake(0.025, 0.35);
			
			velocity.y = 0;
			acceleration.y = 0;
			
			timer.start(StompTime, function(_t:FlxTimer) {
				brain.transition(rise, "rise");
			});
		}
	}
	
	/* Methods */
	
	public function getIdleTime(?Quick : Bool = false) : Float
	{
		return IdleTime * (Quick ? 0.5 : 1);
	}
	
	public function getBounds(?X : Float) : FlxRect
	{
		if (X == null)
			X = x;
		
		return new FlxRect(X - 8, X + width + 8, 0, FlxG.height);
	}
	
	public static function ValidSpawnPosition(x : Float, foot : EnemyFoot, world : PlayState) : Bool
	{
		var bounds : FlxRect = foot.getBounds(x);
	
		for (object in world.feet)
		{
			var foot : EnemyFoot = (cast object);
			if (foot.moving)
			{
				var otherBounds : FlxRect = foot.getBounds();
				if (bounds.overlaps(otherBounds))
				{
					return false;
				}
			}
		}
		
		return true;
	}
}
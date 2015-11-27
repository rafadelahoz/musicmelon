package;

import flixel.FlxObject;

class EnemyDroplet extends Enemy
{
	var speed : Float;
	var accel : Float;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		speed = 0;
		accel = 0;
	}
	
	public function setMotion(Direction : Int, Speed : Float, Acceleration : Float)
	{
		facing = Direction;
		speed = Speed;
		accel = Acceleration;
	}
	
	override public function update()
	{
		switch (facing)
		{
			case FlxObject.LEFT:
				velocity.set(-speed, 0);
				acceleration.set(-accel, 0);
			case FlxObject.RIGHT:
				velocity.set(speed, 0);
				acceleration.set(accel, 0);
			case FlxObject.UP:
				velocity.set(0, -speed);
				acceleration.set(0, -accel);
			case FlxObject.DOWN:
				velocity.set(0, speed);
				acceleration.set(0, accel);
		}
		
		super.update();
	}
	
	override public function onCollisionWithWorld(level : FlxObject)
	{
		kill();
		world.enemies.remove(this);
		destroy();
	}
	
	override public function onNoteHeard(noteMask : FlxObject)
	{
		// Do nothing!
	}
}
package;

import flixel.FlxObject;

class Player extends Entity
{
	public var HSpeed : Float = 70;
	public var JumpSpeed : Float = 130;

	public var onAir : Bool;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);

		makeGraphic(12, 12, 0xFF3BEB6F);

		onAir = false;
	}

	override public function update()
	{
		onAir = !isTouching(FlxObject.DOWN);

		acceleration.y = GameConstants.Gravity;

		if (GamePad.checkButton(GamePad.Left))
		{
			velocity.x = -HSpeed;
		}
		else if (GamePad.checkButton(GamePad.Right))
		{
			velocity.x = HSpeed;
		}
		else
			velocity.x = 0;

		if (!onAir && velocity.y == 0)
		{
			if (GamePad.justPressed(GamePad.A))
				velocity.y = -JumpSpeed;
		}

		super.update();
	}

	public function onCollisionWithEnemy(enemy : Enemy)
	{
		// What?
	}
}
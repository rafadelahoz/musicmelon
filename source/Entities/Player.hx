package;

import flixel.FlxObject;

class Player extends Entity
{
	public var HSpeed : Float = 60;
	public var JumpSpeed : Float = 180;

	public var onAir : Bool;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);

		loadGraphic("assets/images/melon_sheet.png", true, 16, 16);
		animation.add("idle", [0]);
		animation.add("walk", [4, 5, 6, 7], 6, true);
		animation.add("jump", [8]);

		flipX = false;

		onAir = false;
	}

	override public function update()
	{
		onAir = !isTouching(FlxObject.DOWN);

		acceleration.y = GameConstants.Gravity;

		if (GamePad.checkButton(GamePad.Left))
		{
			velocity.x = -HSpeed;
			facing = FlxObject.LEFT;
		}
		else if (GamePad.checkButton(GamePad.Right))
		{
			velocity.x = HSpeed;
			facing = FlxObject.RIGHT;
		}
		else
			velocity.x = 0;

		if (!onAir)
		{
			if (velocity.y == 0 && GamePad.justPressed(GamePad.A))
				velocity.y = -JumpSpeed;
		}
		else
		{
			if (GamePad.justReleased(GamePad.A) && velocity.y < 0)
				velocity.y /= 2;
		}

		super.update();
	}

	override public function draw()
	{
		if (onAir)
			animation.play("jump");
		else
		{
			if (velocity.x == 0)
				animation.play("idle");
			else
				animation.play("walk");
		}

		flipX = (facing == FlxObject.LEFT);

		super.draw();
	}

	public function onCollisionWithEnemy(enemy : Enemy)
	{
		// What?
	}
}
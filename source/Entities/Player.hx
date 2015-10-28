package;

import flixel.FlxObject;

/**
 * Handles the player state, input, movement and response to events 
 */
class Player extends Entity
{
	/* Constants */
	public var HSpeed : Float = 60;
	public var JumpSpeed : Float = 185;

	/* State variables */
	// Whether the player is on air or on ground
	public var onAir : Bool;

	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);

		loadGraphic("assets/images/melon_sheet.png", true, 16, 16);
		animation.add("idle", [0]);
		animation.add("walk", [4, 5, 6, 7], 6, true);
		animation.add("jump", [8]);

		setSize(12, 12);
		offset.set(2, 4);
		
		flipX = false;

		onAir = false;
	}

	override public function update()
	{
		// Check whether we are airborne
		onAir = !isTouching(FlxObject.DOWN);

		// The gravity will affect nonetheless
		acceleration.y = GameConstants.Gravity;

		// Handle movement
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

		// When on ground, the melon can jump
		if (!onAir)
		{
			// But only if we are not falling and A is pressed
			if (velocity.y == 0 && GamePad.justPressed(GamePad.A))
				velocity.y = -JumpSpeed;
		}
		else
		{
			// When going up on air, releasing the jump button
			// cancels the jump so we have more control
			if (GamePad.justReleased(GamePad.A) && velocity.y < 0)
				velocity.y /= 2;
		}

		// The parent will compute the actual position considering
		// velocity and gravity
		super.update();
	}

	override public function draw()
	{
		// Handle animations (may be better to do this on update?)
		if (onAir)
			animation.play("jump");
		else
		{
			if (velocity.x == 0)
				animation.play("idle");
			else
				animation.play("walk");
		}

		// Flip the graphic when looking to the left
		flipX = (facing == FlxObject.LEFT);

		// The parent will actually render the graphic
		super.draw();
	}

	/* Collision Event Handlers */

	public function onCollisionWithEnemy(enemy : Enemy)
	{
		// What?
	}
}
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;

/**
 * Handles the player state, input, movement and response to events 
 */
class Player extends Entity
{
    /* Constants */
    public var HSpeed : Float = 60;
    public var JumpSpeed : Float = 185;
	public var PlayTime : Float = 0.5;

    /* State variables */
    // Whether the player is on air or on ground
    public var onAir : Bool;
    // True if the player has died and the animation is playing
    public var dying : Bool;
    // Whether the player is on a ladder
    public var onLadder : Bool;
	// Which ladder the player currently is
	public var ladder : FlxObject;
    // Is the player climbing?
    public var climbing : Bool;
	// Is the player playing?
	public var playing : Bool;
	public var instrument : FlxSprite;
	public var timer : FlxTimer;
	
	// Debug!
	public var immortal : Bool;
    public var debugMode : Bool;

    public function new( X : Float, Y : Float, World : PlayState )
    {
        super( X, Y, World );

        loadGraphic( "assets/images/melon_sheet.png", true, 16, 16 );
        animation.add( "idle", [0] );
        animation.add( "walk", [4, 5, 6, 7], 6, true );
		animation.add( "play", [4, 0], 4, true );
        animation.add( "jump", [8] );
        animation.add( "climb", [9, 10], 6, true);
        animation.add( "dead", [0, 4, 8], 10, true );
        animation.add( "debug", [1]);

        setSize( 12, 12 );
        offset.set( 2, 4 );
		
		instrument = new FlxSprite("assets/images/melon_instrument.png");
		instrument.solid = false;
		instrument.kill();

        flipX = false;

        onAir = false;
        dying = false;
        onLadder = false;
        climbing = false;
		
        debugMode = false;
		immortal = false;
		
		timer = new FlxTimer();
    }

    override public function update( )
    {
        if (debugMode)
        {
            solid = false;
            immortal = true;

            velocity.set();
            acceleration.set();

            if ( GamePad.checkButton( GamePad.Left ) )
            {
                velocity.x = -HSpeed;
                facing = FlxObject.LEFT;
            }
            else if ( GamePad.checkButton( GamePad.Right ) )
            {
                velocity.x = HSpeed;
                facing = FlxObject.RIGHT;
            }

            if ( GamePad.checkButton( GamePad.Up ) )
            {
                velocity.y = -HSpeed;
                facing = FlxObject.LEFT;
            }
            else if ( GamePad.checkButton( GamePad.Down ) )
            {
                velocity.y = HSpeed;
                facing = FlxObject.RIGHT;
            }

            velocity.x *= 2;
            velocity.y *= 2;

            if (FlxG.keys.justPressed.J)
            {
                debugMode = false;
                velocity.set();
                solid = true;
                immortal = false;
            }

            super.update();

            return;
        }
        else
        {
            if (FlxG.keys.justPressed.J)
            {
                debugMode = true;
            }
        }

        // Check whether we are airborne
        onAir = !isTouching( FlxObject.DOWN );

        // And check whether we are over a ladder
        onLadder = overlaps(world.ladders);
		// We are over a ladder if we are really close to its center!
		if (onLadder && ladder != null)
		{
			onLadder = Math.abs(ladder.getMidpoint().x - getMidpoint().x) <= 8;
		}

        if (!onLadder)
            climbing = false;

        // The gravity will affect nonetheless
        acceleration.y = GameConstants.Gravity;

        if ( dying )
        {
            if ( !isOnScreen( ) )
            {
                GameController.OnDeath( );
            }
        }
        else // if alive
        {
			if (playing && onAir)
			{
				onPlayingEnd(timer);
			}
		
			if (playing)
			{
				// Do nothing, just play?
				velocity.set();
			}
			else
			{
				// Handle movement
				if ( GamePad.checkButton( GamePad.Left ) )
				{
					velocity.x = -HSpeed;
					facing = FlxObject.LEFT;
				}
				else if ( GamePad.checkButton( GamePad.Right ) )
				{
					velocity.x = HSpeed;
					facing = FlxObject.RIGHT;
				}
				else
					velocity.x = 0;

				if (!onAir && !onLadder && GamePad.justPressed(GamePad.B))
				{
					if (world.collectedNotes.length > 0)
					{
						FlxG.sound.play(FlxRandom.getObject(world.collectedNotes));
						playing = true;
						instrument.revive();
						timer.start(PlayTime, onPlayingEnd);
					}
				}
					
				handleJump();
				
				if ( onLadder )
				{
					handleLadder();
				}
			}
        }

        // The parent will compute the actual position considering
        // velocity and gravity
        super.update();
		
		handleInstrument();
    }
	
	public function onPlayingEnd(t:FlxTimer) {
		if (t != null)
			t.cancel();
		playing = false;
		instrument.kill();
	}
	
	public function handleInstrument()
	{
		if (instrument.alive)
		{
			instrument.x = getMidpoint().x + (flipX ? - instrument.width : 0);
			instrument.y = y;
			instrument.flipX = flipX;
			
			instrument.update();
		}
	}

	public function handleJump()
	{
		if (playing)
			return;
			
		// When on ground, the melon can jump
		if ( !onAir || onLadder )
		{
			// But only if we are not falling and A is pressed
			if ( velocity.y == 0 && GamePad.justPressed( GamePad.A ) )
			{
				velocity.y = -JumpSpeed;
				onLadder = false;
				climbing = false;
			}
		}
		else
		{
			// When going up on air, releasing the jump button
			// cancels the jump so we have more control
			if ( GamePad.justReleased( GamePad.A ) && velocity.y < 0 )
				velocity.y /= 2;
		}
	}
	
	public function handleLadder()
	{
		if (!climbing)
		{
			if ( GamePad.checkButton( GamePad.Up ) || GamePad.checkButton( GamePad.Down ) )
			{
				climbing = true;

				if (GamePad.checkButton(GamePad.Down))
				{
					// Get down from the top of a stair case
					// TODO: Make a smooth animation or something!
					if (overlapsAt(x, y + height, world.oneways) && overlapsAt(x,y+height, world.ladders))
					{
						y += 6;
						last.y = y;
						velocity.y = 0;
					}
				}
			}
		}
		
		if (climbing)
		{
			// If the player is in the air but touching a ladder then gravity doesn't affect it
			// if ( onAir )
			velocity.y = 0;
			acceleration.y = 0;

			animation.paused = true;
			
			// If the player presses up then the melon goes up unnafected by gravity
			if ( GamePad.checkButton( GamePad.Up ) )
			{
				velocity.y = -HSpeed;
				acceleration.y = 0;
				animation.paused = false;
			}
			// If the player presses down then the melon goes down unnafected by gravity
			else if ( GamePad.checkButton( GamePad.Down ) )
			{
				velocity.y = HSpeed;

				animation.paused = false;
			}

			// When the player is climbing we center him slowly on the stair
			if (velocity.y != 0)
			{
				var lerpedX : Float = FlxMath.lerp(getMidpoint().x, ladder.getMidpoint().x, 0.5);
				var deltaX : Float = lerpedX - getMidpoint().x;
				
				x += deltaX;
			}

			// If the player stops pressing Up or Down then the melon stops moving up or down
			if (GamePad.justReleased(GamePad.Up) || GamePad.justReleased(GamePad.Down))
			{
				velocity.y = 0;
			}
		}

		// If we are on ground, after all, no laddering please
		// We are on ground if we have a one-way-solid beneath (we are on top of a stair)
		// or if we have no more stair below, that is, at y+height
		if (overlapsAt(x, y+1, world.oneways) || !overlapsAt(x, y+height, world.ladders))
		{
			acceleration.y = GameConstants.Gravity;
			onLadder = false;
		}
	}
	
    override public function draw( )
    {
        // Handle animations (may be better to do this on update?)
        if (debugMode)
        {
            animation.play("debug");
        }
        else if ( dying )
        {
            animation.play( "dead" );
        }
        else
        {
			if (playing)
				animation.play("play");
            else if (climbing)
                animation.play("climb");
            else if ( onAir )
                animation.play( "jump" );
            else
            {
                if ( velocity.x == 0 )
                    animation.play( "idle" );
                else
                    animation.play( "walk" );
            }
        }

        // Flip the graphic when looking to the left
        flipX = (facing == FlxObject.LEFT);

        // The parent will actually render the graphic
        super.draw();
		
		if (instrument.alive)
			instrument.draw();
    }

    /* Collision Event Handlers */

    public function onCollisionWithEnemy( enemy : Enemy )
    {
		if ( immortal )
			return;
			
        if ( !dying )
        {
			// You are dead, so jump out of the way
            solid = false;

            if ( enemy.getMidpoint( ).x > getMidpoint( ).x )
            {
                velocity.x = -HSpeed;
                facing = FlxObject.RIGHT;
            }
            else
            {
                velocity.x = HSpeed;
                facing = FlxObject.LEFT;
            }

            velocity.y = -JumpSpeed * 0.8;

            dying = true;

            world.onPlayerDeath( );
        }
    }

    public function onCollisionWithLadder(Ladder : FlxObject)
    {
		ladder = Ladder;
    }
}
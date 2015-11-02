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
    // True if the player has died and the animation is playing
    public var dying : Bool;
    // Whether the player is on a ladder
    public var onLadder : Bool;
	// Which ladder the player currently is
	public var ladder : FlxObject;

    public function new( X : Float, Y : Float, World : PlayState )
    {
        super( X, Y, World );

        loadGraphic( "assets/images/melon_sheet.png", true, 16, 16 );
        animation.add( "idle", [0] );
        animation.add( "walk", [4, 5, 6, 7], 6, true );
        animation.add( "jump", [8] );
        animation.add( "dead", [0, 4, 8], 10, true );

        setSize( 12, 12 );
        offset.set( 2, 4 );

        flipX = false;

        onAir = false;
        dying = false;
        onLadder = false;
    }

    override public function update( )
    {
        // Check whether we are airborne
        onAir = !isTouching( FlxObject.DOWN );

        // And check whether we are over a ladder
        onLadder = overlaps(world.ladders);
		// We are over a ladder if we are really close to its center!
		if (onLadder && ladder != null)
		{
			onLadder = Math.abs(ladder.getMidpoint().x - getMidpoint().x) <= 4;
		}

        // The gravity will affect nonetheless
        acceleration.y = GameConstants.Gravity;

        if ( dying )
        {
            if ( !isOnScreen( ) )
            {
                trace( "dead" );
                GameController.OnDeath( );
            }
        }
        else // if alive
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

            // When on ground, the melon can jump
            if ( !onAir )
            {
                // But only if we are not falling and A is pressed
                if ( velocity.y == 0 && GamePad.justPressed( GamePad.A ) )
                    velocity.y = -JumpSpeed;
            }
            else
            {
                // When going up on air, releasing the jump button
                // cancels the jump so we have more control
                if ( GamePad.justReleased( GamePad.A ) && velocity.y < 0 )
                    velocity.y /= 2;
            }
			
            if ( onLadder )
            {
                // If the player is in the air but touching a ladder then gravity doesn't affect it
                // if ( onAir )
                velocity.y = 0;
                acceleration.y = 0;
                
                // If the player presses up then the melon goes up unnafected by gravity
                if ( GamePad.checkButton( GamePad.Up ) )
                {
                    velocity.y = -HSpeed;
                    acceleration.y = 0;
                }
                // If the player presses down then the melon goes down unnafected by gravity
                else if ( GamePad.checkButton( GamePad.Down ) )
                {
					velocity.y = HSpeed;
					
					// Get down from the top of a stair case
					// TODO: Make a smooth animation or something!
					if (GamePad.checkButton(GamePad.Down) && overlapsAt(x, y + height, world.oneways))
					{
						onLadder = true;
						y += 6;
						last.y = y;
						velocity.y = 0;
					}
                }

                // If the player stops pressing Up or Down then the melon stops moving up or down
                if (GamePad.justReleased(GamePad.Up) || GamePad.justReleased(GamePad.Down))
                {
                    velocity.y = 0;
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
        }

        // The parent will compute the actual position considering
        // velocity and gravity
        super.update( );
    }

    override public function draw( )
    {
        // Handle animations (may be better to do this on update?)
        if ( dying )
        {
            animation.play( "dead" );
        }
        else
        {
            if ( onAir )
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
        super.draw( );
    }

    /* Collision Event Handlers */

    public function onCollisionWithEnemy( enemy : Enemy )
    {
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
package;

import flixel.FlxObject;
import flixel.util.FlxTimer;

class EnemyWalker extends Enemy
{
	public var hspeed : Float = 40;
	public var turnDelay : Float = 0.5;
	
	var brain : StateMachine;
	
	public function new(X : Float, Y : Float, World : PlayState, Behaviour : Int)
	{
		super(X, Y, World);
		
		behaviour = Behaviour;
	}
	
	override public function onInit()
	{
		// Face the player
		/*if (world.player.getMidpoint().x < getMidpoint().x)
			facing = FlxObject.LEFT;
		else*/
			facing = FlxObject.RIGHT;
	
		// Start your engines!
		brain = new StateMachine(null, onStateChange);
		brain.transition(walk, "walk");
	}
	
	override public function update()
	{
		acceleration.y = GameConstants.Gravity;
		
		brain.update();
		super.update();
	}
	
	public function onStateChange(nextState : String) : Void
	{
		if (nextState == "turn")
		{
			doTurn();
		
			// Now wait a tad before starting to actually walk
			new FlxTimer(turnDelay, 
				function postTurnTimer(timer : FlxTimer)
				{
					brain.transition(walk, "walk");					
				});
			}
	}
	
	override public function onNoteHeard(noteMask : FlxObject)
	{		
		velocity.y = 0;
		velocity.x = 0;
		super.onNoteHeard(noteMask);
	}
	
	override public function onStunEnd()
	{
		stunned = false;
		brain.transition(turn, "turn");
	}

	public function walk() : Void
	{
		if (facing == FlxObject.RIGHT)
		{
			velocity.x = hspeed;
		}
		else
		{
			velocity.x = -hspeed;
		}

		if (justTouched(FlxObject.RIGHT) || justTouched(FlxObject.LEFT))
			brain.transition(turn, "turn");
		
		if (velocity.y != 0) 
		{
			// fall
			velocity.x = 0;
		} 
		else 
		{
			animation.play("idle");
		}
		
		flipX = (flipOnMove && velocity.x < 0);
	}

	public function turn() : Void
	{
		velocity.x = 0;
	}
	
	public function doTurn() : Void
	{
		// Faces the opposite direction of the current one
		if (facing == FlxObject.LEFT)
			facing = FlxObject.RIGHT;
		else
			facing = FlxObject.LEFT;
	}
}
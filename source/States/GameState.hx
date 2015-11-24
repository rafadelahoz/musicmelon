package;

import flixel.FlxG;
import flixel.FlxState;

/**
 * Parent to our game states, handles the GamePad update
 **/
class GameState extends FlxState
{
	public function new()
	{
		super();
	}
	
	override public function create()
	{
		// Delegate
		super.create();
		
		GamePad.resetInputs();
		FlxG.inputs.reset();
	}
	
	override public function update()
	{
		// Update the GamePad state
		GamePad.handlePadState();
		
		if (GameDebug.Cheat("LLLT"))
			FlxG.resetState();
	
		// Before performing the actual update
		super.update();
	}
}
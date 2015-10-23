package;

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
		// Register the Virtual Pad
		GamePad.setupVirtualPad();
		add(GamePad.virtualPad);

		// Delegate
		super.create();
	}
	
	override public function update()
	{
		// Update the GamePad state
		GamePad.handlePadState();
	
		// Before performing the actual update
		super.update();
	}
}
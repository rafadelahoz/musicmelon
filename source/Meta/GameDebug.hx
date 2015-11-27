package;

import flixel.FlxG;

class GameDebug
{
	public static function ToLevelSelectScreen()
	{
		FlxG.switchState(new DebugLevelSelectState());
	}
	
	public static function WarpToLevel(level : String)
	{
		FlxG.switchState(new PlayState(level));
	}
	
	public static function Cheat(code : String) : Bool
	{
		return GamePad.findInHistory(code);
	}
	
	public static function CheatParser()
	{
		if (Cheat("UUDDLRLRBAT"))
		{
			GameDebug.ToLevelSelectScreen();
		}
	}
}
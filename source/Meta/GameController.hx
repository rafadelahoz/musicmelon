package;

import flixel.FlxG;

class GameController 
{
	public static function Init()
	{
		GameStatus.currentLevel = "0";

		// Try to set level from command line
		var args : Array<String> = Sys.args();
		trace(args);
		if (args.length > 1 && args[0] != null)
		{
			var comps : Array<String> = args[0].split("=");
			if (comps[0] == "level")
				GameStatus.currentLevel = comps[1];
		}
	}

	/** Game Management API **/
	public static function ToTitleScreen()
	{
		FlxG.switchState(new MenuState());
	}
	
	public static function StartGame()
	{
		FlxG.switchState(new PlayState(GameStatus.currentLevel));
	}
	
	public static function OnDeath()
	{
		FlxG.switchState(new DeathState());
	}
}
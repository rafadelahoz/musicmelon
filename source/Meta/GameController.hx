package;

import flixel.FlxG;

class GameController 
{
	public static var levels : Array<String> = ["house-0", "0", "Outside", "r1", "r2"];

	public static function Init()
	{
		GameStatus.currentLevel = -1;
		GameStatus.currentLevelName = null;
	
		ParseArgs();
		
		if (GameStatus.currentLevelName != null) 
		{
			// Debug: a test level has been specified, try to locate it in the level list
			var index : Int = levels.indexOf(GameStatus.currentLevelName);
			if (index >= 0)
			{
				GameStatus.currentLevel = index;
			}
		}
		else
		{
			GameStatus.currentLevel = 0;
			GameStatus.currentLevelName = levels[GameStatus.currentLevel];
		}
	}

	/** Game Management API **/
	public static function ToTitleScreen()
	{
		FlxG.switchState(new MenuState());
	}
	
	public static function StartGame()
	{
		FlxG.switchState(new PlayState(GameStatus.currentLevelName));
	}
	
	public static function OnDeath()
	{
		FlxG.switchState(new DeathState());
	}
	
	public static function OnLevelCompleted(notes : Array<String>)
	{
		FlxG.switchState(new PostLevelState(notes));
	}
	
	public static function NextLevel()
	{
		// Increase level
		GameStatus.currentLevel++;
		
		if (GameStatus.currentLevel >= levels.length)
		{
			trace("CONGRATULATIONS! A WINNER IS YOU!");
			
			ToTitleScreen();
		}
		else
		{
			GameStatus.currentLevelName = levels[GameStatus.currentLevel];
			
			FlxG.switchState(new PlayState(GameStatus.currentLevelName));
		}
	}
	
	private static function ParseArgs() {
		
		var args : Array<String> = Sys.args();
		trace(args);
		
		for (arg in args)
		{
			var comps : Array<String> = args[0].split("=");
			ParseArgument(comps[0], comps[1]);
		}
	}
	
	private static function ParseArgument(argument : String, value : String)
	{
		switch (argument)
		{
			case "level":
				GameStatus.currentLevelName = value;
			case "levels":		
				var inputLevels : Array<String> = value.split(",");
				if (inputLevels != null && inputLevels.length > 0)
					levels = inputLevels;
				else
					trace("Not using provided empty level list");
		}
	}
}
package;

import flixel.FlxG;

class GameController 
{
	public static function Init()
	{
		// What?
		GameStatus.currentLevel = "Outside";
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
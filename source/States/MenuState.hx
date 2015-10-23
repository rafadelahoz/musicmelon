package;

import flash.system.System;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.text.FlxBitmapTextField;
import flixel.system.scaleModes.PixelPerfectScaleMode;

import text.PixelText;

/**
 * The Main Menu State displays the title screen, and maybe some cute
 * animation and the obvious Press Start message
 */
class MenuState extends GameState
{
	var titleText : FlxBitmapTextField;
	var menuText : FlxBitmapTextField;
	
	var currentOption : Int;
	var options : Int;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		titleText = PixelText.New(16, 16, "- Depressed Music Melon -");
		add(titleText);
		
		menuText = PixelText.New(FlxG.width / 2 - 48, 2 * FlxG.height / 3, "( Press Start )");
		add(menuText);

		var fixedSM : flixel.system.scaleModes.PixelPerfectScaleMode = new PixelPerfectScaleMode();
		FlxG.scaleMode = fixedSM;
		
		GameController.Init();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();

		titleText = null;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		if (GamePad.justPressed(GamePad.Start) || GamePad.justPressed(GamePad.A))
			handleSelectedOption();
		else if (GamePad.justReleased(GamePad.Select))
			System.exit(0);
	}
	
	function handleSelectedOption()
	{
		GameController.StartGame();
	}
}
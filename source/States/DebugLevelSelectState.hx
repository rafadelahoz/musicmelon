package;

import flash.system.System;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxPoint;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.text.FlxBitmapTextField;
import flixel.system.scaleModes.PixelPerfectScaleMode;

import text.PixelText;

class DebugLevelSelectState extends GameState
{
	var titleText : FlxBitmapTextField;
	var menuText : FlxBitmapTextField;
	
	var currentOption : Int;
	var options : Array<String>;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		prepareOptions();
		
		menuText = PixelText.New(8, 16, "", 0xFFFFFFFF, FlxG.width);
		add(menuText);
		
		currentOption = 0;
		
		updateOptionsText();
		
		var titleTextBg : FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 12, 0xFF000000);
		titleTextBg.scrollFactor.set();
		add(titleTextBg);
		
		titleText = PixelText.New(0, 0, "- warp zone -", 0xFFFFFFFF, FlxG.width);
		titleText.scrollFactor.set();
		add(titleText);
		
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
		
		if (GamePad.justPressed(GamePad.Up))
		{
			currentOption -= 1;
			if (currentOption < 0)
				currentOption = options.length - 1;
		}
		else if (GamePad.justPressed(GamePad.Down))
		{
			currentOption = (currentOption+1) % options.length;
		}
		
		updateOptionsText();
		
		FlxG.camera.focusOn(new FlxPoint(FlxG.width/2, menuText.y + currentOption * 13));
		
		if (GamePad.justPressed(GamePad.Start) || GamePad.justPressed(GamePad.A))
			handleSelectedOption();
		else if (GamePad.justReleased(GamePad.Select))
			System.exit(0);
	}
	
	function handleSelectedOption()
	{
		switch (currentOption)
		{
			case 0:
				GameController.ToTitleScreen();
			case 1:
				GameController.StartGame();
			default:
				GameDebug.WarpToLevel(options[currentOption]);
		}
		
	}
	
	function prepareOptions()
	{
		options = ["To Title", "Start game"];

		var mapdir : String = "assets/maps";
		if (sys.FileSystem.exists(mapdir))
		{
			var contents : Array<String> = sys.FileSystem.readDirectory(mapdir);
			for (file in contents)
			{
				var extChar : Int = file.indexOf(".tmx");
				if (extChar > 0)
					options.push(file.substring(0, extChar));
			}
		}
	}
	
	function updateOptionsText()
	{
		var text : String = "";
		for (i in 0...options.length)
		{
			if (currentOption == i)
				text += "> ";
			else
				text += "  ";
				
			text += options[i] + "\n";
		}
		
		menuText.text = text;
	}
}
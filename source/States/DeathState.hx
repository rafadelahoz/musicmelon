package;

import flash.system.System;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxRandom;
import flixel.text.FlxText;
import flixel.text.FlxBitmapTextField;
import flixel.addons.effects.FlxGlitchSprite;

import text.PixelText;

/**
 * The Death State will be displayed after the player dies,
 * featuring the melon more depressed even and complaining
 * before restarting the level (or exiting?)
 */
class DeathState extends GameState
{
	var demotivator : FlxBitmapTextField;
	
	var currentOption : Int;
	var options : Int;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		FlxG.camera.bgColor = 0xFF004488;
		
		var message : String = getDemotivatorMessage();
		var msgWidth : Int = Std.int(Math.min(message.length * 8, FlxG.width - 16));
		
		demotivator = PixelText.New(FlxG.width / 2 - msgWidth / 2, 52, message, 0xFFFFFFFF, msgWidth);
		add(demotivator);
		
		// Hack-y, don't look!
		var melon : FlxSprite = new FlxSprite(FlxG.width / 2 - 8, 2 * FlxG.height/3);
		melon.loadGraphic("assets/images/melon_sheet.png", true, 16, 16);
		melon.animation.add("sad", [0, 4], 2, true);
		melon.animation.play("sad");
		add(melon);
		// add(new FlxGlitchSprite(melon, 1));
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		if (GamePad.justPressed(GamePad.Start) || GamePad.justPressed(GamePad.A))
			handleSelectedOption();
		else if (GamePad.justReleased(GamePad.Select))
			GameController.ToTitleScreen();
	}
	
	function handleSelectedOption()
	{
		GameController.StartGame();
	}
	
	function getDemotivatorMessage() : String
	{
		// TODO: Add more messages
		var messages = ["I will never make it", "I still don't have it", 
						"Why is it so hard", "I'm so tired of this", "Father was right",
						"Can't stand it any longer", "Is it really worth it?"];
						
		return FlxRandom.getObject(messages);
	}
}
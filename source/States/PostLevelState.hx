package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.text.FlxBitmapTextField;

import text.PixelText;

/**
 * The Post Level State will be displayed after the player
 * collects all the notes from a level, and will allow the player
 * to play (duh!) the collected notes before the next level
 */
class PostLevelState extends GameState
{
	var motivator : FlxBitmapTextField;
	
	var currentOption : Int;
	var options : Int;
	
	var notes : Array<String>;

	public function new(Notes : Array<String>)
	{
		super();
		
		notes = Notes;
	}
	
	override public function create():Void
	{
		super.create();
		
		FlxG.camera.bgColor = 0xFF000000;// 0xFF058E00;
		
		var background : FlxSprite = new FlxSprite(0, 0).loadGraphic("assets/images/win_background.png");
		add(background);
		
		var message : String = getMotivatorMessage();
		var msgWidth : Int = Std.int(Math.min(message.length * 8, FlxG.width - 16));
		
		motivator = PixelText.New(FlxG.width / 2 - msgWidth / 2, 52, message, 0xFFFFFFFF, msgWidth);
		add(motivator);
		
		// Hack-y, don't look!
		var melon : FlxSprite = new FlxSprite(FlxG.width / 2 - 8, 2 * FlxG.height/3);
		melon.loadGraphic("assets/images/melon_sheet.png", true, 16, 16);
		melon.animation.add("play", [0, 4], 4, true);
		melon.animation.play("play");
		add(melon);
		new FlxTimer(2, function(_t:FlxTimer) {
			melon.flipX = !melon.flipX;
		}, 0);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		if (GamePad.justPressed(GamePad.A) || GamePad.justPressed(GamePad.B)) 
		{
			// TODO: Play next note or something
			// Random for now
			FlxG.sound.play(FlxRandom.getObject(notes));
		}
		
		if (GamePad.justPressed(GamePad.Start))
			handleSelectedOption();
	}
	
	function handleSelectedOption()
	{
		GameController.NextLevel();
	}
	
	function getMotivatorMessage() : String
	{
		// TODO: Add more messages
		var messages = ["Not so bad I guess", "Well that's ok", "Could be better but...", "I kinda like this one", "Could be worse"];
						
		return FlxRandom.getObject(messages);
	}
}
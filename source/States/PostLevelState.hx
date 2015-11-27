package;

import flixel.FlxG;
import flixel.FlxObject;
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
	
	var melon : FlxSprite;
	var instrument : FlxSprite;
	
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
		var msgWidth : Int = Std.int(Math.min(message.length * 8, 144));
		
		motivator = PixelText.New(FlxG.width / 2 - msgWidth / 2, 52, message, 0xFFFFFFFF, msgWidth);
		add(motivator);
		
		// Hack-y, don't look!
		melon = new FlxSprite(FlxG.width / 2 - 8, 2 * FlxG.height/3);
		melon.loadGraphic("assets/images/melon_sheet.png", true, 16, 16);
		melon.animation.add("play", [0, 4], 4, true);
		melon.animation.play("play");
		add(melon);
		new FlxTimer(2, function(_t:FlxTimer) {
			melon.flipX = !melon.flipX;
		}, 0);
		
		instrument = new FlxSprite(melon.x, melon.y);
		instrument.loadGraphic("assets/images/melon_instrument.png", true, 16, 16);
		instrument.animation.add("play", [0, 1], 4, true);
		instrument.animation.play("play");
		instrument.solid = false;
		add(instrument);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		
		handleInstrument();
		
		if (GamePad.justPressed(GamePad.A) || GamePad.justPressed(GamePad.B)) 
		{
			// TODO: Play next note or something
			// Random for now
			playNote();
		}
		
		if (GamePad.justPressed(GamePad.Start))
			handleSelectedOption();
	}
	
	public function playNote() 
	{
		FlxG.sound.play(FlxRandom.getObject(notes));
		
		var xx : Float = melon.getMidpoint().x + (melon.flipX ? - instrument.width : 0);
		var yy : Float = melon.y+2;
		
		var note : FxPlayedNote = new FxPlayedNote(xx, yy, (melon.flipX ? FlxObject.LEFT : FlxObject.RIGHT));
		add(note);
	}
	
	public function handleInstrument()
	{
		instrument.x = melon.getMidpoint().x + (melon.flipX ? - instrument.width : 0);
		// instrument.y = melon.y - 2; // funny dance thing!
		instrument.y = melon.y + 2;
		instrument.flipX = melon.flipX;
		instrument.animation.play("play");
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
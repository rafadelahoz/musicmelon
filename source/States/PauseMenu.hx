package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.text.FlxBitmapTextField;
import flixel.util.FlxRandom;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import text.PixelText;

class PauseMenu extends FlxSubState
{
	var group : FlxSpriteGroup;
	var text : FlxBitmapTextField;
	var bg : FlxSprite;
	
	var notesLabel : FlxBitmapTextField;
	
	var currentOption : Int;
	var options : Array<String>;
	var optionsText : FlxBitmapTextField;
	
	var debugText : FlxBitmapTextField;
	
	var world : PlayState;
	
	public function new(World : PlayState)
	{
		super(0x00000000);
		
		world = World;
		world.onPause();
		
		group = new FlxSpriteGroup(0, 0);
		
		bg = new FlxSprite(56, FlxG.height/4).makeGraphic(FlxG.width - 112, 96, 0xFF000000);
		bg.scrollFactor.set();
		
		text = PixelText.New(FlxG.width / 2 - 56, bg.y + 8, "TAKE YOUR TIME");
		text.scrollFactor.set();
		
		var remaining : Int = world.levelNotes;
		var total : Int = remaining + world.collectedNotes.length;
		var collected : Int = total - remaining;
		
		var notesIcon : FlxSprite = new FlxSprite(64, text.y+18, "assets/images/small_note.png");
		notesIcon.scrollFactor.set();
		
		notesLabel = PixelText.New(notesIcon.x + notesIcon.width, text.y + 24, collected + "/"  + total);
		notesLabel.scrollFactor.set();
		
		optionsText = PixelText.New(64, notesLabel.y + 24, "", 0xFFFFFFFF, FlxG.width - 128);
		optionsText.scrollFactor.set();
		
		prepareOptions();
		
		currentOption = 0;
		
		debugText = PixelText.New(0, 0, "");
		debugText.scrollFactor.set();
		
		group.scrollFactor.set();
		
		group.add(bg);
		group.add(text);
		group.add(notesLabel);
		group.add(notesIcon);
		group.add(optionsText);
		group.add(debugText);
		
		add(group);
		
		FlxG.inputs.reset();
	}
	
	override public function close()
	{
		FlxG.inputs.reset();
		world.onUnpause();
		
		super.close();
	}
	
	override public function update()
	{
		GamePad.handlePadState();
		
		debugText.text = GamePad.buttonHistory.substring(GamePad.buttonHistory.length - 10);
		
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
		
		if (GamePad.justReleased(GamePad.A))
		{
			handleSelectedOption();
		}
		
		if (GamePad.justReleased(GamePad.Start))
		{
			close();
		}
	
		super.update();
	}
	
	function handleSelectedOption()
	{
		switch (currentOption)
		{
			case 0:
				close();
			case 1:
				GameController.RestartLevel();
			case 2:
				GameController.ToTitleScreen();
			default:
				
		}
		
	}
	
	function prepareOptions()
	{
		options = ["Continue", "Restart", "Give up"];
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
		
		optionsText.text = text;
	}
}

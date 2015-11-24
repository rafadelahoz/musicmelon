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
	
	var world : PlayState;
	
	public function new(World : PlayState)
	{
		super(0x00000000);
		
		world = World;
		world.onPause();
		
		group = new FlxSpriteGroup(0, 0);
		
		bg = new FlxSprite(FlxG.width/2-64, FlxG.height/2-12).makeGraphic(120, 24, 0xFF000000);
		bg.scrollFactor.set();
		
		text = PixelText.New(FlxG.width / 2 - 48, FlxG.height/2-4, " ~ PAUSED! ~ ");
		text.scrollFactor.set();
		
		group.scrollFactor.set();
		
		group.add(bg);
		group.add(text);
		
		add(group);
		
		FlxG.inputs.reset();
	}
	
	override public function close()
	{
		FlxG.inputs.reset();
		
		super.close();
	}
	
	override public function update()
	{
		GamePad.handlePadState();
		
		if (GamePad.justReleased(GamePad.Start))
		{
			world.onUnpause();
			close();
		}
	
		super.update();
	}
}

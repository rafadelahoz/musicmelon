package;

import flash.display.BitmapData;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxVirtualPad;
import flixel.ui.FlxButton;

@:bitmap("assets/images/ui/virtualpad/x.png")
private class GraphicX extends BitmapData {}

class GamePad
{
	public static var virtualPad : MultiVirtualPad = null;
	
	static var previousPadState : Map<Int, Bool>;
	static var currentPadState : Map<Int, Bool>;
	
	public static function setupVirtualPad() : Void
	{	
		virtualPad = new MultiVirtualPad();
		
		#if desktop
			virtualPad.alpha = 0.0;
		#else
			virtualPad.alpha = 0.65;
		#end
		

		setupVPButton(virtualPad.buttonRight);
		setupVPButton(virtualPad.buttonLeft);
		virtualPad.buttonLeft.x += 10;
		setupVPButton(virtualPad.buttonA);
		setupVPButton(virtualPad.buttonB);
		virtualPad.buttonB.x += 10;
		setupVPButton(virtualPad.buttonStart, true);
		
		initPadState();
	}
	
	public static function handlePadState() : Void
	{
		previousPadState = currentPadState;
		
		currentPadState = new Map<Int, Bool>();
		
		currentPadState.set(Left, 
			virtualPad.buttonLeft.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["LEFT"]));
		currentPadState.set(Right, 
			virtualPad.buttonRight.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["RIGHT"]));
		currentPadState.set(Up, 
			virtualPad.buttonUp.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["UP"]));
		currentPadState.set(Down, 
			virtualPad.buttonDown.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["DOWN"]));
			
		currentPadState.set(A, 
			virtualPad.buttonA.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["A", "Z"]));
		currentPadState.set(B, 
			virtualPad.buttonB.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["S", "X"]));
		
		currentPadState.set(Start, 
			virtualPad.buttonStart.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["ENTER"]));
		currentPadState.set(Select, 
			virtualPad.buttonSelect.status == FlxButton.PRESSED || FlxG.keys.anyPressed(["SPACE"]));
	}
	
	public static function checkButton(button : Int) : Bool
	{
		return currentPadState.get(button);
	}

	public static function justPressed(button : Int) : Bool
	{
		return currentPadState.get(button) && !previousPadState.get(button);
	}

	public static function justReleased(button : Int) : Bool
	{
		return !currentPadState.get(button) && previousPadState.get(button);
	}
	
	public static function resetInputs() : Void
	{
		initPadState();
	}

	private static function setupVPButton(button : FlxSprite, small : Bool = false) : Void
	{
		#if desktop
			button.x = -100;
			button.y = -100;
			button.scale.set(0, 0);
		#else
		if (!small)
		{
			button.scale.x = 0.5;
			button.scale.y = 0.5;
			button.width *= 0.5;
			button.height *= 0.5;
			button.updateHitbox();
			button.y += 17;
		}
		else
		{
			button.scale.x = 0.3;
			button.scale.y = 0.3;
			button.width *= 0.3;
			button.height *= 0.3;
			button.updateHitbox();
		}
		#end
	}
	
	private static function initPadState() : Void
	{
		currentPadState = new Map<Int, Bool>();
		currentPadState.set(Left, false);
		currentPadState.set(Right, false);
		currentPadState.set(Up, false);
		currentPadState.set(Down, false);
		currentPadState.set(A, false);
		currentPadState.set(B, false);
		currentPadState.set(Start, false);
		currentPadState.set(Select, false);

		previousPadState = new Map<Int, Bool>();
		previousPadState.set(Left, false);
		previousPadState.set(Right, false);
		previousPadState.set(Up, false);
		previousPadState.set(Down, false);
		previousPadState.set(A, false);
		previousPadState.set(B, false);
		previousPadState.set(Start, false);
		previousPadState.set(Select, false);
	}

	public static var Left 	: Int = 0;
	public static var Right : Int = 1;
	public static var Up	: Int = 2;
	public static var Down	: Int = 3;
	public static var A 	: Int = 4;
	public static var B 	: Int = 5;
	public static var Start : Int = 6;
	public static var Select : Int = 7;
}

class MultiVirtualPad extends FlxVirtualPad
{
	public var buttonStart : FlxButton;
	public var buttonSelect : FlxButton;

	public function new()
	{
		super(FULL, A_B);
		dPad.add(add(buttonStart = createButton(FlxG.width - 15, 3, 44, 45, GraphicX)));
		dPad.add(add(buttonSelect = createButton(FlxG.width - 15 - 30, 3, 44, 45, GraphicX)));
	}
	
	override public function destroy()
	{
		// haha nope
	}
}
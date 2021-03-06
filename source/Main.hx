package;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

import openfl.geom.Point;
import openfl.events.TouchEvent;

import flixel.FlxGame;
import flixel.FlxState;

class Main extends Sprite 
{
	var gameWidth:Int = 240; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 160; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = MenuState; // The FlxState the game starts with.
	var zoom:Float = 1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 50; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	
	// You can pretty much ignore everything from here on - your code should go in your states.
	
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		setupGame();
	}
	
	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		
		trace("Stage: " + stageWidth + ", " + stageHeight);
		trace("Game:  " + gameWidth + ", " + gameHeight + " @ " + zoom + "x");

		GameController.GameContainer = this;
		
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		addChild(gamepad = new MetaGamePad());
	
		addEventListener(Event.ENTER_FRAME, OnUpdate);
		
		#if (mobile || vpad)
		addEventListener(TouchEvent.TOUCH_BEGIN, OnTouchBegin);
		addEventListener(TouchEvent.TOUCH_MOVE, OnTouchMove);
		addEventListener(TouchEvent.TOUCH_END, OnTouchEnd);
		#end
	}
	
	public function OnResize(event : Event)
	{
		removeChild(gamepad);
		gamepad = new MetaGamePad();
		addChild(gamepad);
	}
	
	public function OnUpdate(event : Event) 
	{
		gamepad.handlePadState();
	}
	
	var gamepad : MetaGamePad;
	
	public function OnTouchBegin(event : TouchEvent)
	{
		gamepad.touchPoints.set(event.touchPointID, new Point(event.stageX, event.stageY));
	}
	
	public function OnTouchMove(event : TouchEvent)
	{
		gamepad.touchPoints.set(event.touchPointID, new Point(event.stageX, event.stageY));
	}
	
	public function OnTouchEnd(event : TouchEvent)
	{
		gamepad.touchPoints.remove(event.touchPointID);
	}
}
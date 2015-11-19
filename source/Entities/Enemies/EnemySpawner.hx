package;

import flixel.util.FlxPoint;
import flixel.util.FlxTimer;

class EnemySpawner extends Enemy
{
	public var spawnData : SpawnData;
	
	public var delay 	: Float = 1;
	public var idle		: Float = 0;
	
	public var timer : FlxTimer;
	
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
		
		timer = new FlxTimer();
		
		spawnData = {
			width : 0,
			height : 0,
			sprite : null,
			mask : null,
			fps : 0,
			facePlayer : false,
			flip : false,
			direction : 0,
			acceleration : 0,
			velocity : 0
		};
	}
	
	override public function init(Width : Int, Height : Int, ?Sprite : String = null, ?Mask : FlxPoint, ?FPS : Int = -1, ?FacePlayer : Bool = false, ?Flip : Bool = true)
	{
		spawnData.width = Width;
		spawnData.height = Height;
		spawnData.sprite = Sprite;
		spawnData.mask = Mask;
		spawnData.fps = FPS;
		spawnData.facePlayer = FacePlayer;
		spawnData.flip = Flip;
		
		/*makeGraphic(Width, Height, 0x00FFFFFF);
		setSize(Mask.x, Mask.y);
		centerOffsets(true);*/
		visible = false;
		
		// You are NOT collidable
		collideWithLevel = false;
		solid = false;
		
		// And delegate!
		onInit();
	}
	
	override public function onInit()
	{
		timer.start(idle, function(_t:FlxTimer) {
			timer.start(delay, onSpawn);
		});
	}
	
	public function setMotion(Direction : Int, Speed : Int, Acceleration : Int)
	{
		spawnData.direction = Direction;
		spawnData.velocity = Speed;
		spawnData.acceleration = Acceleration;
	}
	
	public function onSpawn(timer : FlxTimer)
	{
		// Spawn something
		var thing : EnemyDroplet = new EnemyDroplet(x, y, world);
		thing.setMotion(spawnData.direction, spawnData.velocity, spawnData.acceleration);
		thing.init(spawnData.width, spawnData.height, spawnData.sprite, spawnData.mask, spawnData.fps, spawnData.facePlayer, spawnData.flip);
		
		thing.color = color;
		
		world.enemies.add(thing);
	
		timer.start(delay, onSpawn);
	}
}

typedef SpawnData = {
	width : Int,
	height : Int,
	sprite : String,
	mask : FlxPoint,
	fps : Int,
	facePlayer : Bool,
	flip : Bool,
	direction : Int,
	acceleration : Int,
	velocity : Int
};
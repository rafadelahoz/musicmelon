package;

import flixel.FlxObject;
import flixel.util.FlxPoint;

/**
 * The Enemy class will be the base class for advanced enemies,
 * while containing common functionality.
 * It is also the idle enemy class.
 */
class Enemy extends Entity
{
	public static var B_IDLE 		: Int = 0;
	public static var B_WALK_DUMMY 	: Int = 1;
	public static var B_WALK_SMART  : Int = 2;
	public static var B_PATH		: Int = 3;
	public static var B_FLY			: Int = 4;
	public static var B_SPAWN		: Int = 5;
	// ...

	// Default frames-per-second for animation
	public static var DefaultFPS : Int = 5;

	// Current behaviour for the enemy
	public var behaviour : Int;

	// If true, the enemy will face the player (left or right)
	public var facePlayer : Bool;
	// If true, the enemy will face the direction it's moving
	public var flipOnMove : Bool;
	
	// Frames-per-second for the idle animation
	var fps : Int;

	/**
	 * Basic constructor, just position and world
	 */
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);
	}
	
	public var collideWithLevel : Bool;
	
	/**
	 * Initializes the enemy with the given parameters
	 * @param Width			Width of the enemy & enemy sprite
	 * @param Height 		Height of the enemy & enemy sprite
	 * @param Sprite		Filename (without path or extension) of the spritesheet for the enemy
	 * @param Mask			FlxPoint with (w, h) of collision mask. Will be centered on Width, Height
	 * @param FPS			Frames-per-second for the enemy animation
	 * @param FacePlayer	Whether the enemy shall always face the player or not
	 */
	public function init(Width : Int, Height : Int, ?Sprite : String = null, ?Mask : FlxPoint, ?FPS : Int = -1, ?FacePlayer : Bool = false, ?Flip : Bool = true)
	{
		// If no sprite is specified, just make a placeholder rectangle
		if (Sprite == null)
		{
			makeGraphic(Width, Height, 0xFFEB3BB7);
		}
		else
		// If a sprite is specified, use it!
		{
			// If no fps is provided, use the default
			fps = FPS;
			if (fps < 0)
				fps = DefaultFPS;
				
			// Load the specified spritesheet with the given width and height
			loadGraphic("assets/images/" + Sprite + ".png", true, Width, Height);

			if (Mask != null)
			{
				setSize(Mask.x, Mask.y);
				centerOffsets(true);
			}

			// Add the animation with the appropriate fps
			animation.add("idle", [0, 1], fps);
			// And play it
			animation.play("idle");
		}
		
		// Shall the enemy face the player?
		facePlayer = FacePlayer;
		
		// Or shall we flip when we move
		flipOnMove = Flip;
		
		// You are collidable
		collideWithLevel = true;
		
		// And delegate!
		onInit();
	}
	
	/**
	 * Override this with custom logic
	 */
	public function onInit()
	{
		// Override me!
	}

	override public function update()
	{
		// Face player flag processing
		if (facePlayer)
		{
			// Locate player position and look towards that
			if (player.getMidpoint().x < getMidpoint().x)
				facing = FlxObject.LEFT;
			else 
				facing = FlxObject.RIGHT;
				
			// Flip when looking left
			flipX = (facing == FlxObject.LEFT);
		}
	
		// Delegate!
		super.update();
	}
	
	/**
	 * Handles the collision against player event
	 */
	public function onCollisionWithPlayer(player : Player)
	{
		// Override me!
	}
	
	/**
	 * Handles the collision against world event
	 */
	public function onCollisionWithWorld(World : FlxObject)
	{
		// Override me!
	}
	
	/**
	 * Returns an updated reference to the current player
	 */
	public var player(get, null) : Player;
	function get_player() 
	{
		return world.player;
	}
}
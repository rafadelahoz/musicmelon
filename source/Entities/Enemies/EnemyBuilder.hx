package;

import flixel.FlxObject;
import flixel.util.FlxPoint;
import utils.tiled.TiledObject;
import utils.tiled.TiledObjectGroup;

/**
 * Handles the parsing of Enemies from map files
 **/
class EnemyBuilder
{
	public static function build(?g : TiledObjectGroup = null, o : TiledObject, X : Float, Y : Float, World : PlayState) : Enemy
	{
		var enemy : Enemy = null;
		
		// Fetch behaviour
		var behaviour : Int = EnemyBuilder.parseBehaviour(o);
		
		// Fetch properties
		var sprite 		: String	= EnemyBuilder.parseSprite(o);
		var mask 		: FlxPoint 	= EnemyBuilder.parseMask(o);
		var faceplayer 	: Bool 		= EnemyBuilder.parseFacePlayer(o);
		var fps 		: Int 		= EnemyBuilder.parseFPS(o);
		var flip		: Bool		= EnemyBuilder.parseFlip(o);
		var speed 		: Int		= EnemyBuilder.parseSpeed(o);
		var delay		: Float		= EnemyBuilder.parseDelay(o);
		var floaty		: Bool		= EnemyBuilder.parseFloaty(o);
		
		switch (behaviour)
		{
			case Enemy.B_IDLE:
				// Create the enemy
				enemy = new Enemy(X, Y, World);
			case Enemy.B_WALK_DUMMY, Enemy.B_WALK_SMART:
				// Create the enemy
				enemy = new EnemyWalker(X, Y, World, behaviour);
				// Setup speed
				if (speed > 0)
					cast(enemy, EnemyWalker).hspeed = speed;
			case Enemy.B_PATH:
				// Fetch path
				var path : Path = EnemyBuilder.generatePath(g, o);
				// Create the enemy
                enemy = new EnemyPathfinder(X, Y, World, behaviour, path);
				// Setup speed
				if (speed > 0)
					cast(enemy, EnemyPathfinder).Speed = speed;
			case Enemy.B_FLY:
				// Create the enemy
				enemy = new EnemyBurstFly(X, Y, World);
				// Setup speed
				if (speed > 0)
					cast(enemy, EnemyBurstFly).chargeSpeed = speed;
				// Setup delay
				if (delay > 0)
					cast(enemy, EnemyBurstFly).idleBaseTime = delay;
				// Setup floaty motion
				// cast(enemy, EnemyBurstFly).floaty = floaty;
			case Enemy.B_SPAWN:
				
				var accel : Int = EnemyBuilder.parseAccel(o);
				var direction : Int = EnemyBuilder.parseDirection(o);
				var offset : Float = EnemyBuilder.parseOffset(o);
				
				enemy = new EnemySpawner(X, Y, World);
				cast(enemy, EnemySpawner).setMotion(direction, speed, accel);
				cast(enemy, EnemySpawner).delay = delay;
				cast(enemy, EnemySpawner).idle = offset;
				
			default:
				trace("Creating not yet supported behaviour " + behaviour + ", defaulting to Idle");
				enemy = new Enemy(X, Y, World);
		}

		var colorStr : String = o.custom.get("color");
		if (colorStr != null)
		{
			if (colorStr.indexOf("0x") == -1)
				colorStr = "0x" + colorStr;
			var color : Int = Std.parseInt(colorStr);
			enemy.color = color;
		}
		
		// Initialize it with the read properties
		enemy.init(o.width, o.height, sprite, mask, fps, faceplayer, flip);
		
		return enemy;
	}

	public static function parseBehaviour(o : TiledObject) : Int
	{
		var behaviour : String = o.custom.get("behaviour");
		if (behaviour != null)
			behaviour = behaviour.toLowerCase();
		else
			behaviour = "null";
			
		switch (behaviour)
		{
			case "idle":
				return Enemy.B_IDLE;
			case "dummy":
				return Enemy.B_WALK_DUMMY;
			case "smart":
				return Enemy.B_WALK_SMART;
			case "path":
				return Enemy.B_PATH;
			case "fly":
				return Enemy.B_FLY;
			case "spawn":
				return Enemy.B_SPAWN;
			default:
				trace("Unrecognized behaviour found: " + behaviour);
				return Enemy.B_IDLE;
		}
	}

	public static function parseSprite(o : TiledObject) : String
	{
		var sprite : String = o.custom.get("sprite");
		return sprite;
	}
	
	public static function parseFPS(o : TiledObject) : Int
	{
		if (o.custom.contains("fps"))
		{
			return Std.parseInt(o.custom.get("fps"));
		}
		else
		{
			return Enemy.DefaultFPS;
		}
	}
	
	public static function parseSpeed(o : TiledObject) : Int
	{
		if (o.custom.contains("speed"))
		{
			return Std.parseInt(o.custom.get("speed"));
		}
		else
		{
			return -1;
		}
	}
	
	public static function parseAccel(o : TiledObject) : Int
	{
		if (o.custom.contains("accel"))
		{
			return Std.parseInt(o.custom.get("accel"));
		}
		else
		{
			return -1;
		}
	}
	
	public static function parseDirection(o : TiledObject) : Int
	{
		if (o.custom.contains("direction"))
		{
			switch (o.custom.get("direction").toLowerCase())
			{
				case "left":
					return FlxObject.LEFT;
				case "right":
					return FlxObject.RIGHT;
				case "up":
					return FlxObject.UP;
				case "down":
					return FlxObject.DOWN;
				default:
			}
		}
		
		return FlxObject.NONE;
	}
	
	public static function parseDelay(o : TiledObject) : Float
	{
		if (o.custom.contains("delay"))
		{
			return Std.parseFloat(o.custom.get("delay"));
		}
		else
		{
			return -1;
		}
	}
	
	public static function parseOffset(o : TiledObject) : Float
	{
		if (o.custom.contains("offset"))
		{
			return Std.parseFloat(o.custom.get("offset"));
		}
		else
		{
			return -1;
		}
	}
	
	public static function parseFloaty(o : TiledObject) : Bool
	{
		if (o.custom.contains("floaty"))
			return o.custom.get("floaty") == "true";
		else
			return false;
	}

	public static function parseMask(o : TiledObject) : FlxPoint
	{
		var maskStr : String = o.custom.get("mask");
		var mask : FlxPoint = null;
		if (maskStr != null)
		{
			var maskComps : Array<String> = maskStr.split(",");
			mask = FlxPoint.get(Std.parseInt(maskComps[0]), Std.parseInt(maskComps[1]));
		}
		
		return mask;
	}
	
	public static function parseFacePlayer(o : TiledObject) : Bool
	{
		return o.custom.contains("faceplayer") && o.custom.get("faceplayer") != "false";
	}
	
	public static function parseFlip(o : TiledObject) : Bool
	{
		return o.custom.contains("flip") && o.custom.get("flip") != "false";
	}
	
	public static function generatePath(g : TiledObjectGroup, o : TiledObject) : Path
	{
		var pathId      : String = EnemyBuilder.parsePath(o);
		var path        : Path = null;
		if (pathId != null) 
		{
			path = EnemyBuilder.buildPath(pathId, g);    
		}
		
		return path;
	}

	public static function parsePath(o : TiledObject) : String
	{
		return o.custom.get("path");
	}

	public static function buildPath(id : String, group : utils.tiled.TiledObjectGroup) : Path
	{
		var o : TiledObject = null;

		// Locate path by id on group
		for (obj in group.objects)
		{
			if (obj.type.toLowerCase() == "path" && obj.name == id)
			{
				o = obj;
				break;
			}
		}

		if (o == null) 
		{
			trace("Path " + id + " not found");
			return new Path("not found! (" + id + ")", new Array<FlxPoint>());
		}

		// Parse its nodes
		var x : Int = o.x;
		var y : Int = o.y;

		var points : Array<FlxPoint> = o.points;
		
		for (point in points)
			point.add(x, y);

		var path : Path = new Path(id, points);

		return path;
	}
}
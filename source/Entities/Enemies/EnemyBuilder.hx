package;

import flixel.util.FlxPoint;
import utils.tiled.TiledObject;
import utils.tiled.TiledObjectGroup;

/**
 * Handles the parsing of Enemies from map files
 **/
class EnemyBuilder
{
	public static function build(?g : TiledObjectGroup = null, o : TiledObject, X : Float, Y : Float, World : PlayState, Behaviour : Int) : Enemy
	{
		var enemy : Enemy = null;
		
		switch (Behaviour)
		{
			case Enemy.B_IDLE:
				enemy = new Enemy(X, Y, World);
			case Enemy.B_WALK_DUMMY, Enemy.B_WALK_SMART:
				enemy = new EnemyWalker(X, Y, World, Behaviour);
				if (o.custom.contains("speed"))
				{
					var speed : Int = Std.parseInt(o.custom.get("speed"));
					cast(enemy, EnemyWalker).hspeed = speed;
				}
			case Enemy.B_PATH:
				var pathId      : String = EnemyBuilder.parsePath(o);
				trace(pathId);
                var path        : Path = null;
                if (pathId != null) 
                {
                    path = EnemyBuilder.buildPath(pathId, g);    
                }

                enemy = new EnemyPathfinder(X, Y, World, Behaviour, path);

                if (o.custom.contains("speed"))
				{
					var speed : Int = Std.parseInt(o.custom.get("speed"));
					cast(enemy, EnemyPathfinder).Speed = speed;
				}

			default:
				trace("Creating not yet supported behaviour " + Behaviour + ", defaulting to Idle");
				enemy = new Enemy(X, Y, World);
		}
		
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

		trace("Path " + id +  " found! " + path);

		return path;
	}
}
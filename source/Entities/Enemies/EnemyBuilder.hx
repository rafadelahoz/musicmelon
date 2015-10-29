package;

import flixel.util.FlxPoint;
import utils.tiled.TiledObject;

/**
 * Handles the parsing of Enemies from map files
 **/
class EnemyBuilder
{
	public static function build(X : Float, Y : Float, World : PlayState, Behaviour : Int) : Enemy
	{
		var enemy : Enemy = null;
		
		switch (Behaviour)
		{
			case Enemy.B_IDLE:
				enemy = new Enemy(X, Y, World);
			case Enemy.B_WALK_DUMMY, Enemy.B_WALK_SMART:
				enemy = new EnemyWalker(X, Y, World, Behaviour);
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
		return o.custom.contains("faceplayer");
	}
}
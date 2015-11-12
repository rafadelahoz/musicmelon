package;

import flixel.util.FlxPath;

class EnemyPathfinder extends Enemy
{
	public var Speed : Int = 100;

	var path : FlxPath;
	var pathData : Path;

	public function new(X : Float, Y : Float, World : PlayState, Behaviour : Int, Path : Path)
	{
		super(X, Y, World);
		
		behaviour = Behaviour;
		pathData = Path;
		path = null;
	}
	
	override public function onInit()
	{
		// what
		if (pathData != null)
			path = new FlxPath(this, pathData.nodes, Speed, FlxPath.LOOP_FORWARD, false);
	}

	override public function update()
	{
		if (velocity.x != 0 || velocity.y != 0)
			flipX = (flipOnMove && velocity.x < 0);
		
		super.update();
	}
}
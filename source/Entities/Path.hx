package;

import flixel.util.FlxPoint;

class Path
{
	public var id : String;
	public var nodes : Array<FlxPoint>;

	public function new(Id : String, Nodes : Array<FlxPoint>)
	{
		id = Id;
		nodes = Nodes;
	}
}
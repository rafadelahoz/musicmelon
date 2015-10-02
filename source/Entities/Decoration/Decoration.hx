package;

import flixel.util.FlxRect;
import utils.tiled.TiledImage;

class Decoration extends Entity
{
	var movementRect : FlxRect;
	var collisionRect : FlxRect;
	
	public function new(X : Float, Y : Float, World : PlayState, Image : TiledImage)
	{
		// Correct by the offset
		super(X + Image.offsetX, Y + Image.offsetY, World);
		
		loadGraphic(Image.imagePath);
		setSize(Image.width, Image.height);
		offset.set(Image.offsetX, Image.offsetY);
		
		immovable = true;
	}
}
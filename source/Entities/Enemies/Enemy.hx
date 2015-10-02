package;

class Enemy extends Entity
{
	public function new(X : Float, Y : Float, World : PlayState)
	{
		super(X, Y, World);

		makeGraphic(16, 16, 0xFFEB3BB7);
	}

	public function onCollisionWithPlayer(player : Player)
	{
		// Override me!
	}
}
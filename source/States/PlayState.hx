package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.util.FlxPoint;

import text.TextBox;

using flixel.util.FlxSpriteUtil;

/**
 * GamePlay game state. Contains the player, the level, the enemies
 * and every other game play related entity.
 */
class PlayState extends GameState
{
    /* Level config */
    public var mapName : String;

    /* General elements */
    var camera : FlxCamera;

    /* Entities lists */
    public var player : Player;
    public var level : TiledLevel;
    public var oneways : FlxGroup;
    public var ladders : FlxGroup;
    public var enemies : FlxGroup;
    public var collectibles : FlxTypedGroup<Collectible>;
    public var decoration : FlxTypedGroup<Decoration>;

    // General entities list for pausing
    public var entities : FlxTypedGroup<Entity>;
	
	// Specific Foot enemies list for positioning
	public var feet : FlxTypedGroup<EnemyFoot>;
	
	// Game state variables
	public var levelNotes : Int;
	public var collectedNotes : Array<String>;

    /**
	 * Builds a new PlayState which will load the map file specified by name
	 */

    public function new( ?Level : String )
    {
        super( );

        if ( Level == null )
            Level = "" + GameStatus.currentLevel;

        mapName = Level;
    }

    /**
	 * Function that is called up when to state is created to set it up. 
	 */

    override public function create( ) : Void
    {
        // Random Background color
        FlxG.camera.bgColor = 0xFF202060;

        // Prepare state holders
        entities = new FlxTypedGroup<Entity>();
		
		// Prepare gameplay groups
        oneways = new FlxGroup();
        ladders = new FlxGroup();
        enemies = new FlxGroup();
        collectibles = new FlxTypedGroup<Collectible>();
        decoration = new FlxTypedGroup<Decoration>();
		
		feet = new FlxTypedGroup<EnemyFoot>();

		// Init game state
		levelNotes = 0;
		collectedNotes = new Array<String>();
		
        // Load the tiled level
        level = new TiledLevel("assets/maps/" + mapName + ".tmx");

        // Read level parameters
		// (...if any)
        FlxG.camera.bgColor = level.backgroundColor;

        // Add tilemaps
        add( level.backgroundTiles );

        // Load level objects
        level.loadObjects( this );

        add( enemies );
        add( oneways );
        add( collectibles );

        // Add overlay tiles
        add( level.overlayTiles );

        // Set the camera to follow the player
        FlxG.camera.follow( player, FlxCamera.STYLE_TOPDOWN, null, 0 );
		
        // Delegate
        super.create( );
    }

    /**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */

    override public function destroy( ) : Void
    {
        if ( player != null )
        {
            player.destroy( );
            player = null;
        }

        level.destroy( );
        level = null;

        oneways.destroy( );
        oneways = null;

        enemies.destroy( );
        enemies = null;

        decoration.destroy( );
        decoration = null;

        collectibles.destroy( );
        collectibles = null;

        super.destroy( );
    }

    /**
	 * Function that is called once every frame.
	 */

    override public function update( ) : Void
    {
        if ( GamePad.justReleased( GamePad.Start ) )
        {
            openSubState( new PauseMenu() );
        }

        // Enemies vs World
        resolveEnemiesWorldCollision( );

        // Enemies vs One way solids
        FlxG.collide( oneways, enemies, onEnemyWorldCollision );

        // Player vs World
        level.collideWithLevel( player );

        // Player vs One way solids
        FlxG.collide( oneways, player );

        // Player vs Ladders
        FlxG.overlap( ladders, player, onLadderCollision );

        // Player vs Collectibles
        FlxG.overlap( collectibles, player, onCollectibleCollision );

        // Player vs Enemies
        FlxG.overlap( enemies, player, onEnemyPlayerCollision );

        /* Update the GUI */
        // gui.updateGUI(icecream, this);

        /* Do the debug things */
        doDebug( );

        /* Go on */
        super.update( );
    }
	
    override public function draw( ) : Void
    {
        super.draw( );
    }

	/* Collision and Handlers */
	
    function resolveGroupWorldCollision( group : FlxGroup ) : Void
    {
        for ( element in group )
        {
            if ( Std.is( element, FlxGroup ) )
            {
                resolveGroupWorldCollision( cast(element, FlxGroup) );
            }
            else
            {
                level.collideWithLevel( cast element );
            }
        }
    }

    function resolveEnemiesWorldCollision( ) : Void
    {
        enemies.forEach( resolveEnemyWorldCollision );
    }

    function resolveEnemyWorldCollision( enemy : FlxBasic ) : Void
    {
        if ( (cast enemy).collideWithLevel )
        {
            level.collideWithLevel( (cast enemy), onEnemyWorldCollision );
        }
    }

    public function onEnemyPlayerCollision( one : Enemy, two : Player ) : Void
    {
        one.onCollisionWithPlayer( two );
        two.onCollisionWithEnemy( one );
    }

    public function onCollectibleCollision( collectible : Collectible, player : Player ) : Void
    {
        collectible.onCollisionWithPlayer( player );
        // Don't notify the player for now
    }
	
	public function onEnemyWorldCollision(level : FlxObject, enemy : FlxObject) : Void
	{
		(cast enemy).onCollisionWithWorld(level);
	}

    public function onLadderCollision( ladder : FlxObject, player : Player )
    {
        player.onCollisionWithLadder( ladder );
    }

	/* State handling */
	
    public function addPlayer( p : Player ) : Void
    {
        if ( player != null )
            player = null;

        player = p;
    }
	
	public function addNote(note : MusicNote)
	{
		levelNotes++;
		collectibles.add(note);
	}
	
	public function onNoteCollected(sfxPath : String)
	{
		collectedNotes.push(sfxPath);
	
		// Add foot, finish level...
		levelNotes--;
		if (levelNotes > 0)
		{
			// Wait before spawning? Fall directly?
			enemies.add(new EnemyFoot(0, 0, this, true));
		}
		else
		{
			GameController.OnLevelCompleted(collectedNotes);
		}
	}

    public function onPlayerDeath( )
    {
        // Fix the camera when player dies
        FlxG.camera.follow( null );
    }

	/* Debug utilities */
	
    function doDebug( ) : Void
    {
        var mousePos : FlxPoint = FlxG.mouse.getWorldPosition( );

        if ( FlxG.mouse.justPressed )
        {
			var enemy : EnemyBurstFly = new EnemyBurstFly(mousePos.x, mousePos.y, this);
			enemy.init(16, 16, "enemy_butterfly_sheet");
			enemies.add(enemy);
        }

		if (FlxG.keys.pressed.N)
		{
			GameController.NextLevel();
		}
		
        if ( FlxG.keys.pressed.O )
        {
            TextBox.Message( "NPC", "Are you here to steal our animals?" );
        }
    }
}
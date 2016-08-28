package;

import flash.geom.ColorTransform;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Material;
import GameMap;
import nape.phys.BodyType;

import GameMap;

class Railway extends FlxSprite
{
	public var map:GameMap;
	public var lastDirection:Int;
	public var direction:Int;
	public var previous:Railway = null;
	public var next:Railway = null;
	
	public function new(map:GameMap, previous:Railway, lastDirection:Int, direction:Int, X:Float, Y:Float, ?addToTileset:Bool=true)
	{	
		super(X, Y);
		
		this.previous = previous;
		this.map = map;
		if (addToTileset)
		{
			map.reserveTile(Std.int(X / GameMap.TILE_SIZE), Std.int(Y / GameMap.TILE_SIZE), direction);
		}
		
		if (previous != null)
		{
			previous.next = this;
		}
		
		setDirection(lastDirection, direction);
	}
	
	public function setDirection(lastDirection:Int, direction:Int)
	{
		var curved = lastDirection != Direction.NONE && lastDirection != direction;
		this.direction = direction;
		this.lastDirection = lastDirection;
		
		if (!curved)
		{
			if (direction == Direction.NORTH || direction == Direction.SOUTH)
			{
				loadGraphic("assets/images/raiways/railway.png");
			}
			else
			{
				loadGraphic("assets/images/raiways/horizontal-railway.png");
			}
		}
		else
		{
			loadGraphic("assets/images/raiways/Curved Railway.png");
			
			if (lastDirection == Direction.NORTH && direction == Direction.EAST)
			{}
			else if (lastDirection == Direction.NORTH && direction == Direction.WEST)
			{
				angle = 90;
			}
			else if (lastDirection == Direction.EAST && direction == Direction.NORTH)
			{
				angle = 180;
			}
			else if (lastDirection == Direction.EAST && direction == Direction.SOUTH)
			{
				angle = 90;
			}
			else if (lastDirection == Direction.WEST && direction == Direction.NORTH)
			{
				angle = -90;
			}
			else if (lastDirection == Direction.WEST && direction == Direction.SOUTH)
			{}
			else if (lastDirection == Direction.SOUTH && direction == Direction.EAST)
			{
				angle = -90;
			}
			else if (lastDirection == Direction.SOUTH && direction == Direction.WEST)
			{
				angle = -180;
			}
		}
	}
	
	public function inverse()
	{
		var curved = lastDirection != Direction.NONE && lastDirection != direction;
		if (!curved)
		{
			direction = map.directionInverse(direction);
		}
		else
		{
			var temp = direction;
			direction = map.directionInverse(lastDirection);
			lastDirection = map.directionInverse(temp);
		}
		
		reserveNow();
	}
	
	public function reserveNow()
	{
		trace("Placed from " + lastDirection + " to " + direction);
		map.reserveTile(Std.int(x / GameMap.TILE_SIZE), Std.int(y / GameMap.TILE_SIZE), direction);
	}
	
	override public function update(elapsed:Float):Void
	{
		if (this == map.lastRail)
		{
			this.colorTransform = new ColorTransform(0.7, 1, 0.7);
		}
		else
		{
			this.colorTransform = new ColorTransform();
		}
		
		super.update(elapsed);
	}
}
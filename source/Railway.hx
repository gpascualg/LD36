package;

import flash.geom.ColorTransform;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
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
	public var curved:Bool = false;
	
	public var tx:Int;
	public var ty:Int;
	
	
	public function new(map:GameMap, previous:Railway, lastDirection:Int, direction:Int, X:Float, Y:Float)
	{	
		super(X, Y);
		
		this.previous = previous;
		this.map = map;
		
		if (previous != null)
		{
			previous.next = this;
		}
		
		updateTile();
		setDirection(lastDirection, direction);
	}
	
	public function updateTile()
	{
		tx = Std.int(x / GameMap.TILE_SIZE);
		ty = Std.int(y / GameMap.TILE_SIZE);
	}
	
	public function setDirection(lastDirection:Int, direction:Int)
	{
		curved = lastDirection != Direction.NONE && lastDirection != direction;
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
	
	public function nextDirection(from:Int):Int
	{
		if (!curved)
		{
			if (from == direction || map.directionInverse(from) == direction)
			{
				return from;
			}
			
			return direction;
		}
		
		if (from == lastDirection)
		{
			return direction;
		}
		
		if (from == direction)
		{
			return direction;
		}
		
		if (from == map.directionInverse(lastDirection))
		{
			return direction;
		}
			
		if (from == map.directionInverse(direction))
		{
			return map.directionInverse(lastDirection);
		}
			
		trace("?????");
		return -1;
	}
	
	public function nextRail(from:Int):Railway
	{
		switch (nextDirection(from))
		{
			case Direction.NORTH: return map.getRailAt(tx, ty - 1);
			case Direction.SOUTH: return map.getRailAt(tx, ty + 1);
			case Direction.EAST: return map.getRailAt(tx + 1, ty);
			case Direction.WEST: return map.getRailAt(tx - 1, ty);
		}
		
		return null;
	}
	
	public function nextRails(last:Int, canEndInCurve:Bool):Array<Railway>
	{
		var nextArray:Array<Railway> = new Array<Railway>();
		
		var realNext:Int = -1;
		var next = last;
		var prev = null;
		var current = this;
		var railAcc = 0;
		while (current != null)
		{
			nextArray.push(current);
			
			prev = current;
			last = next;
			next = current.nextDirection(last);							
			current = current.nextRail(last);
			
			if (current != null && current == this)
			{
				++railAcc;
				if (railAcc == 2)
				{
					break;
				}
			}
		}
		
		if (!canEndInCurve && nextArray.length > 0)
		{			
			var rail = nextArray[nextArray.length - 1];
			if (rail.lastDirection != rail.direction)
			{			
				var dx = next == Direction.EAST ? 1 : (next == Direction.WEST ? -1 : 0);
				var dy = next == Direction.SOUTH ? 1 : (next == Direction.NORTH ? -1 : 0);
				
				trace('TRYING TO FIX LAST CURVE AT ' + new FlxPoint(rail.tx + dx, rail.ty + dy) + ' FROM ' + new FlxPoint(rail.tx, rail.ty));
				trace(last + ' ' + next + ' ' + rail.direction);
				
				var newRail = new Railway(map, rail, next, next, (rail.tx + dx) * GameMap.TILE_SIZE, (rail.ty + dy) * GameMap.TILE_SIZE);
				map.placeRailAt(newRail, rail.tx + dx, rail.ty + dy);
				nextArray.push(newRail);
			}
		}
		
		return nextArray;
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
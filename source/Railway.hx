package;

import flash.geom.ColorTransform;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import GameMap;

import GameMap;


class RailCombo
{
	public var railway:Railway;
	public var direction:Int;
	
	public function new(r:Railway, d:Int)
	{
		railway = r;
		direction = d;
	}
}

class RailInfo
{
	public var railCombo:Array<RailCombo>;
	public var isLoop:Bool;
	
	public function new(r:Array<RailCombo>, l:Bool)
	{
		railCombo = r;
		isLoop = l;
	}
}


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
	
	public function previousDirection(from:Int):Int
	{
		if (!curved)
		{
			if (from == direction || map.directionInverse(from) == direction)
			{
				return map.directionInverse(from);
			}
			
			return direction;
		}
		
		if (from == lastDirection)
		{
			trace("CASE 1 " + from + " to " + map.directionInverse(lastDirection));
			return map.directionInverse(lastDirection);
		}
		
		if (from == direction)
		{
			trace("CASE 2 " + from + " to " + map.directionInverse(lastDirection));
			return map.directionInverse(lastDirection);
		}
		
		if (from == map.directionInverse(lastDirection))
		{
			trace("CASE 3 " + from + " to " + map.directionInverse(lastDirection));
			return map.directionInverse(lastDirection);
		}
			
		if (from == map.directionInverse(direction))
		{
			trace("CASE 3 " + from + " to " + lastDirection);
			return lastDirection;
		}
			
		trace("?????");
		return -1;
	}
	
	public function previousRail(from:Int):Railway
	{
		switch (previousDirection(from))
		{
			case Direction.NORTH: return map.getRailAt(tx, ty - 1);
			case Direction.SOUTH: return map.getRailAt(tx, ty + 1);
			case Direction.EAST: return map.getRailAt(tx + 1, ty);
			case Direction.WEST: return map.getRailAt(tx - 1, ty);
		}
		
		return null;
	}
	
	public function nextRails(last:Int, canEndInCurve:Bool):RailInfo
	{
		var info:RailInfo = new RailInfo(new Array<RailCombo>(), false);
		
		var realNext:Int = -1;
		var next = last;
		var prev = null;
		var current = this;
		var railAcc = 0;
		
		while (current != null)
		{
			// Check for it
			for (combo in info.railCombo)
			{
				if (combo.railway == current)
				{
					info.isLoop = true;
					break;
				}
			}
			
			if (info.isLoop)
			{
				break;
			}
			
			info.railCombo.push(new RailCombo(current, next));
			
			prev = current;
			last = next;
			next = current.nextDirection(last);							
			current = current.nextRail(last);
		}
		
		if (!canEndInCurve && info.railCombo.length > 0)
		{			
			var rail = info.railCombo[info.railCombo.length - 1].railway;
			if (rail.lastDirection != rail.direction)
			{			
				var dx = next == Direction.EAST ? 1 : (next == Direction.WEST ? -1 : 0);
				var dy = next == Direction.SOUTH ? 1 : (next == Direction.NORTH ? -1 : 0);
				
				trace('TRYING TO FIX LAST CURVE AT ' + new FlxPoint(rail.tx + dx, rail.ty + dy) + ' FROM ' + new FlxPoint(rail.tx, rail.ty));
				trace(last + ' ' + next + ' ' + rail.direction);
				
				var newRail = new Railway(map, rail, next, next, (rail.tx + dx) * GameMap.TILE_SIZE, (rail.ty + dy) * GameMap.TILE_SIZE);
				map.placeRailAt(newRail, rail.tx + dx, rail.ty + dy);
				info.railCombo.push(new RailCombo(newRail, next));
			}
		}
		
		return info;
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
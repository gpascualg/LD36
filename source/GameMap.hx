package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import openfl.display.FPS;
import flixel.util.FlxSpriteUtil;
import Barrel;
import Gem;
import Railway;
import openfl.utils.Object;

/**
 * ...
 * @author j
 */
class GameMap
{
	public static inline var PREBUILD_RAILS_MAX:Int = 5; // 5
	public static inline var TILE_SIZE:Int = 32;
	private var background:FlxTilemap;
	
	public var foreground:FlxTilemap;
	public var shadowCanvas:FlxSprite;
	public var shadowOverlay:FlxSprite;
	
	public var mapData:Array<Int>;
	
	private var _parent:FlxState;
	private var _loco:Loco;
	
	public var inverted:Bool = false;
	public var startPoint:FlxPoint;
	public var endPoint:FlxPoint;
	public var gem:Gem;
	
	public var hasGeneratedPath:Bool;
	
	public var lastRail:Railway = null;
	public var lastDirection:Int = -1;
	public var gems:FlxTypedGroup<Gem>;
	public var obstacles:Map<Int, Barrel> = null;
	
	public var mirrors:Array<Array<Mirror>>;
	
	private var rails:FlxTypedGroup<Railway>;
	private var railsByIndex:Array<Array<Railway>>;
	
	public function new(parent:FlxState)
	{
		_parent = parent;
		var background:FlxTilemap = new FlxTilemap();
		background.loadMapFromCSV("assets/data/background.txt",
			"assets/images/tiles.png", TILE_SIZE, TILE_SIZE, null, 1, 1);
		_parent.add(background);
		
		shadowCanvas = new FlxSprite();
		shadowCanvas.blend = BlendMode.MULTIPLY;
		shadowCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		//_parent.add(shadowCanvas);
		
		foreground = new FlxTilemap();
		mapData = new Array<Int>();
		
		foreground.loadMapFromCSV("assets/data/foreground.txt",
			"assets/images/tiles.png", TILE_SIZE, TILE_SIZE, null, 1, 1);
		
		_parent.add(foreground);
		
		shadowOverlay = new FlxSprite();
		shadowOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		shadowOverlay.blend = BlendMode.MULTIPLY;
		//_parent.add(shadowOverlay);
		
		rails = new FlxTypedGroup<Railway>();
		parent.add(rails);
		gems = new FlxTypedGroup<Gem>();
		parent.add(gems);
		
		// Setup mirrors array
		buildMirrors();
	}
	
	public function loadTutorial(loco:Loco, phase:Int)
	{
		// All obstacles out
		for (key in obstacles.keys())
		{
			obstacles[key].destroy();
			obstacles.remove(key);
		}
		
		// All railways out
		for (rail in rails)
		{
			rails.remove(rail);
		}
		
		// Generate map
		var rail = null;
		for (y in 1...(foreground.heightInTiles - 1))
		{
			for (x in 1...(foreground.widthInTiles - 1))
			{
				railsByIndex[y][x] = null;
				
				if (y < foreground.heightInTiles / 2)
				{
					foreground.setTile(x, y, 4);
				}
				else if (y == foreground.heightInTiles - 5 && x > foreground.widthInTiles / 2 - 8 && x < foreground.widthInTiles / 2 + 8)
				{
					rail = new Railway(this, rail, Direction.EAST, Direction.EAST, x * GameMap.TILE_SIZE, y * GameMap.TILE_SIZE);
					placeRailAt(rail, x, y);
				}
				else if (y == foreground.heightInTiles - 4 && x > foreground.widthInTiles / 2 - 8 && x < foreground.widthInTiles / 2 + 8)
				{
					foreground.setTile(x, y, 4);
				}
				else
				{
					foreground.setTile(x, y, 0);
				}
			}
		}
		
		for (gem in gems)
		{
			gem.x = (foreground.widthInTiles / 2) * GameMap.TILE_SIZE;
			gem.y = (foreground.heightInTiles - 3) * GameMap.TILE_SIZE;
		}
		
		var wagon:Wagon = loco;
		while (wagon != null)
		{
			wagon.x = (foreground.widthInTiles / 2 - 1) * GameMap.TILE_SIZE;
			wagon.y = (foreground.heightInTiles - 5) * GameMap.TILE_SIZE;
			wagon = wagon.next;
		}
	}
	
	public function createRandomPath(lightSources:FlxTypedGroup<LightSource>, canvas:FlxSprite, loco:Loco, ?startPoint:FlxPoint=null, ?invert:Bool=false):Void
	{	
		// Save loco
		if (loco != null)
		{
			_loco = loco;
		}
		
		// Empty map
		if (obstacles != null)
		{
			for (key in obstacles.keys())
			{
				var obstacle = obstacles[key];
				obstacles.remove(key);
				
				var tx = Std.int(obstacle.x / GameMap.TILE_SIZE);
				var ty = Std.int(obstacle.y / GameMap.TILE_SIZE);
				reserveTile(tx, ty, 0);
				obstacle.destroy();
			}
		}
		
		// Keep last chunks
		_loco._current = _loco._current == null ? _loco._previous : _loco._current;
		_loco._first = _loco._current == null;
		var currentWagon:Wagon = _loco;
		while (currentWagon.next != null)
		{
			currentWagon = currentWagon.next;
		}
		
		// TODO: Check isLoop
		var nextRails:Array<RailCombo> = currentWagon.nextRails(false).railCombo;
		var keepRails:Array<Railway> = [];
		for (rail in nextRails)
		{
			keepRails.push(rail.railway);
		}
		
		trace(keepRails);
		trace(keepRails.length);
		
		// Clear rails
		for (rail in rails)
		{
			// Clear tile only if not keeping
			if (keepRails.indexOf(rail) < 0)
			{			
				var tx = Std.int(rail.x / GameMap.TILE_SIZE);
				var ty = Std.int(rail.y / GameMap.TILE_SIZE);
				
				// Clear
				var tileIdx = foreground.getTile(tx, ty);
				if (tileIdx >= 50)
				{
					reserveTile(tx, ty, 0);
				}
			}
			
			// Remove
			rails.remove(rail);
		}
				
		//Declare the obstacles array
		obstacles = new Map<Int, Barrel>();
		inverted = invert;
		
		//Start point
		var xStart:Int = 1 + Std.int(Std.random(3));
		var yStart:Int = Std.random(foreground.heightInTiles - 4) + 2;
		
		//End Point
		var xEnd:Int = foreground.widthInTiles - 2 - Std.int(Std.random(3));
		var yEnd:Int = Std.int(Std.random(foreground.heightInTiles - 4) + 2);
		
		if (invert)
		{
			var temp = xStart;
			xStart = xEnd;
			xEnd = temp;
			
			temp = yStart;
			yStart = yEnd;
			yEnd = temp;
		}
		
		// Overwrite if given
		if (startPoint != null)
		{
			xStart = Std.int(startPoint.x);
			yStart = Std.int(startPoint.y);
		}
		
		var path:Array<Array<Int>> = new Array<Array<Int>>();
		railsByIndex = new Array<Array<Railway>>();
		for (ty in 0...foreground.heightInTiles)
		{
			var arr1 = new Array<Int>();
			var arr2 = new Array<Railway>();
			
			for (tx in 0...foreground.widthInTiles)
			{
				arr1.push(0);
				arr2.push(null);
				
				// Clear
				var tileIdx = foreground.getTile(tx, ty);
				if (tileIdx < 0)
				{
					reserveTile(tx, ty, 0);
				}
			}
			
			path.push(arr1);
			railsByIndex.push(arr2);
		}
		path[yEnd][xEnd] = -2;
		
		// Set start & end point
		setStartPoint(xStart, yStart);
		setEndPoint(xEnd, yEnd);
				
		//Calculate the path & clear foreground from obstacles / custom ids
		var x:Int = xStart;
		var y:Int = yStart;
		var actualDirection:Int = chooseRandomDirection(x, y);
		
		trace("Start: " + new FlxPoint(xStart, yStart));
		trace("End: " + new FlxPoint(xEnd, yEnd));
		
		hasGeneratedPath = false;
		while (!hasGeneratedPath)
		{
			//We have ended
			if (foreground.getTile(x, y) == -2){
				hasGeneratedPath = true;
				continue;
			}
			
			var desiredX:Int = x;
			var desiredY:Int = y;
			
			// Does this tile already have a rail? (force direction)
			var currentIdx = foreground.getTile(x, y);
			if (currentIdx >= 50)
			{
				path[y][x] = currentIdx;
				
				switch (currentIdx) 
				{
					case Direction.WEST: --x;
					case Direction.EAST: ++x;
					case Direction.NORTH: --y;
					case Direction.SOUTH: ++y;						
				}
				
				continue;
			}
			//trace("NOT Forcing: " + new FlxPoint(x, y) + " " + currentIdx);
		
			path[desiredY][desiredX] = actualDirection;
			if (Math.random() > 0.7)
			{
				actualDirection = chooseRandomDirection(x, y);
				continue;
			}

			switch(actualDirection){
				case Direction.WEST:
					desiredX--;
					if (desiredX == 0){
						actualDirection = chooseRandomDirection(x, y);
						continue;
					}
				case Direction.EAST:
					desiredX++;
					if (desiredX == foreground.widthInTiles - 1){
						actualDirection = chooseRandomDirection(x, y);
						continue;
					}
				case Direction.NORTH:
					desiredY--;
					if (desiredY == 0){
						actualDirection = chooseRandomDirection(x, y);
						continue;
					}
				case Direction.SOUTH:
					desiredY++;
					if (desiredY == foreground.heightInTiles - 1){
						actualDirection = chooseRandomDirection(x, y);
						continue;
					}
				case Direction.NONE:
					// NOOOO;
			}
			
			x = desiredX;
			y = desiredY;
		}
				
		// Add railways
		x = xStart;
		y = yStart;
		var lastDirection:Int = -1;
		var direction:Int = -1;
		var numberOfRails = 0;
		
		while (true)
		{
			direction = path[y][x];
			//trace((new FlxPoint(x, y)) + " " + direction);
			
			if (direction == -2)
			{
				if (numberOfRails < PREBUILD_RAILS_MAX)
				{
					//lastRail = new Railway(this, lastRail, lastDirection, lastDirection, x * GameMap.TILE_SIZE, y * GameMap.TILE_SIZE);
					//placeRailAt(lastRail, x, y);
				}
				
				break;
			}
			
			if (numberOfRails < Math.max(PREBUILD_RAILS_MAX, keepRails.length))
			{
				trace('Rail at: ' + new FlxPoint(x, y) + ' ' + lastDirection + ' -> ' + direction);
				lastRail = new Railway(this, lastRail, lastDirection, direction, x * GameMap.TILE_SIZE, y * GameMap.TILE_SIZE);
				placeRailAt(lastRail, x, y);
				lastDirection = direction;
			}
			else
			{
				reserveTile(x, y);
			}
						
			switch(direction) {
				case Direction.WEST:
					--x;
				case Direction.EAST:
					++x;
				case Direction.NORTH:
					--y;
				case Direction.SOUTH:
					++y;
					
				default:
					break;
					// NOOOO;
			}
			++numberOfRails;
		}
				
		// Flag start surroundings
		for (x in -1...2)
		{
			for (y in -1...2)
			{
				if (x == 0 && y == 0)
				{
					continue;
				}
				
				var cx = xStart + x;
				var cy = yStart + y;
				
				if (cx > 0 && cy > 0 && cx < foreground.widthInTiles - 1 && cy < foreground.heightInTiles - 1 && 
					foreground.getTile(cx, cy) == 0)
				{
					reserveTile(cx, cy, -1);
				}
			}
		}
		
		// Flag end surroundings
		for (x in -1...2)
		{
			for (y in -1...2)
			{
				if (x == 0 && y == 0)
				{
					continue;
				}
				
				var cx = xEnd + x;
				var cy = yEnd + y;
				
				if (cx > 0 && cy > 0 && cx < foreground.widthInTiles - 1 && cy < foreground.heightInTiles - 1 && 
					foreground.getTile(cx, cy) == 0)
				{
					trace("Reserve " + new FlxPoint(cx, cy));
					reserveTile(cx, cy, -1);
				}
			}
		}

		//Fill the map with random noise ensuring that the path is respected
		var acc = 0.7;
		for (tileY in 0...foreground.heightInTiles)
		{
			for (tileX in 0...foreground.widthInTiles)
			{
				var x = tileX; // + Std.random(3) - 1;
				var y = tileY; // + Std.random(3) - 1;
				
				var tileIndex = foreground.getTile(x, y);				
				var xPos:Float = x * TILE_SIZE;
				var yPos:Float = y * TILE_SIZE;
				
				//Render an obstacle
				if (tileIndex >= 0 && tileIndex < 50 && tileIndex != 4 && Math.random() > acc)
				{
					var barr:Barrel = new Barrel(xPos, yPos);
					obstacles[y * foreground.widthInTiles + x] = barr;
					_parent.add(barr);
					foreground.setTile(x, y, Prop.BARREL);
					
					if (acc > 0.5)
					{
						acc -= Math.random() / 4.0;
					}
				}
				else
				{
					acc = 0.7;
				}
			}
		}
		
		// Gem on endPoint
		var gem = new Gem(this, lightSources, canvas, endPoint.x * GameMap.TILE_SIZE, endPoint.y * GameMap.TILE_SIZE);
		gems.add(gem);
	}
	
	private function cleanMap()
	{
		for (tileY in 1...foreground.heightInTiles -1)
		{
			for (tileX in 1...foreground.widthInTiles -1)
			{
				foreground.setTile(tileX, tileY, 0);
			}
		}
	}
	
	public function getLastDirection()
	{
		if (lastDirection == -1)
		{
			return lastRail.direction;
		}
		
		return lastRail.nextDirection(lastDirection);
	}
	
	public function setLastRail(rail:Railway, ?direction:Int=-1)
	{
		lastRail = rail;
		lastDirection = direction;
	}
	
	public function placeRailAt(rail:Railway, x:Int, y:Int)
	{
		if (railsByIndex[y][x] != null)
		{
			rails.remove(railsByIndex[y][x]);
		}
		
		railsByIndex[y][x] = rail;
		setLastRail(rail);
		reserveTile(x, y, rail.direction);
		rails.add(rail);
	}
	
	public function removeRailAt(x:Int, y:Int)
	{
		if (railsByIndex[y][x] != null)
		{
			rails.remove(railsByIndex[y][x]);
		}
		
		railsByIndex[y][x] = null;
	}
	
	public function getRailAt(x:Int, y:Int):Railway
	{
		return railsByIndex[y][x];
	}
	
	public function tempRailPlace(rail:Railway)
	{
		rails.add(rail);
	}
	
	public function tempRailRemove(rail:Railway)
	{
		rails.remove(rail);
	}
	
	public function directionInverse(d:Int)
	{
		switch (d) 
		{
			case Direction.NORTH: return Direction.SOUTH;
			case Direction.SOUTH: return Direction.NORTH;
			case Direction.EAST: return Direction.WEST;
			case Direction.WEST: return Direction.EAST;				
		}
		
		return Direction.NONE;
	}
	
	private function chooseRandomDirection(x:Int, y:Int):Direction
	{
		var allowedDirs:Array<Direction> = new Array<Direction>();
		
		if (x != 0)
			allowedDirs.push(Direction.WEST);
		if (x != foreground.widthInTiles - 1)
			allowedDirs.push(Direction.EAST);
		if (y != 0)
			allowedDirs.push(Direction.NORTH);
		if (y != foreground.heightInTiles - 1)
			allowedDirs.push(Direction.SOUTH);
		
		var dir:Direction = cast(Std.int((Math.floor(Math.random() * (allowedDirs.length - 0 + 1)) + 0)), Direction);
		return allowedDirs[dir];
	}
	
	private function cleanTile(x:Int, y:Int):Void
	{
		//foreground.setTile(x, y, 0);
	}
	
	public function reserveTile(x:Int, y:Int, ?direction:Int=-1):Void
	{
		foreground.setTile(x, y, direction);
	}
	
	private function setEndPoint(x:Int, y:Int){
		endPoint = new FlxPoint(x, y);
		foreground.setTile(x, y, -2);
	}
	
	private function setStartPoint(x:Int, y:Int){
		startPoint = new FlxPoint(x, y);
		//foreground.setTile(x, y, -3);
	}
	
	private function buildMirrors():Void {
		mirrors = new Array<Array<Mirror>>();
		
		for (y in 0...foreground.heightInTiles)
		{
			var arr = new Array<Mirror>();
			
			for (x in 0...foreground.widthInTiles)
			{
				arr.push(null);
			}
			
			mirrors.push(arr);
		}
	}
}

@:enum
abstract Prop(Int) to Int
{
	var BARREL = 5;
	var GEM = 6;
}

@:enum
abstract Direction(Int) to Int
{
	var NONE = -1;
	var NORTH = 50;
	var EAST = 51;
	var SOUTH = 52;
	var WEST = 53;
}


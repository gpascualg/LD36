package;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Body;
import openfl.display.BlendMode;
import openfl.display.FPS;
import flixel.util.FlxSpriteUtil;
import Barrel;
import Gem;
import openfl.utils.Object;

/**
 * ...
 * @author j
 */
class GameMap
{
	public static inline var PREBUILD_RAILS_MAX:Int = 5;
	public static inline var TILE_SIZE:Int = 32;
	private var background:FlxTilemap;
	
	public var foreground:FlxNapeTilemap;
	public var shadowCanvas:FlxSprite;
	public var shadowOverlay:FlxSprite;
	
	public var mapData:Array<Int>;
	
	private var _parent:FlxState;
	
	public var startPoint:FlxPoint;
	public var endPoint:FlxPoint;
	public var gem:Gem;
	
	public var hasGeneratedPath:Bool;
	
	public var lastRail:Railway = null;
	public var rails:FlxTypedGroup<Railway>;
	public var gems:FlxTypedGroup<Gem>;
	public var obstacles:Map<Int, Barrel>;
	
	public var mirrors:Array<Array<Mirror>>;
	
	
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
		_parent.add(shadowCanvas);
		
		foreground = new FlxNapeTilemap();
		mapData = new Array<Int>();
		
		foreground.loadMapFromCSV("assets/data/foreground.txt",
			"assets/images/tiles.png", TILE_SIZE, TILE_SIZE, null, 1, 1);
		
		_parent.add(foreground);
		
		shadowOverlay = new FlxSprite();
		shadowOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		shadowOverlay.blend = BlendMode.MULTIPLY;
		_parent.add(shadowOverlay);
		
		foreground.setupTileIndices([4]);
		rails = new FlxTypedGroup<Railway>();
		parent.add(rails);
		gems = new FlxTypedGroup<Gem>();
		parent.add(gems);
		createRandomPath();
		
		// Setup mirrors array
		buildMirrors();
	}
	
	private function createRandomPath():Void
	{
		//Declare the obstacles array
		obstacles = new Map<Int, Barrel>();
		
		//Start point
		var xStart:Int = 1;
		var yStart:Int = Std.random(foreground.heightInTiles - 4) + 2;
		setStartPoint(Std.int(xStart), Std.int(yStart));
		
		//End Point
		var xEnd:Int = foreground.widthInTiles - 2;
		var yEnd:Float = Std.random(foreground.heightInTiles - 4) + 2;
		setEndPoint(Std.int(xEnd), Std.int(yEnd));
		
		trace("YEnd: " + yEnd);
		
		//Calculate the path
		var x:Int = xStart;
		var y:Int = yStart;
		var actualDirection:Direction = chooseRandomDirection(x, y);
		
		var path:Array<Array<Int>> = new Array<Array<Int>>();
		for (y in 0...foreground.heightInTiles)
		{
			var arr = new Array<Int>();
			for (x in 0...foreground.widthInTiles)
			{
				arr.push(-1);
			}
			path.push(arr);
		}
				
		while (!hasGeneratedPath)
		{
			//We have ended
			if (foreground.getTile(x, y) == -2){
				hasGeneratedPath = true;
				continue;
			}
			
			var desiredX:Int = x;
			var desiredY:Int = y;
		
			path[desiredY][desiredX] = actualDirection;
			reserveTile(desiredX, desiredY);
						
			if (Math.random() > 0.7)
			{
				actualDirection = chooseRandomDirection(x, y);
				continue;
			}

			switch(actualDirection){
				case Direction.EAST:
					desiredX++;
					if (desiredX == foreground.widthInTiles - 1){
						actualDirection = chooseRandomDirection(x, y);
						continue;
					}
				case Direction.NORTH:
					desiredY--;
					if (desiredY == 1){
						actualDirection = chooseRandomDirection(x, y);
						continue;
					}
				case Direction.SOUTH:
					desiredY++;
					if (desiredY == foreground.heightInTiles - 1){
						actualDirection = chooseRandomDirection(x, y);
						continue;
					}
				case Direction.WEST:
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
		
		while (numberOfRails < PREBUILD_RAILS_MAX)
		{
			direction = path[y][x];
			trace((new FlxPoint(x, y)) + " " + direction);
			
			if (direction == -2)
			{
				break;
			}
			
			var isCurved = lastDirection != -1 && lastDirection != direction;
			
			lastRail = new Railway(this, lastDirection, direction, x * GameMap.TILE_SIZE, y * GameMap.TILE_SIZE);
			rails.add(lastRail);
			lastDirection = direction;
						
			switch(direction) {
				case Direction.EAST:
					++x;
				case Direction.NORTH:
					--y;
				case Direction.SOUTH:
					++y;
				case Direction.WEST:
				case Direction.NONE:
					// NOOOO;
			}
			++numberOfRails;
		}
		
		// Flag start surroundings
		for (x in -1...1)
		{
			for (y in -1...1)
			{
				var cx = xStart + x;
				var cy = yStart + y;
				
				if (cx > 0 && cy > 0 && cx < foreground.widthInTiles - 1 && cy < foreground.heightInTiles - 1 && 
					x != 0 && y != 0 && foreground.getTile(cx, cy) == 0)
				{
					reserveTile(cx, cy, -4);
				}
			}
		}
		
		// Flag end surroundings
		for (x in -1...1)
		{
			for (y in -1...1)
			{
				var cx = Std.int(endPoint.x + x);
				var cy = Std.int(endPoint.y + y);
				
				if (cx > 0 && cy > 0 && cx < foreground.widthInTiles - 1 && cy < foreground.heightInTiles - 1 && 
					x != 0 && y != 0 && foreground.getTile(cx, cy) == 0)
				{
					reserveTile(cx, cy, -4);
				}
			}
		}

		//Fill the map with random noise ensuring that the path is respected
		for (tileY in 0...foreground.heightInTiles)
		{
			for (tileX in 0...foreground.widthInTiles)
			{
				var tileIndex = foreground.getTile(tileX, tileY);
				var xPos:Float = tileX * TILE_SIZE;
				var yPos:Float = tileY * TILE_SIZE;
				
				//Render the start and the end point
				if (tileIndex == -2/* || tileIndex == -3*/)
				{
					gem = new Gem(xPos, yPos);
					gems.add(gem);
				}
				
				//Render an obstacle
				else if (tileIndex != -1 && tileIndex < 50 && tileIndex != 4 && Math.random() > 0.75)
				{
					var barr:Barrel = new Barrel(xPos, yPos);
					obstacles[tileY * foreground.widthInTiles + tileX] = barr;
					_parent.add(barr);
					foreground.setTile(tileX, tileY, Prop.BARREL);
				}
			}
		}
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
	
	private function chooseRandomDirection(x:Int, y:Int):Direction
	{
		var allowedDirs:Array<Direction> = new Array<Direction>();
		
		if (x != foreground.widthInTiles - 1)
			allowedDirs.push(Direction.EAST);
		if (y !=  1)
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
		foreground.setTile(x, y, -3);
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


package;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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

/**
 * ...
 * @author j
 */
class GameMap
{
	public static inline var TILE_SIZE:Int = 16;
	private var background:FlxTilemap;
	
	public var foreground:FlxNapeTilemap;
	public var shadowCanvas:FlxSprite;
	public var shadowOverlay:FlxSprite;
	
	public var mapData:Array<Int>;
	
	private var _parent:FlxState;
	public var gem:Gem;
	
	public var hasGeneratedPath:Bool;
	
	public var obstacles:Map<Int, Barrel>;
	
	
	
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
		createRandomPath();
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
		
		
		while (!hasGeneratedPath)
		{	
			if (Math.random() > 0.7)
			{
				actualDirection = chooseRandomDirection(x, y);
				continue;
			}
			
			//We have ended
			if (foreground.getTile(x, y) == -2){
				hasGeneratedPath = true;
				continue;
			}
			
			var desiredX:Int = x;
			var desiredY:Int = y;

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
			}
		
			reserveTile(desiredX, desiredY);
			x = desiredX;
			y = desiredY;
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
				if (tileIndex == -2 || tileIndex == -3)
				{
					gem = new Gem(xPos, yPos);
					_parent.add(gem);
				}
				
				//Render an obstacle
				else if (tileIndex != -1 && tileIndex != 4 && Math.random() > 0.75)
				{
					var barr:Barrel = new Barrel(xPos, yPos);
					obstacles[tileY * tileX] = barr;
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
	
	private function reserveTile(x:Int, y:Int):Void
	{
		if(foreground.getTile(x, y) == 0)
			foreground.setTile(x, y, -1);
	}
	
	private function setEndPoint(x:Int, y:Int){
		foreground.setTile(x, y, -2);
	}
	
	private function setStartPoint(x:Int, y:Int){
		foreground.setTile(x, y, -3);
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
	var NORTH = 0;
	var EAST = 1;
	var SOUTH = 2;
}


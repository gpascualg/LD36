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
	
	private var _parent:FlxState;
	public var gem:Gem;
	
	public function new(parent:FlxState) 
	{
		_parent = parent;
		var background:FlxTilemap = new FlxTilemap();
		background.loadMapFromCSV("assets/data/background.txt",
			"assets/images/tiles.png", TILE_SIZE, TILE_SIZE, null, 1, 1);
		_parent.add(background);
		
		foreground = new FlxNapeTilemap();
		foreground.loadMapFromCSV("assets/data/foreground.txt",
			"assets/images/tiles.png", TILE_SIZE, TILE_SIZE, null, 1, 1);
		_parent.add(foreground);
	
		shadowOverlay = new FlxSprite();
		shadowOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		shadowOverlay.blend = BlendMode.MULTIPLY;
		_parent.add(shadowOverlay);
		
		shadowCanvas = new FlxSprite();
		shadowCanvas.blend = BlendMode.MULTIPLY;
		shadowCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		_parent.add(shadowCanvas);
		
		foreground.setupTileIndices([4]);
		createProps();	
	}
	
	private function createProps():Void
	{
		for (tileY in 0...foreground.heightInTiles)
		{
			for (tileX in 0...foreground.widthInTiles)
			{
				var tileIndex = foreground.getTile(tileX, tileY);
				var xPos:Float = tileX * TILE_SIZE;
				var yPos:Float = tileY * TILE_SIZE;
				
				if (tileIndex == Prop.BARREL)
				{					
					_parent.add(new Barrel(xPos, yPos));
					cleanTile(tileX, tileY);
				}
				else if (tileIndex == Prop.GEM)
				{
					gem = new Gem(xPos, yPos);
					_parent.add(gem);
					cleanTile(tileX, tileY);
				}
			}
		}
	}	
	
	private function cleanTile(x:Int, y:Int):Void
	{
		foreground.setTile(x, y, 0);
	}
}

@:enum
abstract Prop(Int) to Int
{
	var BARREL = 5;
	var GEM = 6;
}
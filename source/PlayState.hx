package;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Body;
import openfl.display.BlendMode;
import openfl.display.FPS;
import GameMap;
using flixel.util.FlxSpriteUtil;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

/**
 * This was based on a guide from this forum post: http://forums.tigsource.com/index.php?topic=8803.0
 * Ported to HaxeFlixel by Xerosugar
 * 
 * If you're feeling up the challenge, here's how YOU help can improve this demo:
 * - Make it possible to extends the shadows to the edge of the screen
 * - Make it possible to use multiple light sources while still maintaining a decent frame rate
 * - Improve the performance of *this* demo
 * - Make it possible to blur the edges of the shadows
 * - Make it possible to limit the light source's influence, or "strength"
 * - Your own ideas? :)
 * 
 * @author Tommy Elfving
 */
class PlayState extends FlxState
{
	private static inline var SHADOW_COLOR = 0xff2a2963;
	private static inline var OVERLAY_COLOR = 0xff887fff;
	private var map:GameMap;
	
	private var lightSources:FlxTypedGroup<LightSource>;
	private var darknessOverlay:FlxSprite;
	
	private var loco:Loco;
	private var rail:Railway = null;
	private var lastRail = [false, false, false];
	
	/**
	 * If there's a small gap between something (could be two tiles,
	 * even if they're right next to each other), this should cover it up for us
	 */
	private var lineStyle:LineStyle = { color: SHADOW_COLOR, thickness: 1 };
	
	private var infoText:FlxText;
	private var fps:FPS;
	
	private var speedBar:FlxBar;
	private var speedText:FlxText;
	private var speedHint:FlxText;
	
	var _txtNum1:FlxText;
	var _img1:FlxSprite;
	var _img1BG:FlxSprite;
		
	var _txtNum2:FlxText;
	var _img2:FlxSprite;
	var _img2BG:FlxSprite;
	
	var _txtNum3:FlxText;
	var _img3:FlxSprite;
	var _img3BG:FlxSprite;
		
	override public function create():Void
	{
		super.create();
				
		FlxG.camera.bgColor = 0x5a81ad;
		
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 0);
		FlxNapeSpace.drawDebug = false; // You can toggle this on/off one by pressing 'D'		
			
		map = new GameMap(this);
		
		lightSources = new FlxTypedGroup<LightSource>();
		darknessOverlay = new FlxSprite();
		darknessOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, true);
		darknessOverlay.blend = BlendMode.MULTIPLY;
		add(darknessOverlay);
		
		
		speedText = new FlxText(1000, 617, 200, "Speed:", 8, true);
		speedText.size = 10;
		add(speedText);
		
		speedBar = new FlxBar(1048, 615, FlxBarFillDirection.LEFT_TO_RIGHT, 200, 20);
		speedBar.createFilledBar(0xFF63460C, 0xFFE6AA2F);
		speedBar.setRange(Loco.MIN_SPEED - 2, Loco.MAX_SPEED);
		add(speedBar);
		
		
		speedHint = new FlxText(1125, 619, 200, "Press W", 8, true);
		speedHint.size = 8;
		speedHint.alpha = 0.5;
		add(speedHint);
			

		addKeyHint(100, 610, "1", "assets/images/raiways/railway.png", _txtNum1, _img1, _img1BG, 0, 22);
		addKeyHint(150, 610, "2", "assets/images/raiways/Curved Railway.png", _txtNum2, _img2, _img2BG, 90);
		addKeyHint(200, 610, "3", "assets/images/raiways/Curved Railway.png", _txtNum3, _img3, _img3BG, 0);
		
		/*
		// Testing
		lightSources.add(new LightSource(map, 300, 180, 70));
		lightSources.add(new LightSource(map, 20, 300, 70));
		for (source in lightSources)
		{
			source.setTarget(Math.round(FlxG.width), Math.round(FlxG.height));
		}
		
		// Mirror testing
		var mirror = new Mirror(map, lightSources, 300, 130);
		map.mirrors[Std.int(130 / GameMap.TILE_SIZE)][Std.int(300 / GameMap.TILE_SIZE)] = mirror;
		add(mirror);
		*/
		
		// Loco!
		loco = new Loco(map, lightSources, map.startPoint.x * GameMap.TILE_SIZE, map.startPoint.y * GameMap.TILE_SIZE);
		add(loco);
		
		infoText = new FlxText(10, 10, 100, "");
		add(infoText);
		
		// This here is only used to get the current FPS in a simple way, without having to run the application in Debug mode
		fps = new FPS(10, 10, 0xffffff);
		FlxG.stage.addChild(fps);
		fps.visible = false;
		
		#if flash
			FlxG.sound.playMusic(SoundManager.BG_MUSIC_MP3, 0.3, true);
		#else
			FlxG.sound.playMusic(SoundManager.BG_MUSIC_OGG, 0.3, true);
		#end
	}
	
	public function addKeyHint(x:Int, y:Int, text:String, imgSource:String, txt:FlxText, img:FlxSprite, bg:FlxSprite, rot:Float=0, size:Int=24)
	{
		bg = new FlxSprite().makeGraphic(30, 30, FlxColor.BLACK);
		bg.drawRect(0, 19, 30, 1, FlxColor.WHITE);
		
		txt = new FlxText(x, y + 4, 14, text, 10);
		txt.size = 10;
		txt.setBorderStyle(SHADOW, FlxColor.WHITE, 1, 1);
		
		img = new FlxSprite(x + 8, y - 2 + (24 - size),  imgSource);
		img.setGraphicSize(size, size);
		img.angle = rot;
		
		add(img);
		add(txt);		
	}
	
	public function selectRailway(index:Int)
	{
		//TODO: Need to understand how de F**CK change text attributes on the fly
		return;
		switch(index)
		{
			case 1:
				_txtNum1.setBorderStyle(SHADOW, FlxColor.GREEN, 1, 1);
			case 2:
				_txtNum2.setBorderStyle(SHADOW, FlxColor.GREEN, 1, 1);
			case 3:
				_txtNum3.setBorderStyle(SHADOW, FlxColor.GREEN, 1, 1);
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		infoText.text = "FPS: " + fps.currentFPS + "\n\nObjects can be dragged/thrown around.\n\nPress 'R' to restart.";
		
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
		
		if (FlxG.keys.justPressed.D)
			FlxNapeSpace.drawDebug = !FlxNapeSpace.drawDebug;	
		
		var railOld:Int = Direction.NONE;
		var railNew:Int = Direction.EAST;
		if (FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.TWO || FlxG.keys.justPressed.THREE)
		{			
			if (rail != null && (
				(lastRail[0] && FlxG.keys.justPressed.ONE) ||
				(lastRail[1] && FlxG.keys.justPressed.TWO) ||
				(lastRail[2] && FlxG.keys.justPressed.THREE)))
			{
				rail.destroy();
				rail = null;
			}
			else
			{
				if (rail != null)
				{					
					rail.destroy();
					rail = null;
				}
				
				lastRail[0] = FlxG.keys.justPressed.ONE;
				lastRail[1] = FlxG.keys.justPressed.TWO;
				lastRail[2] = FlxG.keys.justPressed.THREE;
				
				railOld = map.lastRail.direction;
				
				if (FlxG.keys.justPressed.ONE)
				{
					selectRailway(1);
					
					railNew = railOld;
				}
				
				if (FlxG.keys.justPressed.TWO)
				{
					selectRailway(2);
					
					if (railOld == Direction.EAST || railOld == Direction.WEST)
					{
						railNew = Direction.NORTH;
					}
					else
					{
						railNew = Direction.EAST;
					}
				}
				
				if (FlxG.keys.justPressed.THREE)
				{
					selectRailway(3);
			
					if (railOld == Direction.EAST || railOld == Direction.WEST)
					{
						railNew = Direction.SOUTH;
					}
					else
					{
						railNew = Direction.WEST;
					}
				}
				
				trace("Setting from " + railOld + " to " + railNew);
				
				rail = new Railway(map, railOld, railNew, 0, 0, false);
				map.rails.add(rail);
			}
		}
		
		if (rail != null)
		{
			var x:Int = Std.int(FlxG.mouse.x / GameMap.TILE_SIZE);
			var y:Int = Std.int(FlxG.mouse.y / GameMap.TILE_SIZE);
			
			rail.x = x * GameMap.TILE_SIZE;
			rail.y = y * GameMap.TILE_SIZE;
			
			if (FlxG.mouse.justPressed)
			{
				map.lastRail = rail;
				rail.reserveNow();
				rail = null;
			}
		}
			
		if (FlxG.keys.pressed.W)
		{
			loco.incrementSpeed(elapsed);
			speedBar.value = loco.speed;
		}else{
			loco.decrementSpeed(elapsed);
			speedBar.value  = loco.speed;
		}
		
		// Clean lightning
		#if debug
			darknessOverlay.fill(0xAAFFFFFF);
		#else
			darknessOverlay.fill(FlxColor.BLACK);
		#end
		
		#if shadows
			// Clean shadows
			map.shadowCanvas.fill(FlxColor.TRANSPARENT);
			map.shadowOverlay.fill(OVERLAY_COLOR);
		#end
		
		// Find closest light for each lightsources
		var i = 0;
		for (source in lightSources)
		{
			if (source.enabled)
			{
				var endPoint = source.castLine(i==2);
				source.setSpan(Std.int(endPoint.x), Std.int(endPoint.y));
				
				#if shadows
					var obs = map.obstacles.get(Std.int(source.lastTile.y * map.foreground.widthInTiles + source.lastTile.x));
					trace(obs);
					if (obs != null)
					{
						processBodyShapes(obs.body);
					}
				#end
				
				drawLighLine(darknessOverlay, source, 50);
				++i;
			}
		}
		
		// Cast shadows
		//processShadows();
		
		super.update(elapsed);
	}
	
	private function drawLighLine(sprite:FlxSprite, source:LightSource, thickness:Int):Void
	{
		var gradient = FlxGradient.createGradientFlxSprite(source.thickness, source.span, [FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK], 1, 0);
		gradient.origin.set(source.thickness / 2, 0);
		gradient.angle = source.angle * 180.0 / Math.PI - 90;
		sprite.stamp(gradient, Std.int(source.x), Std.int(source.y));
		gradient.destroy();
	}
	
	public function processShadows():Void
	{
		map.shadowCanvas.fill(FlxColor.TRANSPARENT);
		map.shadowOverlay.fill(OVERLAY_COLOR);

		for (body in FlxNapeSpace.space.bodies)
		{
			processBodyShapes(body);
		}
	}
	
	private function processBodyShapes(body:Body)
	{
		for (source in lightSources)
		{
			for (shape in body.shapes) 			
			{
				var verts:Vec2List = shape.castPolygon.worldVerts;
				
				for (i in 0...verts.length) 
				{
					var startVertex:Vec2 = (i == 0) ? verts.at(verts.length - 1) : verts.at(i - 1);
					processShapeVertex(source, startVertex, verts.at(i));
				}
			}
		}
	}
	
	private function processShapeVertex(source:LightSource, startVertex:Vec2, endVertex:Vec2):Void
	{
		var tempLightOrigin:Vec2 = Vec2.get(
			source.x + FlxG.random.float( -.3, 3),
			source.y + FlxG.random.float(-.3, .3));
			
		if (doesEdgeCastShadow(startVertex, endVertex, tempLightOrigin))
		{
			var projectedPoint:Vec2 = projectPoint(startVertex, tempLightOrigin);
			var prevProjectedPt:Vec2 = projectPoint(endVertex, tempLightOrigin);
			var vts:Array<FlxPoint> = [
				FlxPoint.weak(startVertex.x, startVertex.y),
				FlxPoint.weak(projectedPoint.x, projectedPoint.y),
				FlxPoint.weak(prevProjectedPt.x, prevProjectedPt.y),
				FlxPoint.weak(endVertex.x, endVertex.y)
			];
			
			map.shadowCanvas.drawPolygon(vts, SHADOW_COLOR, lineStyle);
		}
	}
	
	private function projectPoint(point:Vec2, light:Vec2):Vec2
	{
		var lightToPoint:Vec2 = point.copy();
		lightToPoint.subeq(light);
		
		var projectedPoint:Vec2 = point.copy();
		return projectedPoint.addeq(lightToPoint.muleq(.45));
	}
	
	private function doesEdgeCastShadow(start:Vec2, end:Vec2, light:Vec2):Bool
	{
		var startToEnd:Vec2 = end.copy();
		startToEnd.subeq(start);
		
		var normal:Vec2 = new Vec2(startToEnd.y, -1 * startToEnd.x);
		
		var lightToStart:Vec2 = start.copy();
		lightToStart.subeq(light);
	 
		return normal.dot(lightToStart) > 0;
	}
	
	public static function GameOver():Void
	{
		
	}
}
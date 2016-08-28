package;

import flash.utils.Timer;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import nape.geom.Vec2;
import nape.geom.Vec2List;
import nape.phys.Body;
import openfl.display.BlendMode;
import openfl.display.FPS;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

import GameMap;
import LightSource;

using flixel.util.FlxSpriteUtil;

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
	
	public static var instance:PlayState = null;
	
	private static inline var SHADOW_COLOR = 0xff2a2963;
	private static inline var OVERLAY_COLOR = 0xff887fff;
	private var map:GameMap;
	
	private var lightSources:FlxTypedGroup<LightSource>;
	private var darknessOverlay:FlxSprite;
	
	private var loco:Loco;
	private var pingUp:Bool = true;
	private var ping:LightSource;
	private var rail:Railway = null;
	private var lastRail = [false, false, false];
	
	private static inline var MAX_PING_LIGTH = 300;
	private static inline var PING_RECHARGE = 10;
	private var _pingPower = MAX_PING_LIGTH;
	private var _pingSound:FlxSound;
	
	private var _addRailSound:FlxSound;
	
	/**
	 * If there's a small gap between something (could be two tiles,
	 * even if they're right next to each other), this should cover it up for us
	 */
	private var lineStyle:LineStyle = { color: SHADOW_COLOR, thickness: 1 };
	
	private var fps:FPS;
	
	private var speedBar:FlxBar;
	private var speedText:FlxText;
	private var speedHint:FlxText;
	
	private var beaconBar:FlxBar;
	private var beaconText:FlxText;
	private var beaconHint:FlxText;
	
	private var timerTxt:FlxText;
	public var diamondsTxt:FlxText;
	
	var _txtNum1:FlxText;
	var _img1:FlxSprite;
	var _img1BG:FlxSprite;
		
	var _txtNum2:FlxText;
	var _img2:FlxSprite;
	var _img2BG:FlxSprite;
	
	var _txtNum3:FlxText;
	var _img3:FlxSprite;
	var _img3BG:FlxSprite;
	
	var _effects:FlxEffectSprite;
	var mirror:Mirror;
		
	override public function create():Void
	{
		super.create();
		
		instance = this;
		StatsManager.ResetStats();
		
		FlxG.camera.bgColor = 0x5a81ad;
		
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 0);
		FlxNapeSpace.drawDebug = false; // You can toggle this on/off one by pressing 'D'		
		
		lightSources = new FlxTypedGroup<LightSource>();
		darknessOverlay = new FlxSprite();
			
		map = new GameMap(this, lightSources, darknessOverlay);
		
		darknessOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, true);
		darknessOverlay.blend = BlendMode.MULTIPLY;
		add(darknessOverlay);

		add(_effects = new FlxEffectSprite(darknessOverlay));
		_effects.effects = [new FlxRainbowEffect(0.9)];
		_effects.effects[0].active = false;
		_effects.blend = BlendMode.MULTIPLY;
		
		//Speed UI
		speedText = new FlxText(1000, 617, 200, "Speed:", 8, true);
		speedText.size = 10;
		add(speedText);
		
		speedBar = new FlxBar(1048, 615, FlxBarFillDirection.LEFT_TO_RIGHT, 200, 20);
		speedBar.createFilledBar(0xFF63460C, 0xFFE6AA2F);
		speedBar.setRange(Wagon.MIN_SPEED - 2, Wagon.MAX_SPEED);
		add(speedBar);
		
		speedHint = new FlxText(1125, 619, 200, "Press W", 8, true);
		speedHint.size = 8;
		speedHint.alpha = 0.5;
		add(speedHint);
		//End of speed UI
		
		//Beacon UI
		beaconText = new FlxText(690, 617, 200, "Beacon:", 8, true);
		beaconText.size = 10;
		add(beaconText);
		
		beaconBar = new FlxBar(748, 615, FlxBarFillDirection.LEFT_TO_RIGHT, 200, 20);
		beaconBar.createFilledBar(0xFF000044, 0xFF0000ff);
		beaconBar.setRange(0,  MAX_PING_LIGTH);
		add(beaconBar);
		
		beaconHint = new FlxText(825, 619, 200, "Space", 8, true);
		beaconHint.size = 8;
		beaconHint.alpha = 0.5;
		add(beaconHint);
		
		_pingSound = FlxG.sound.load("assets/sounds/Beacon.wav", 0.3);
		//End of Beacon UI
		_addRailSound = FlxG.sound.load("assets/sounds/addRail.wav", 5);
		
		//KeyHints
		var auxSprite:FlxSprite;
		auxSprite = new FlxSprite().makeGraphic(20, 22, FlxColor.BLACK);
		
		_img1BG = new FlxSprite().makeGraphic(23, 24, FlxColor.GREEN);
		_img1BG.setPosition(512, 614);
		
		auxSprite.setPosition(513, 615);
		add(_img1BG);
		add(auxSprite);
		
		auxSprite = new FlxSprite().makeGraphic(20, 22, FlxColor.BLACK);
		_img2BG = new FlxSprite().makeGraphic(23, 24, FlxColor.GREEN);
		_img2BG.setPosition(561, 614);
		
		auxSprite.setPosition(562, 615);
		add(_img2BG);
		add(auxSprite);
		
		auxSprite = new FlxSprite().makeGraphic(20, 22, FlxColor.BLACK);
		_img3BG = new FlxSprite().makeGraphic(22, 24, FlxColor.GREEN);
		_img3BG.setPosition(614, 614);
		
		auxSprite.setPosition(615, 615);

		add(_img3BG);
		add(auxSprite);
		
		addKeyHint(500, 610, "1", "assets/images/raiways/railway.png", _txtNum1, _img1, _img1BG, 0, 22);
		addKeyHint(550, 610, "2", "assets/images/raiways/Curved Railway.png", _txtNum2, _img2, _img2BG, 90, 23);
		addKeyHint(600, 610, "3", "assets/images/raiways/Curved Railway.png", _txtNum3, _img3, _img3BG, 0, 23);
		clearAllSelectedRails();
		//End of KeyHits
		
		// Mirror testing
		/*
		mirror = new Mirror(map, lightSources, darknessOverlay, 300, 130);
		map.mirrors[Std.int(130 / GameMap.TILE_SIZE)][Std.int(300 / GameMap.TILE_SIZE)] = mirror;
		add(mirror);
		
		lightSources.add(new LightSource(map, darknessOverlay, 300, 180, 70));
		for (source in lightSources)
		{
			source.setTarget(Math.round(300), Math.round(130));
		}
		*/
		
		// Loco!
		loco = new Loco(map, lightSources, darknessOverlay, map.startPoint.x * GameMap.TILE_SIZE, map.startPoint.y * GameMap.TILE_SIZE);
		var wagon1 = new Wagon(map, map.startPoint.x * GameMap.TILE_SIZE, map.startPoint.y * GameMap.TILE_SIZE, "assets/images/train/train-part.png", loco);
		var wagon2 = new Wagon(map, map.startPoint.x * GameMap.TILE_SIZE, map.startPoint.y * GameMap.TILE_SIZE, "assets/images/train/train-bottom.png", wagon1);
		add(wagon2);
		add(wagon1);
		add(loco);
		
		// Ping light
		ping = new LightSource(map, darknessOverlay, 0, 0, 1, LightType.CONCENTRIC_SPOT, false);
		lightSources.add(ping);
		
		// This here is only used to get the current FPS in a simple way, without having to run the application in Debug mode
		fps = new FPS(10, 10, 0xffffff);
		FlxG.stage.addChild(fps);
		fps.visible = false;
		
		#if flash
			FlxG.sound.playMusic(SoundManager.BG_MUSIC_MP3, 1, true);
		#else
			FlxG.sound.playMusic(SoundManager.BG_MUSIC_OGG, 1, true);
		#end
		
		new FlxTimer().start(1.0, function(t:FlxTimer){if (_pingPower < MAX_PING_LIGTH){_pingPower += PING_RECHARGE; }}, 250);	
		
		//STATS:
		timerTxt = new FlxText(30, 614, 150, "Time:", true);
		timerTxt.size = 10;
		add(timerTxt);
		
		timerTxt = new FlxText(68, 614, 150, "0", true);
		timerTxt.size = 10;
		add(timerTxt);
		
		diamondsTxt = new FlxText(95, 614, 200, "Diamods:", true);
		diamondsTxt.size = 10;
		add(diamondsTxt);
		
		diamondsTxt = new FlxText(150, 614, 150, "0", true);
		diamondsTxt.size = 10;
		add(diamondsTxt);
		
		new FlxTimer().start(1, addOneSecond, 0);
	}
	
	public function addOneSecond(timer:FlxTimer):Void
	{
		StatsManager.secondsResisted += 1;
		timerTxt.text = Std.string(StatsManager.secondsResisted);
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
		clearAllSelectedRails();
		switch(index)
		{
			case 1:
				_img1BG.alpha = 1;
			case 2:
				_img2BG.alpha = 1;
			case 3:
				_img3BG.alpha = 1;
		}
	}
	
	public function clearAllSelectedRails()
	{
		_img1BG.alpha = 0;
		_img2BG.alpha = 0;
		_img3BG.alpha = 0;
	}
	
	override public function update(elapsed:Float):Void
	{
		
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
				map.rails.remove(rail);
				rail = null;
				clearAllSelectedRails();
			}
			else
			{
				if (rail != null)
				{
					map.rails.remove(rail);
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
				
				rail = new Railway(map, map.lastRail, railOld, railNew, 0, 0, false);
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
				var tileIdx = map.foreground.getTile(x, y);
				trace(tileIdx);
				if (tileIdx <= 0 || tileIdx >= 50)
				{
					var tx = Std.int(map.lastRail.x / GameMap.TILE_SIZE);
					var ty = Std.int(map.lastRail.y / GameMap.TILE_SIZE);
					
					var canBeAdded = 
						(map.lastRail.direction == Direction.EAST && tx + 1 == x && ty == y) ||
						(map.lastRail.direction == Direction.WEST && tx - 1 == x && ty == y) ||
						(map.lastRail.direction == Direction.NORTH && tx == x && ty - 1 == y) ||
						(map.lastRail.direction == Direction.SOUTH && tx == x && ty + 1 == y);
					
					if (canBeAdded)
					{
						map.lastRail = rail;
						rail.reserveNow();
						rail = null;
						clearAllSelectedRails();
						_addRailSound.play();
					}
				}
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
		
		beaconBar.value = _pingPower;
		
		if (FlxG.keys.justPressed.SPACE && !ping.enabled)
		{
			ping.enabled = true;
			pingUp = true;
			ping.thickness = 0;
			ping.x = loco.x + GameMap.TILE_SIZE / 2.0;
			ping.y = loco.y + GameMap.TILE_SIZE / 2.0;
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
		
		// Update ping
		if (ping.enabled)
		{
			if (pingUp)
			{
				ping.thickness += 10;
				if (ping.thickness > _pingPower)
				{
					pingUp = false;
					_pingPower = 0;
					_pingSound.play(); 
				}
			}
			else
			{
				ping.thickness -= 1;
				
				if (ping.thickness <= 0)
				{
					ping.enabled = false;
				}
			}
		}
		
		// Find closest light for each lightsources
		var i = 0;
		for (source in lightSources)
		{
			if (source.enabled)
			{
				var endPoint = source.castLine();
				source.setSpan(Std.int(endPoint.x), Std.int(endPoint.y));
				
				#if shadows
					var obs = map.obstacles.get(Std.int(source.lastTile.y * map.foreground.widthInTiles + source.lastTile.x));
					trace(obs);
					if (obs != null)
					{
						processBodyShapes(obs.body);
					}
				#end
				
				source.drawLight();
				++i;
			}
		}
		
		// Cast shadows
		//processShadows();
		
		// Overlaps
		FlxG.overlap(loco, map.gems, onGemPicked);
		
		super.update(elapsed);
	}
	
	public function onGemPicked(loco:Loco, gem:Gem)
	{
		darknessOverlay.alpha = 0.90;
		_effects.effects[0].active = true;
		new FlxTimer().start(1, disableRainbow, 1);
		
		loco.onGemPicked(loco, gem);
	}
	
	public function disableRainbow(timer:FlxTimer)
	{
		darknessOverlay.alpha = 1;
		_effects.effects[0].active = false;
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
		FlxG.switchState(new GameOverState()); 
	}
}
package;

import flash.utils.Timer;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;
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
	private var pingsUp:Array<Bool>;
	private var pings:Array<LightSource>;
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
				
		lightSources = new FlxTypedGroup<LightSource>();
		darknessOverlay = new FlxSprite();
		
		map = new GameMap(this);
		loco = new Loco(map, lightSources, darknessOverlay, 0, 0);
		var wagon1 = new Wagon(map, 0, 0, "assets/images/train/train-part.png", loco);
		var wagon2 = new Wagon(map, 0, 0, "assets/images/train/train-bottom.png", wagon1);
		map.createRandomPath(lightSources, darknessOverlay, loco);
		
		darknessOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, true);
		darknessOverlay.blend = BlendMode.MULTIPLY;
		add(darknessOverlay);

		#if !html5
			add(_effects = new FlxEffectSprite(darknessOverlay));
			_effects.effects = [new FlxRainbowEffect(0.9)];
			_effects.effects[0].active = false;
			#if neko
				_effects.blend = BlendMode.MULTIPLY;
			#else
				_effects.blend = BlendMode.ALPHA;
			#end
		#end
		
		//Speed UI
		speedText = new FlxText(1000, 617, 200, "Speed:", 8, true);
		speedText.size = 10;
		add(speedText);
		
		speedBar = new FlxBar(1048, 615, FlxBarFillDirection.LEFT_TO_RIGHT, 200, 20);
		speedBar.createFilledBar(0xFF63460C, 0xFFE6AA2F);
		speedBar.setRange(Wagon.MIN_SPEED - 2, Wagon.MAX_SPEED);
		add(speedBar);
		
		var keyImage:FlxSprite = new FlxSprite().loadGraphic("assets/images/keys/W.png");
		keyImage.setPosition(1128,  609);
		keyImage.alpha = 0.8;
		keyImage.setGraphicSize(18, 18);
		add(keyImage);
		//End of speed UI
		
		//Beacon UI
		beaconText = new FlxText(690, 617, 200, "Beacon:", 8, true);
		beaconText.size = 10;
		add(beaconText);
		
		beaconBar = new FlxBar(748, 615, FlxBarFillDirection.LEFT_TO_RIGHT, 200, 20);
		beaconBar.createFilledBar(0xFF000044, 0xFF0000ff);
		beaconBar.setRange(0,  MAX_PING_LIGTH);
		add(beaconBar);
		
		
		keyImage = new FlxSprite().loadGraphic("assets/images/keys/SPACE.png");
		keyImage.alpha = 0.8;
		keyImage.setPosition(760,  610);
		keyImage.setGraphicSize(90, 17);
		add(keyImage);
		
		var t:FlxText = new FlxText(220, 617, 200, "Surrender");
		t.size = 10;
		add(t);
		
		keyImage = new FlxSprite().loadGraphic("assets/images/keys/G.png");
		keyImage.alpha = 0.8;
		keyImage.setPosition(190,  608);
		keyImage.setGraphicSize(18, 18);
		add(keyImage);

		
		_pingSound = FlxG.sound.load("assets/sounds/Beacon.wav", 0.3);
		//End of Beacon UI
		_addRailSound = FlxG.sound.load("assets/sounds/addRail.wav", 5);
		
		//KeyHints
		var auxSprite:FlxSprite;
		auxSprite = new FlxSprite().makeGraphic(20, 22, FlxColor.BLACK);
		
		_img1BG = new FlxSprite().makeGraphic(23, 24, FlxColor.GREEN);
		_img1BG.setPosition(492, 614);
		
		auxSprite.setPosition(493, 615);
		add(_img1BG);
		add(auxSprite);
		
		auxSprite = new FlxSprite().makeGraphic(20, 22, FlxColor.BLACK);
		_img2BG = new FlxSprite().makeGraphic(23, 24, FlxColor.GREEN);
		_img2BG.setPosition(554, 614);
		
		auxSprite.setPosition(555, 615);
		add(_img2BG);
		add(auxSprite);
		
		auxSprite = new FlxSprite().makeGraphic(20, 22, FlxColor.BLACK);
		_img3BG = new FlxSprite().makeGraphic(23, 24, FlxColor.GREEN);
		_img3BG.setPosition(611, 614);
		
		auxSprite.setPosition(613, 615);

		add(_img3BG);
		add(auxSprite);
		
				
		var t:FlxText = new FlxText(405, 617, 200, "Remove");
		t.size = 10;
		add(t);
		
		var rem:FlxSprite = new FlxSprite().loadGraphic("assets/images/keys/D.png");
		rem.setPosition(375, 610);
		rem.alpha = 0.8;
		rem.setGraphicSize(18, 18);
		add(rem);
		
		addKeyHint(480, 610, "1", "assets/images/raiways/railway.png", _txtNum1, _img1, _img1BG, 0, 22);
		addKeyHint(540, 610, "2", "assets/images/raiways/Curved Railway.png", _txtNum2, _img2, _img2BG, 0, 23);
		addKeyHint(600, 610, "3", "assets/images/raiways/Curved Railway.png", _txtNum3, _img3, _img3BG, 90, 23);
		clearAllSelectedRails();
		//End of KeyHits
		
		/*
		// Mirror testing
		mirror = new Mirror(map, lightSources, darknessOverlay, map.endPoint.x * GameMap.TILE_SIZE, map.endPoint.y * GameMap.TILE_SIZE);
		map.mirrors[Std.int(map.endPoint.y)][Std.int(map.endPoint.x)] = mirror;
		add(mirror);
		
		lightSources.add(new LightSource(map, darknessOverlay, 300, 180, 70));
		for (source in lightSources)
		{
			source.setTarget(Math.round(300), Math.round(130));
		}
		*/
		
		// Loco!
		loco.init(map.startPoint.x * GameMap.TILE_SIZE, map.startPoint.y * GameMap.TILE_SIZE);
		wagon1.init(map.startPoint.x * GameMap.TILE_SIZE, map.startPoint.y * GameMap.TILE_SIZE);
		wagon2.init(map.startPoint.x * GameMap.TILE_SIZE, map.startPoint.y * GameMap.TILE_SIZE);
		add(wagon2);
		add(wagon1);
		add(loco);
		
		// Ping light
		pings = new Array<LightSource>();
		pingsUp = new Array<Bool>();
		
		// This here is only used to get the current FPS in a simple way, without having to run the application in Debug mode
		fps = new FPS(10, 10, 0xffffff);
		FlxG.stage.addChild(fps);
		fps.visible = false;
		
		SoundManager.PlayBackgroundMusic();
		
		new FlxTimer().start(1.0, function(t:FlxTimer){ if (_pingPower < MAX_PING_LIGTH && (pingsUp.length <= 0 || !pingsUp[pingsUp.length - 1])){_pingPower += PING_RECHARGE; }}, 250);	
		
		//STATS:
		timerTxt = new FlxText(30, 617, 150, "Time:");
		timerTxt.size = 10;
		add(timerTxt);
		
		timerTxt = new FlxText(68, 617, 150, "0");
		timerTxt.size = 10;
		add(timerTxt);
		
		diamondsTxt = new FlxText(95, 617, 200, "Diamods:");
		diamondsTxt.size = 10;
		add(diamondsTxt);
		
		diamondsTxt = new FlxText(150, 617, 150, "0");
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
		var keyImage:FlxSprite = new FlxSprite().loadGraphic("assets/images/keys/"+text+".png");
		trace(keyImage.path);
		keyImage.setPosition(x-17, y);
		keyImage.alpha = 0.8;
		keyImage.setGraphicSize(18, 18);
		
		add(keyImage);
		
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
		
		if (FlxG.keys.justPressed.G)
			GameOver();
		
		if (FlxG.keys.justPressed.R)
			FlxG.resetGame();
		
		var railOld:Int = Direction.NONE;
		var railNew:Int = Direction.EAST;
		if (FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.TWO || FlxG.keys.justPressed.THREE)
		{			
			if (rail != null && (
				(lastRail[0] && FlxG.keys.justPressed.ONE) ||
				(lastRail[1] && FlxG.keys.justPressed.TWO) ||
				(lastRail[2] && FlxG.keys.justPressed.THREE)))
			{
				map.tempRailRemove(rail);
				rail = null;
				clearAllSelectedRails();
			}
			else
			{
				if (rail != null)
				{
					map.tempRailRemove(rail);
					rail = null;
				}
				
				lastRail[0] = FlxG.keys.justPressed.ONE;
				lastRail[1] = FlxG.keys.justPressed.TWO;
				lastRail[2] = FlxG.keys.justPressed.THREE;
				
				railOld = map.getLastDirection();
				
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
				
				rail = new Railway(map, map.lastRail, railOld, railNew, 0, 0);
				map.tempRailPlace(rail);
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
					var direction = map.getLastDirection();
					
					var canBeAdded = 
						(direction == Direction.EAST && tx + 1 == x && ty == y) ||
						(direction == Direction.WEST && tx - 1 == x && ty == y) ||
						(direction == Direction.NORTH && tx == x && ty - 1 == y) ||
						(direction == Direction.SOUTH && tx == x && ty + 1 == y);
					
					if (canBeAdded)
					{
						rail.updateTile();
						map.placeRailAt(rail, rail.tx, rail.ty);
						loco.updateLast(rail);
						rail = null;
						clearAllSelectedRails();
						_addRailSound.play();
						onRailPlaced();
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
		
		if (FlxG.keys.justPressed.D)
		{
			map.removeRailAt(map.lastRail.tx, map.lastRail.ty);
			
			var curDir = map.getLastDirection();
			var newLast = map.lastRail.previousRail(curDir);
			var newDir:Int = map.directionInverse(map.lastRail.previousDirection(curDir));
			
			if (newLast == null)
			{
				var rails = loco.nextRails();
				if (rails.railCombo.length > 0)
				{
					newLast = rails.railCombo[rails.railCombo.length - 1].railway;
					newDir = rails.railCombo[rails.railCombo.length - 1].direction;
				}
			}
			
			if (newLast == null || !newLast.exists)
			{
				GameOver();
			}
			
			map.setLastRail(newLast, newDir);
		}
		
		beaconBar.value = _pingPower;
		
		if (FlxG.keys.justPressed.SPACE)
		{
			var light = new LightSource(map, darknessOverlay, 0, 0, 100, LightType.CONCENTRIC_SPOT, true);
			pings.push(light);
			pingsUp.push(true);
			lightSources.add(light);
			
			light.x = loco.x + GameMap.TILE_SIZE / 2.0;
			light.y = loco.y + GameMap.TILE_SIZE / 2.0;
		}
				
		if (FlxG.keys.justReleased.SPACE)
		{
			if (pingsUp.length > 0 && pingsUp[pingsUp.length - 1])
			{
				pingsUp[pingsUp.length - 1] = false;
				_pingSound.play();
			}
		}
		
		
		// Clean lightning
		#if (debug && !html5)
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
		var toRemove:Array<LightSource> = [];
		for (i in 0...pings.length)
		{
			var ping = pings[i];
			var pingUp = pingsUp[i];
			
			if (ping.enabled)
			{
				if (pingUp)
				{
					ping.thickness += 5;
					_pingPower -= 10;
					if (_pingPower <= 0)
					{
						pingsUp[i] = false;
						_pingPower = 0;
						_pingSound.play();
					}
				}
				else
				{
					ping.thickness -= 1;
					
					if (ping.thickness <= 0)
					{
						toRemove.push(ping);
						pingsUp.remove(false);
					}
				}
			}
		}
		
		for (ping in toRemove)
		{
			lightSources.remove(ping);
			pings.remove(ping);
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
	
	public function onRailPlaced():Void{}
	
	public function onGemPicked(loco:Loco, gem:Gem)
	{
		darknessOverlay.alpha = 0.90;
		#if !html5
			_effects.effects[0].active = true;
		#end
		new FlxTimer().start(1, disableRainbow, 1);
		
		loco.onGemPicked(loco, gem);
	}
	
	public function disableRainbow(timer:FlxTimer)
	{
		darknessOverlay.alpha = 1;
		#if !html5
			_effects.effects[0].active = false;
		#end
	}
	
	public function GameOver():Void
	{
		FlxG.switchState(new GameOverState()); 
	}
}
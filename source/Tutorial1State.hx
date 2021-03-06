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
import flixel.ui.FlxButton;
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


class Tutorial1State extends PlayState
{
	private var moving:Bool = false;
	private var lastWagon:Wagon = null; 
	
	override public function create():Void
	{
		super.create();
		
		darknessOverlay.alpha = 0;
		map.loadTutorial(loco, 0);
		
		var explImage:FlxSprite = new FlxSprite().loadGraphic("assets/images/Tut1Expl.png");
		add(explImage);
		
		var title:FlxText = new FlxText(45, 25, 600, "Tutorial 1: Movement", 30);
		add(title);
		
		var explanation:FlxText = new FlxText(50, 100, 0, "Select Railway", 25);
		add(explanation);
		
		explanation = new FlxText(762, 100, 0, "Place", 25);
		add(explanation);

		explanation = new FlxText(988, 100, 0, "Delete", 25);
		add(explanation);
		
		var tutImg:FlxSprite = new FlxSprite().loadGraphic("assets/images/Tutorial1.png");
		tutImg.setPosition(584, 360);
		tutImg.alpha = 0.6;
		add(tutImg);
		
		var button:FlxButton = new FlxButton(1165, 23, "Skip Tutorial", function(){
			Main.SkipTutorial();
		});
		
		add(button);
		
		loco.speed = Wagon.MAX_SPEED;
		lastWagon = loco;
		while (lastWagon.next != null)
		{
			lastWagon = lastWagon.next;
		}
	}
	
	override public function doEffects()
	{}
	
	override public function update(elapsed:Float):Void
	{
		if (!lastWagon._first && !moving && loco.speed > 0)
		{
			loco.stop();
		}
		
		super.update(elapsed);
	}
	
	override public function onGemPicked(loco:Loco, gem:Gem)
	{
		if (gem.alive && gem.exists)
		{
			FlxG.sound.play(SoundManager.PICKUP_SOUND, 1).onComplete = function(){
				FlxG.switchState(new Tutorial2State());
			}
			
			gem.alive = false;
		}
	}
	
	override public function onRailPlaced():Void
	{
		moving = true;
		loco.restart();
	}
	
	override public function GameOver():Void
	{
		FlxG.resetState();
	}
}
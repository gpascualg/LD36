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
import flixel.ui.FlxButton;
import openfl.display.BlendMode;
import openfl.display.FPS;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

import GameMap;
import LightSource;

using flixel.util.FlxSpriteUtil;


class Tutorial2State extends PlayState
{	
	var completed:Bool = false;
	
	override public function create():Void
	{
		super.create();
		
		darknessOverlay.alpha = 0;
		map.loadTutorial(loco, 1);
		
		var explImage:FlxSprite = new FlxSprite().loadGraphic("assets/images/Tut2Expl.png");
		add(explImage);
		
		var title:FlxText = new FlxText(45, 25, 600, "Tutorial 2: Speed", 30);
		add(title);
		
		var explanation:FlxText = new FlxText(50, 100, 0, "Increment speed:", 25);
		add(explanation);
		
		explanation = new FlxText(760, 100, 0, "GOAL:", 25);
		add(explanation);
		
		explanation = new FlxText(760, 170, 0, "REACH MAX SPEED!", 30);
		explanation.setBorderStyle(SHADOW, FlxColor.YELLOW);
		add(explanation);
		
		for (gem in map.gems)
		{
			gem.alpha = 0;
		}
		
		var button:FlxButton = new FlxButton(1165, 23, "Skip Tutorial", function(){
			Main.SkipTutorial();
		});
		add(button);
	}

	override public function doEffects()
	{}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (loco.speed >= Wagon.MAX_SPEED)
		{
			if (completed) return;
			completed = true;
			
			FlxG.sound.play(SoundManager.PICKUP_SOUND, 1).onComplete = function(){
				FlxG.switchState(new Tutorial3State());
			}	
		}
	}
	
	override public function onGemPicked(loco:Loco, gem:Gem)
	{
	}
	
	override public function onRailPlaced():Void{
		
		loco.restart();
	}
	
	override public function GameOver():Void
	{
		FlxG.resetState();
	}
}
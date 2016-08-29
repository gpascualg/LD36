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


class Tutorial1State extends PlayState
{	
	override public function create():Void
	{
		super.create();
		
		darknessOverlay.alpha = 0;
		map.loadTutorial(loco, 0);
		
		//Make the loco stop after a few seconds
		new FlxTimer().start(2.4, function(t:FlxTimer){loco.stop(); }, 1);
		
		var explImage:FlxSprite = new FlxSprite().loadGraphic("assets/images/Tut1Expl.png");
		add(explImage);
		
		var title:FlxText = new FlxText(45, 25, 600, "Tutorial 1: Movement", 30);
		add(title);
		
		var explanation:FlxText = new FlxText(50, 100, "Select Railway", 25);
		add(explanation);
		
		explanation = new FlxText(760, 100, "Place", 25);
		add(explanation);

		explanation = new FlxText(988, 100, "Delete", 25);
		add(explanation);
		
		var tutImg:FlxSprite = new FlxSprite().loadGraphic("assets/images/Tutorial1.png");
		tutImg.setPosition(584, 424);
		tutImg.alpha = 0.6;
		add(tutImg);
	}
		
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	override public function onGemPicked(loco:Loco, gem:Gem)
	{
		FlxG.sound.play(SoundManager.PICKUP_SOUND, 1).onComplete = function(){
			FlxG.switchState(new Tutorial2State());
		}	
	}
	
	override public function onRailPlaced():Void{
		
		loco.restart();
	}
	
	override public function GameOver():Void
	{
		FlxG.resetState();
	}
}
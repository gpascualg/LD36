package;

import flash.display.Sprite;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxSpriteAniRot;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flash.events.KeyboardEvent;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;


/**
 * ...
 * @author j
 */
class SplashScreen extends FlxState
{

	var title:FlxText;
	var credits:FlxText;
	var howTo:FlxText;
	var pressKey:FlxText;
	
	var numUpdates:Int = 0;
	
	var showPress:Bool = false;
	
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		
		SoundManager.PlayBackgroundMusic();
		
		var _splashEffect:FlxEffectSprite;
		
		var splashImage:FlxSprite = new FlxSprite().loadGraphic("assets/images/splash/splash-bg.png");
		add(_splashEffect = new FlxEffectSprite(splashImage));
		var effect:FlxGlitchEffect = new FlxGlitchEffect(10, 2, 0.1);
		_splashEffect.effects = [effect];
		
		
		var image:FlxSprite = new FlxSprite().loadGraphic("assets/images/splash/title.png");
		image.setPosition(1280 / 2 - (742 / 2), 100);
		image.alpha = 0;
		add(image);
		
		pressKey = new FlxText(0, 550, 1280, "Press any key to start");
		pressKey.alignment = FlxTextAlign.CENTER;
		pressKey.size = 20;
		pressKey.alpha = 0;
		pressKey.setBorderStyle(SHADOW, FlxColor.YELLOW, 1, 1);
		add(pressKey);
		
		FlxTween.tween(image, { alpha: 1 }, 4, { ease: FlxEase.cubeIn }).onComplete = showPlay;
		
	}
	
	private function showPlay(tween:FlxTween):Void
	{
		showPress = true;
	}
	
	
	override public function update(elapsed:Float):Void
	{
		if (!showPress) return;
		
		numUpdates++;
		pressKey.alpha = numUpdates / 400;
		if (numUpdates == 400){			
			numUpdates = 0;
		}
		
		if (FlxG.keys.firstJustReleased() != -1)
		{
			FlxG.sound.play(SoundManager.PICKUP_SOUND, 1).onComplete = function(){
				FlxG.switchState(new PlayState());
			}	
		}
	}
	

	
}
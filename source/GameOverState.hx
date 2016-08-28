package;

import flash.display.Sprite;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.effects.chainable.FlxGlitchEffect;


/**
 * ...
 * @author j
 */
class GameOverState extends FlxState
{

	private var _gameOverSprite:FlxSprite;
	private var _gameOverEffectSprite:FlxEffectSprite;
	private var _shakeEffect:FlxShakeEffect;
	
	private var _gameOverSound:FlxSound;
	
	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		
		var bgEffect:FlxEffectSprite;
		
		var splashImage:FlxSprite = new FlxSprite().loadGraphic("assets/images/splash/splash-bg.png");
		add(bgEffect = new FlxEffectSprite(splashImage));
		var effect:FlxGlitchEffect = new FlxGlitchEffect(10, 2, 0.1);
		bgEffect.effects = [effect];
		
		_gameOverSound = FlxG.sound.load(SoundManager.DEATH_SOUND);
		
		_gameOverSprite = new FlxSprite(100, 100, "assets/images/Game-Over.png");
		add(_gameOverEffectSprite = new FlxEffectSprite(_gameOverSprite));
		
		_gameOverEffectSprite.setPosition(1280 / 2 - (506 / 2), 100);
		
		_shakeEffect = new FlxShakeEffect(10, 3);
		_gameOverEffectSprite.effects = [_shakeEffect];
		_shakeEffect.intensity = 10;
		_shakeEffect.start();
		
		_gameOverSound.volume = 0.5;
		_gameOverSound.play();
		
		var button = new FlxButton(470, 450, "Play Again");
		button.setGraphicSize(180, 30);
		button.setSize(180, 30);
		
		button.onUp.callback = function()
		{
			FlxG.switchState(new PlayState());	
		}
		
		add(button);
		
		var button = new FlxButton(730, 450, "Main Menu");
		button.setGraphicSize(180, 30);
		button.setSize(180, 30);
		
		button.onUp.callback = function()
		{
			FlxG.sound.play(SoundManager.PICKUP_SOUND, 1).onComplete = function(){
				FlxG.switchState(new SplashScreen());
			}	
		}
		
		add(button);
		
		
		var horOffset:Int = 80;
		
		_shakeEffect.onComplete = function(){
			var infoText = new FlxText(410 + horOffset, 260, 300, "Time Resisted:", true);
			infoText.size = 24;
			add(infoText);
			
			infoText = new FlxText(700 + horOffset, 260, 260, Std.string(StatsManager.secondsResisted), true);
			infoText.size = 24;
			add(infoText);
			
			infoText = new FlxText(410 + horOffset, 314, 300, "Diamonds Taken:", true);
			infoText.size = 24;
			add(infoText);
			
			infoText = new FlxText(700 + horOffset, 314, 300, Std.string(StatsManager.gemsTaken), true);
			infoText.size = 24;
			add(infoText);
		}

		
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
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
		
		var button = new FlxButton(460, 450, "Play Again");
		button.setGraphicSize(180, 30);
		
		button.onUp.callback = function()
		{
			FlxG.switchState(new PlayState());
		}
		
		add(button);
		
		var button = new FlxButton(720, 450, "Main Menu");
		button.setGraphicSize(180, 30);
		
		button.onUp.callback = function()
		{
			FlxG.switchState(new SplashScreen());
		}
		
		add(button);
		
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
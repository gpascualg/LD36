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
class Tutorial4State extends FlxState
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
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
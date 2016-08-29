package;

import flash.display.Sprite;
import flash.utils.Timer;
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
import flixel.util.FlxTimer;


/**
 * ...
 * @author j
 */
class Tutorial4State extends FlxState
{
	var _counter:FlxText;
	var button:FlxButton;
	
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
		
		var title:FlxText = new FlxText(0, 60, 1280, "Well Done!", 90);
		title.alignment = FlxTextAlign.CENTER;
		add(title);
		
		title = new FlxText(0, 240, 1280, "It's time to get some diamonds!", 35);
		title.alignment = FlxTextAlign.CENTER;
		title.setBorderStyle(SHADOW, FlxColor.BLUE);
		add(title);
		
		_counter = new FlxText(0, 360, 1280, "5", 50);
		_counter.alignment = FlxTextAlign.CENTER;
		_counter.alpha = 0;
		add(_counter);
		
		button = new FlxButton(1280 / 2 - 300, 350, "I'M READY", function()
		{
			_counter.alpha = 1;
			new FlxTimer().start(1, countdown, 0);
			button.destroy();
		});
		
		button.setSize(300, 50);
		button.setGraphicSize(300, 50);
		button.setPosition(1280 / 2 - 45, 520);
		add(button);
		
		
	}
	
	private function countdown(timer:FlxTimer):Void
	{
		
		FlxG.sound.play("assets/sounds/Counter.wav");
		var c:Int = Std.parseInt(_counter.text);
		c--;
		_counter.text = Std.string(c);
		if(c == 0)
		{
			FlxG.switchState(new PlayState());
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.F)
		{
            FlxG.fullscreen = !FlxG.fullscreen;
		}
		
		super.update(elapsed);
	}
}
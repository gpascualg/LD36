package;

import flash.display.GraphicsSolidFill;
import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.FlxG;
import flixel.util.FlxSave;

using Main.FloatExtender;

class FloatExtender {
	static public inline var EPSILON = 1e-6;
	
	static public function equals(f:Float, o:Float, ?epsilon:Float=EPSILON)
	{
		return f - epsilon <= o && f + epsilon >= o;
	}
	
	static public function pequals(f:Float, o:Float, ?epsilon:Float=EPSILON)
	{
		return f - o <= epsilon;
	}
	
	static public function clamp(f:Float, min:Float, max:Float)
	{
		return (f < min ? min : (f > max ? max : f));
	}
}

class Main extends Sprite
{
	var skipSplash:Bool = true;
	public static inline var MAP_WIDTH:Int = 640;
	public static inline var MAP_HEIGTH:Int = 320;
	public static inline var MAP_SCALE:Int = 2;
	public static var gameSave = new FlxSave();
	
	public function new()
	{
		super();
		gameSave.bind("SaveState");
		addChild(new FlxGame(MAP_WIDTH * MAP_SCALE, MAP_HEIGTH * MAP_SCALE, SplashScreen, 1, 60, 60, true, false));
	}
	
	public static function SkipTutorial():Void
	{
		FlxG.switchState(new PlayState());
	}
}
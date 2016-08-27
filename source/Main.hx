package;

import flixel.FlxGame;
import openfl.display.Sprite;

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
}

class Main extends Sprite
{
	var skipSplash:Bool = true;
	public function new()
	{
		super();
		#if !flash
			addChild(new FlxGame(640, 320, PlayState, 1, 60, true, false));
		#else
			addChild(new FlxGame(640, 320, PlayState));
		#end
	}
}
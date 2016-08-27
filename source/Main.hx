package;

import flixel.FlxGame;
import openfl.display.Sprite;

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
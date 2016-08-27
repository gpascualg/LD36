package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var skipSplash:Bool = true;
	public function new()
	{
		super();
		addChild(new FlxGame(640, 320, PlayState, 1, 60, true, false));
	}
}
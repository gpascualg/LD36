package;

import flixel.FlxSprite;
import flixel.FlxG;
import GameMap;

class Barrel extends FlxSprite
{
	public function new(X:Float, Y:Float)
	{
		super(X, Y, "assets/images/barrel.png");	
	}
	
	override public function update(elapsed:Float):Void
	{		
		super.update(elapsed);
	}
}
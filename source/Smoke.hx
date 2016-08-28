package;
import flixel.util.FlxTimer;
using flixel.FlxSprite;

/**
 * ...
 * @author j
 */
class Smoke extends FlxSprite
{	
	var timer:FlxTimer;
	public function new(X:Float, Y:Float) 
	{
		super(X, Y);
		loadGraphic("assets/images/Smoke.png", true, 8, 8);
		animation.add("smoke", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 5);
		animation.play("smoke");
		
		timer = new FlxTimer().start(2, destroySmoke, 1);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	public function destroySmoke(timer:FlxTimer):Void
	{
		destroy();
	}
}
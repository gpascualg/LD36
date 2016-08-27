package;

import flash.display.Sprite;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxSpriteAniRot;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flash.events.KeyboardEvent;

/**
 * ...
 * @author j
 */
class SplashScreen extends FlxState
{

	var title:FlxText;
	var credits:FlxText;
	var howTo:FlxText;
	var pressKey:FlxText;
	
	var numUpdates:Int = 0;
	
	public function new() 
	{
		super();
		
		title = new FlxText(100, 50, 1000, "A Trip Into The Dark", true);
		title.size = 60;
		add(title);
		
		howTo = new FlxText(100, 200, 400, "How to play:", true);
		howTo.size = 20;
		add(howTo);
		
		credits = new FlxText(880, 610, 400, "A game made in 72 hours for Ludum Dare 36 by blipy & 4nc3str4l", true);
		credits.size = 10;
		add(credits);
		
		pressKey = new FlxText(480, 550, 400, "Press any key to start", true);
		pressKey.size = 20;
		pressKey.setBorderStyle(SHADOW, FlxColor.YELLOW, 1, 1);
		add(pressKey);
	}
	
	override public function update(elapsed:Float):Void
	{
		numUpdates++;
		pressKey.alpha = numUpdates / 400;
		if (numUpdates == 400){			
			numUpdates = 0;
		}
		
		if (FlxG.keys.firstJustReleased() != -1)
		{
			FlxG.switchState(new PlayState());
		}
	}
	

	
}
package;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Material;
import GameMap;
import nape.phys.BodyType;

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
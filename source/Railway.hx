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

class Railway extends FlxSprite
{
	public function new(map:GameMap, direction:Int, X:Float, Y:Float, ?curved:Bool=false)
	{
		if (!curved)
		{
			if (direction == Direction.NORTH || direction == Direction.SOUTH)
			{
				super(X, Y, "assets/images/raiways/railway.png");
			}
			else
			{
				super(X, Y, "assets/images/raiways/horizontal-railway.png");
			}
		}
		else
		{
			super(X, Y, "assets/images/raiways/Curved Railway.png");
		}
		
		map.reserveTile(Std.int(X / GameMap.TILE_SIZE), Std.int(Y / GameMap.TILE_SIZE), direction);
	}
	
	override public function update(elapsed:Float):Void
	{		
		super.update(elapsed);
	}
}
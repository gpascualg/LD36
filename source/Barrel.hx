package;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Material;
import GameMap;
import nape.phys.BodyType;

class Barrel extends FlxNapeSprite
{
	private var dragJoint:PivotJoint;
	
	public function new(X:Float, Y:Float)
	{
		super(X + GameMap.TILE_SIZE *.5, Y + 8, "assets/images/barrel.png");

		createRectangularBody(GameMap.TILE_SIZE, GameMap.TILE_SIZE, BodyType.KINEMATIC);
		var mat:Material = new Material(0.1, 0.2, 0.38, 1, 0.005);
		body.setShapeMaterials(mat);
		body.userData.type = "Barrel";
		
		dragJoint = new PivotJoint(FlxNapeSpace.space.world, null, Vec2.weak(), Vec2.weak());
		dragJoint.space = FlxNapeSpace.space;
		dragJoint.active = false;
		dragJoint.stiff = true;
		
	}
	
	override public function update(elapsed:Float):Void
	{
		if (FlxG.mouse.justPressed && FlxG.mouse.getWorldPosition().inCoords(x, y, width, height)) 
		{
			var mousePoint = Vec2.get(FlxG.mouse.x, FlxG.mouse.y);
			
			dragJoint.body2 = body;
			dragJoint.anchor2.set(body.worldPointToLocal(mousePoint, true));
			dragJoint.active = true;
			
			mousePoint.dispose();
		}
		
		if (!FlxG.mouse.pressed) 
		{
			dragJoint.active = false;
		}
		
		if (dragJoint.active)
		{
			dragJoint.anchor1.setxy(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		super.update(elapsed);
	}
}
package;

import flash.display.InteractiveObject;
import flash.geom.Point;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

import Wagon;
import GameMap;

import flixel.util.FlxTimer;

using Main.FloatExtender;

/**
 * About the 'userData'-field:
 * Most things in Nape have this handy Dynamic field called 'userData' which
 * can hold pretty much any kind of data. This can aid you in finding - or
 * referencing this particular nape-sprite instance later, just do:
 *    body.userData.someFieldName = someValue
 * 
 * Note: The program does not always provide you with error messages when it
 * crashes and when Nape is involved; be sure to not refer to fields in userData
 * that you're not sure exists.
 * 
 * To read more about what Nape is and what it can do
 * (and to study some interesting - and useful - Nape demos)
 * @see http://napephys.com/samples.html
 */
class Loco extends Wagon
{
	private var light:LightSource;
	
	public function new(map:GameMap, lights:FlxTypedGroup<LightSource>, X:Float, Y:Float) 
	{
		super(map, X, Y, "assets/images/train/train-head.png");
		
		new FlxTimer().start(1.0, expluseSmoke, 0);
		
		light = new LightSource(map, X, Y + GameMap.TILE_SIZE / 2, 70);
		light.setTarget(Std.int(X + 10000), Std.int(Y));
		lights.add(light);	
	}
	
	public function stop()
	{
		speed = 0;
	}
	
	public function incrementSpeed(elapsed:Float)
	{
		if(speed < Wagon.MAX_SPEED)
			speed += Wagon.ACELERATION * elapsed;
	}
	public function decrementSpeed(elapsed:Float)
	{
		if (speed > Wagon.MIN_SPEED)
			speed -= Wagon.ACELERATION * elapsed;
	}
	
	private function roundTo10(x:Float)
	{
		x = Std.int(x);
		return x + (10 - (x % 10));
	}
	
	override public function update(elapsed:Float):Void
	{		
		updateLight();
		super.update(elapsed);
	}
	
	private function updateLight()
	{
		var ang:Float = 0;
		if (_last == Direction.EAST || _next == Direction.EAST)
		{
			ang = ((FlxG.mouse.y - y) / 1000).clamp( -0.1, 0.1) + angle * Math.PI / 180;
		}
		else
		{
			ang = ((FlxG.mouse.x - x) / 1000).clamp( -0.1, 0.1) + angle * Math.PI / 180;
		}
		
		var cx = x - GameMap.TILE_SIZE / 2.0;
		var cy = y + GameMap.TILE_SIZE / 2.0;
		var r = GameMap.TILE_SIZE / 2.0;
		var rad = angle * Math.PI / 180;
		
		light.x = cx + r * Math.cos(rad);
		light.y = cy + r * Math.sin(rad);
		light.angle = ang;
		light.setSpan(Std.int(light.x + Math.cos(light.angle) * 10000), Std.int(light.y + Math.sin(light.angle) * 10000));
		light.force();
	}
	
	private function expluseSmoke(timer:FlxTimer):Void
	{
		var offsetX:Int = 0;
		var offsetY:Int = 0;
		
		var normalizedAngle:Float = angle % 360;
		
		if (normalizedAngle < 0)
			normalizedAngle += 360;
		
		switch(normalizedAngle)
		{
			case 0:
				offsetX = 4;
				offsetY = 22;
			case 90:
				offsetX = 1;
				offsetY = 6;
			case 270:
				offsetX = 20;
				offsetY = 4;
			case 180:
				offsetX = 20;
				offsetY = 0;
		}
		PlayState.instance.add(new Smoke(this.x + offsetX, this.y + offsetY));
	}
}

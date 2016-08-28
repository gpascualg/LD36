package;

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
	
	
	public function new(map:GameMap, lights:FlxTypedGroup<LightSource>, canvas: FlxSprite, X:Float, Y:Float) 
	{
		super(map, X, Y, "assets/images/train/train-head.png");
		
		light = new LightSource(map, canvas, X, Y + GameMap.TILE_SIZE / 2, 70);
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
		
	override public function update(elapsed:Float):Void
	{		
		updateLight();
		super.update(elapsed);
	}
	
	private function updateLight()
	{
		var ang:Float = 0;
		if (_last == Direction.EAST || _next == Direction.EAST || _last == Direction.WEST || _next == Direction.WEST)
		{
			ang = ((FlxG.mouse.y - y) / 500).clamp(-0.2, 0.2) + angle * Math.PI / 180;
		}
		else
		{
			ang = ((FlxG.mouse.x - x) / 500).clamp(-0.2, 0.2) + angle * Math.PI / 180;
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
	
	public function onGemPick(loco:Loco, gem:Gem)
	{
		var pick = FlxG.sound.play(SoundManager.PICKUP_SOUND, 0.5, false);
		gem.kill();
	}
}

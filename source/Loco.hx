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
class Loco extends FlxSprite
{
	private var map:GameMap;
	private var light:LightSource;
	public var speed = 100;
	
	private var _tx:Int = Std.int(Math.NaN);
	private var _ty:Int = Std.int(Math.NaN);
	
	private var _first:Bool = true;
	private var _next:Int;
	
	public function new(map:GameMap, lights:FlxTypedGroup<LightSource>, X:Float, Y:Float) 
	{
		super(X, Y);
		makeGraphic(GameMap.TILE_SIZE, GameMap.TILE_SIZE, FlxColor.GREEN, true);
		
		light = new LightSource(map, X, Y + GameMap.TILE_SIZE / 2, 70);
		light.setTarget(Std.int(X + 10000), Std.int(Y));
		lights.add(light);
				
		drag.x = drag.y = 0;
		this.map = map;
	}
	
	public function stop()
	{
		speed = 0;
	}
	
	override public function update(elapsed:Float):Void
	{
		var mA = 0;
		var tx = Std.int((x + 1e-6) / GameMap.TILE_SIZE);
		var ty = Std.int(y / GameMap.TILE_SIZE);
		
		if (tx != _tx || ty != _ty)
		{
			if (!_first && _next == Direction.NORTH)
			{
				var tdy = Std.int((y + GameMap.TILE_SIZE - 1e-6) / GameMap.TILE_SIZE);
				if (tdy == _ty)
				{
					updateLight();
					super.update(elapsed);
					return;
				}
				
				if (tdy != ty)
				{
					y = tdy * GameMap.TILE_SIZE;
					ty = Std.int(y / GameMap.TILE_SIZE);
				}
			}
			
			_first = false;
			_tx = tx;
			_ty = ty;
			
			var tileIdx = map.foreground.getTile(tx, ty);
			_next = tileIdx;
			
			switch (tileIdx) 
			{
				case Direction.NORTH:
					trace((new FlxPoint(tx, ty)) + " = NORTH " + tileIdx);
					mA = -90;
				case Direction.EAST:
					trace((new FlxPoint(tx, ty)) + " = EAST " + tileIdx);
					mA = 0;
				case Direction.SOUTH:
					trace((new FlxPoint(tx, ty)) + " = SOUTH " + tileIdx);
					mA = 90;
				case Direction.WEST:
					trace((new FlxPoint(tx, ty)) + " = WEST " + tileIdx);
					mA = 180;
				default:
					trace("STOPPING? " + tileIdx);
					speed = 0;
			}
			
			velocity.set(speed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), mA);
		}
	
		updateLight();
		super.update(elapsed);
	}
	
	private function updateLight()
	{
		var ang = ((FlxG.mouse.y - y) / 1000).clamp(-0.1, 0.1);
		light.x = x;
		light.y = y + GameMap.TILE_SIZE / 2;
		light.angle = ang;
		light.setSpan(Std.int(light.x + Math.cos(light.angle) * 10000), Std.int(light.y + Math.sin(light.angle) * 10000));
		light.force();
	}
}

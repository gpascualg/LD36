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
class Wagon extends FlxSprite
{
	public static inline var ACELERATION:Float = 1;
	public static inline var MAX_SPEED:Float = 300;
	public static inline var MIN_SPEED:Float = 10;
	
	private var _tx:Int = Std.int(Math.NaN);
	private var _ty:Int = Std.int(Math.NaN);
	private var _first:Bool = true;
	private var _last:Int = -1;
	private var _next:Int = -1;
	private var _target:Int = 0;
	
	public var map:GameMap;
	public var speed:Float = MIN_SPEED;
	private var previous:Wagon;
	
	public function new(map:GameMap, X:Float, Y:Float, asset:String, ?previous:Wagon=null)
	{
		super(X, Y);
		loadGraphic(asset);
		drag.x = drag.y = 0;
		
		this.map = map;
		this.previous = previous;
	}
	
	override public function update(elapsed:Float):Void
	{
		var mA = 0;
		var tx = Std.int((x + 1e-6) / GameMap.TILE_SIZE);
		var ty = Std.int(y / GameMap.TILE_SIZE);
		
		if (previous != null)
		{
			if (_first)
			{
				var ptx = Std.int((previous.x + 1e-6) / GameMap.TILE_SIZE);
				var pty = Std.int(previous.y / GameMap.TILE_SIZE);
				var ptx2 = Std.int((previous.x + GameMap.TILE_SIZE - 1e-6) / GameMap.TILE_SIZE);
				var pty2 = Std.int((previous.y + GameMap.TILE_SIZE - 1e-6) / GameMap.TILE_SIZE);
				
				if ((tx == ptx && ty == pty) || (tx == ptx2 && ty == pty2))
				{
					super.update(elapsed);
					return;
				}
			}
			
			speed = previous.speed;
		}
				
		if (_target != angle)
		{
			var dAng = 2;
			angle += _target < angle ? -dAng : dAng;
		}
		
		if (tx != _tx || ty != _ty)
		{
			if (!_first && _next == Direction.NORTH)
			{
				var tdy = Std.int((y + GameMap.TILE_SIZE - 1e-6) / GameMap.TILE_SIZE);
				if (tdy == _ty)
				{
					super.update(elapsed);
					return;
				}
				
				if (tdy != ty)
				{
					y = tdy * GameMap.TILE_SIZE;
					ty = Std.int(y / GameMap.TILE_SIZE);
				}
			}
			else if (!_first && _next == Direction.WEST)
			{
				var tdx = Std.int((x + GameMap.TILE_SIZE - 1e-6) / GameMap.TILE_SIZE);
				if (tdx == _tx)
				{
					super.update(elapsed);
					return;
				}
				
				if (tdx != tx)
				{
					x = tdx * GameMap.TILE_SIZE;
					tx = Std.int(x / GameMap.TILE_SIZE);
				}
				
				y = _ty * GameMap.TILE_SIZE; // Fix Y?
			}
			
			_first = false;
			_tx = tx;
			_ty = ty;
			
			var tileIdx = map.foreground.getTile(tx, ty);
			_last = _next;
			_next = tileIdx;
			
			switch (tileIdx) 
			{
				case Direction.NORTH:
					trace((new FlxPoint(tx, ty)) + " = NORTH " + tileIdx);
					mA = -90;
					if (_last == -1) angle = _target = -90;
					else if (_last == Direction.EAST) _target -= 90
					else if (_last != Direction.NORTH) _target += 90;
					
				case Direction.EAST:
					trace((new FlxPoint(tx, ty)) + " = EAST " + tileIdx);
					mA = 0;
					if (_last == -1) angle = _target = 0;
					else if (_last == Direction.NORTH) _target += 90
					else if (_last != Direction.EAST) _target -= 90;
					
				case Direction.SOUTH:
					trace((new FlxPoint(tx, ty)) + " = SOUTH " + tileIdx);
					mA = 90;
					if (_last == -1) angle = _target = 90;
					else if (_last == Direction.EAST) _target += 90
					else if (_last != Direction.SOUTH) _target -= 90;
					
				case Direction.WEST:
					trace((new FlxPoint(tx, ty)) + " = WEST " + tileIdx);
					mA = -180;
					if (_last == -1) angle = _target = -180;					
					else if (_last == Direction.NORTH) _target -= 90
					else if (_last != Direction.WEST) _target += 90;
					
				default:
					trace("STOPPING at " + (new FlxPoint(tx, ty)) + "? " + tileIdx);
					speed = 0;
					PlayState.GameOver();
			}
			
			velocity.set(speed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), mA);
		}
		
		super.update(elapsed);
	}
}
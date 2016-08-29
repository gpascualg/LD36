package;

import flash.geom.Point;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

import Railway;
import GameMap;

using Main.FloatExtender;

class Wagon extends FlxSprite
{
	public static inline var ACELERATION:Float = 500;
	public static inline var MAX_SPEED:Float = 5000;
	public static inline var MIN_SPEED:Float = 1000;
	
	private var _tx:Int = Std.int(Math.NaN);
	private var _ty:Int = Std.int(Math.NaN);
	public var _first:Bool = true;
	public var _previous:Railway = null;
	public var _current:Railway = null;
	private var _last:Int = -1;
	private var _next:Int = -1;
	private var _target:Int = 0;
	private var mA:Float = 0;
	private var realMA:Float = 0;
	
	public var map:GameMap;
	public var speed:Float = MIN_SPEED;
	public var realSpeed:Float = 0;
	private var previous:Wagon = null;
	public var next:Wagon = null;
	
	public function new(map:GameMap, X:Float, Y:Float, asset:String, ?previous:Wagon=null)
	{
		super(X, Y);
		loadGraphic(asset);
		drag.x = drag.y = 0;
		
		if (previous != null)
		{
			previous.next = this;
		}
		
		this.map = map;
		this.previous = previous;
	}
	
	public function init(X:Float, Y:Float)
	{
		x = X;
		y = Y;
	}
	
	public function resetWagon(X:Float, Y:Float, ?resetSpeed:Bool=false)
	{
		x = X;
		y = Y;
		_first = true;
		_last = _next = -1;
		_tx = Std.int(Math.NaN);
		_ty = Std.int(Math.NaN);
		_current = _previous = null;
		
		if (resetSpeed)
		{
			mA = realMA = 0;
			speed = 0;
			realSpeed = 0;
			velocity.set(speed, 0);
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		var tx = Std.int((x + 1e-6) / GameMap.TILE_SIZE);
		var ty = Std.int(y / GameMap.TILE_SIZE);
		
		#if debug
		if (FlxG.keys.justPressed.F)
		{
			speed = MAX_SPEED;
		}
		#end
		
		if (_first)
		{
			_current = map.getRailAt(tx, ty);
			_last = _next = _current.direction;
		}
		
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
					updateSpeed(elapsed);
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
					updateSpeed(elapsed);
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
			
			_tx = tx;
			_ty = ty;
			
			if (_current == null)
			{
				// Make sure the user didn't put one at last minute
				_current = map.getRailAt(tx, ty);
				
				if (_current == null)
				{
					trace("STOPPING at " + (new FlxPoint(tx, ty)) + _last + " ? " + _next);				
					PlayState.instance.GameOver();
					return;
				}
			}
			
			_last = _next;
			_next = _current.nextDirection(_last);
			trace("At " + (new FlxPoint(tx, ty)) + _next);
			_previous = _current;
			_current = _current.nextRail(_last);
			
			switch (_next) 
			{
				case Direction.NORTH:
					mA = -90;
					if (_first) angle = _target = -90;
					else if (_last == Direction.EAST) _target -= 90
					else if (_last != Direction.NORTH) _target += 90;
					
				case Direction.EAST:
					mA = 0;
					if (_first) angle = _target = 0;
					else if (_last == Direction.NORTH) _target += 90
					else if (_last != Direction.EAST) _target -= 90;
					
				case Direction.SOUTH:
					mA = 90;
					if (_first) angle = _target = 90;
					else if (_last == Direction.EAST) _target += 90
					else if (_last != Direction.SOUTH) _target -= 90;
					
				case Direction.WEST:
					mA = -180;
					if (_first) angle = _target = -180;					
					else if (_last == Direction.NORTH) _target -= 90
					else if (_last != Direction.WEST) _target += 90;
					
				default:
					trace("SHOULD NOT BE HERE!! at " + (new FlxPoint(tx, ty)) + "? " + _next);
					speed = 0;
					PlayState.instance.GameOver();
			}
			
			_first = false;
		}
		
		updateSpeed(elapsed);		
		super.update(elapsed);
	}
	
	public function updateSpeed(elapsed:Float)
	{
		if (realMA != mA || speed != realSpeed || (previous != null && realSpeed != previous.realSpeed))
		{
			// Loco sets speed
			if (previous == null)
			{
				realSpeed = speed;
			}
			else
			{
				realSpeed = previous.realSpeed;
			}
			
			realMA = mA;
			velocity.set(realSpeed * elapsed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), realMA);
		}
	}
	
	public function previousRail(?startInCurrent:Bool=true):Railway
	{		
		if (startInCurrent && _current != null)
		{
			return _current.previousRail(_next);
		}
		
		if (_previous != null)
		{
			return _previous.previousRail(_last);
		}
		
		return null;
	}
	
	public function nextRails(?canEndInCurve:Bool=true, ?startInCurrent:Bool=false):RailInfo
	{
		if (!startInCurrent && _previous != null)
		{
			return _previous.nextRails(_last, canEndInCurve);
		}
		
		if (_current != null)
		{
			return _current.nextRails(_next, canEndInCurve);
		}
		
		return new RailInfo(new Array<RailCombo>(), false);
	}
}

package;

import flash.geom.Point;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
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
class LightSource extends FlxNapeSprite
{
	private var map:GameMap;
	private var lastX:Int = 0;
	private var lastY:Int = 0;
	
	private var lastAngle:Float = 0;
	private var angleChanged:Bool = false;
	private var lastPoint:FlxPoint = new FlxPoint();
	public var lastTile:FlxPoint = new FlxPoint();
	
	public var enabled:Bool;
	public var span:Int;
	public var endX:Int;
	public var endY:Int;
	public var thickness:Int = 1;
	public var connection:Mirror = null;
	
	public function new(map:GameMap, X:Float, Y:Float, ?thickness:Int=1, ?enabled:Bool=true) 
	{
		super(X, Y, null, true, true);
		loadGraphic("assets/images/gem.png", true, 16, 16);
		animation.add("glitter", [0, 1, 2], 1);
		animation.play("glitter");
		
		createRectangularBody(16, 16, BodyType.DYNAMIC);
		body.setShapeMaterials(Material.ice());
		
		body.userData.type = "Gem";
		
		this.map = map;
		this.thickness = thickness;
		this.enabled = enabled;
	}
	
	override public function update(elapsed:Float):Void
	{
		handleGlitterEffect();
		super.update(elapsed);
	}
	
	public function setTarget(endX:Int, endY:Int):Void
	{
		endX -= Math.round(thickness / 2);
		setSpan(endX, endY);
		
		angle = Math.atan2(endY - y, endX - x);
		if (angle != lastAngle)
		{
			lastAngle = angle;
			angleChanged = true;
		}
		else
		{
			angleChanged = false;
		}
	}
	
	public function setSpan(endX:Int, endY:Int):Void
	{
		this.span = Math.round(Math.sqrt(Math.pow(x - endX, 2) + Math.pow(y - endY, 2)));	
		this.endX = endX;
		this.endY = endY;	
	}
	
	public function limitSpan(endX:Int, endY:Int):FlxPoint
	{
		setTarget(endX, endY);
		var endPoint = castLine();
		setSpan(Std.int(endPoint.x), Std.int(endPoint.y));
		return endPoint;
	}
	
	public function force()
	{
		angleChanged = true;
	}
	
	public function castLine(?verbose:Bool=false):FlxPoint
	{		
		if (angleChanged)
		{
			lastPoint = null;
			angleChanged = false;
			var ang = angle - 0.1;
			var mirror:Mirror = null;
			while (ang < angle + 0.1)
			{
				var dx = Math.cos(ang) * GameMap.TILE_SIZE;
				var dy = Math.sin(ang) * GameMap.TILE_SIZE;
				ang += 0.05;
				
				if (dx == 0 && dy == 0)
				{
					continue;
				}
				
				var ix = x;
				var iy = y;				
								
				var gtX = (dx < 0) ? endX : 0;
				var ltX = (dx < 0) ? FlxG.width : endX;			
				
				var gtY = (dy < 0) ? endY : 0;
				var ltY = (dy < 0) ? FlxG.height : endY;
				
				while (ix < ltX && ix > gtX && iy < ltY && iy > gtY)
				{
					var tx = Std.int(ix / GameMap.TILE_SIZE);
					var ty = Std.int(iy / GameMap.TILE_SIZE);
					
					if (tx >= map.foreground.widthInTiles - 1 || ty >= map.foreground.heightInTiles - 1 || tx <= 0 || ty <= 0)
					{
						ix += dx;
						iy += dy;
						continue;
					}
					
					// Avoid self-tile
					if (tx == Std.int(x / GameMap.TILE_SIZE) && ty == Std.int(y / GameMap.TILE_SIZE))
					{
						ix += dx;
						iy += dy;
						continue;						
					}
					
					var isMirror = map.mirrors[ty][tx];
					var tileIdx = map.foreground.getTile(tx, ty);
					
					if (isMirror != null)
					{
						var newPoint = new FlxPoint(ix, iy);
						if (lastPoint == null || newPoint.distanceTo(getPosition()) < lastPoint.distanceTo(getPosition()))
						{
							lastPoint = new FlxPoint(newPoint.x, newPoint.y);
							mirror = isMirror;
						}
					}
					else if (tileIdx == Prop.BARREL)
					{
						var newPoint = new FlxPoint(ix + dx * 2.0, iy + dy * 2.0);
						if (lastPoint == null || newPoint.distanceTo(getPosition()) < lastPoint.distanceTo(getPosition()))
						{
							lastTile = new FlxPoint(tx, ty);
							lastPoint = new FlxPoint(newPoint.x, newPoint.y);
						}
						break;
					}
					
					ix += dx;
					iy += dy;
				}
			}
			
			if (verbose)
			{
				trace("Light limiting:\nPoint: " + lastPoint + "\nConnection: " + connection);
			}
				
			if (lastPoint == null)
			{
				lastPoint = new FlxPoint(endX, endY);
			}
			else if (connection != null)
			{
				connection.disconnect();
			}
			
			if (mirror != null)
			{
				mirror.connect(this);
			}
		}
		
		return lastPoint;			
	}
	
	private function handleGlitterEffect():Void
	{
		var moved = Std.int(x) != lastX || Std.int(y) != lastY;
		if (moved)
			animation.curAnim.resume();
		else
			animation.curAnim.pause();
		
		lastX = Std.int(x);
		lastY = Std.int(y);
	}
}
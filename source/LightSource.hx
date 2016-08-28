package;

import flash.geom.Point;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxGradient;
import flixel.util.FlxColor;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;

import GameMap;

using Main.FloatExtender;
using flixel.util.FlxSpriteUtil;

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
	
	private var canvas:FlxSprite;
	private var lastAngle:Float = 0;
	private var angleChanged:Bool = false;
	private var lastPoint:FlxPoint = new FlxPoint();
	public var lastTile:FlxPoint = new FlxPoint();
	
	public var enabled:Bool;
	public var span:Int;
	public var endX:Int;
	public var endY:Int;
	public var thickness:Int = 1;
	public var type:LightType;
	public var connection:Mirror = null;
	
	public function new(map:GameMap, canvas:FlxSprite, X:Float, Y:Float, ?thickness:Int=1, ?type:LightType=LightType.LINE, ?enabled:Bool=true) 
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
		this.canvas = canvas;
		this.type = type;
	}
	
	override public function update(elapsed:Float):Void
	{
		handleGlitterEffect();
		super.update(elapsed);
	}
	
	public function setTarget(endX:Int, endY:Int):Void
	{
		if (type == LightType.LINE)
		{
			endX -= Math.round(thickness / 2);
		}
		
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
	
	public function castLine():FlxPoint
	{
		var mirror:Mirror = null;
		lastPoint = null;
			
		//if (angleChanged)
		if (type == LightType.LINE || type == LightType.CONE)
		{
			angleChanged = false;
			var ang = angle - 0.1;
			
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
		}
		else if (type == LightType.SPOT || type == LightType.CONCENTRIC_SPOT)
		{
			var x = Std.int(x / GameMap.TILE_SIZE);
			var y = Std.int(y / GameMap.TILE_SIZE);
			
			var dx = Std.int(thickness / GameMap.TILE_SIZE);
			var dy = Std.int(thickness / GameMap.TILE_SIZE);
			
			for (cx in -(dx + 1)...(dx + 1))
			{
				for (cy in -(dy + 1)...(dy + 1))
				{
					var tx = x + cx;
					var ty = y + cy;
					
					if (tx >= map.foreground.widthInTiles - 1 || ty >= map.foreground.heightInTiles - 1 || tx <= 0 || ty <= 0)
					{
						continue;
					}
					
					var isMirror = map.mirrors[ty][tx];
					if (isMirror != null)
					{
						var newPoint = new FlxPoint(tx, ty);
						if (lastPoint == null || newPoint.distanceTo(getPosition()) < lastPoint.distanceTo(getPosition()))
						{
							lastPoint = new FlxPoint(newPoint.x, newPoint.y);
							mirror = isMirror;
						}
					}
				}
			}
		}
			
		if (lastPoint == null)
		{
			lastPoint = new FlxPoint(endX, endY);
		}
		
		if (mirror != null)
		{
			mirror.connect(this);
		}
		else if (connection != null)
		{
			connection.disconnect();
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
	
	public function drawLight()
	{
		switch (type) 
		{
			case LightType.LINE:
				drawLightLine();
			
			case LightType.SPOT:
				drawLightSpot(false);	
			
			case LightType.CONCENTRIC_SPOT:
				drawLightSpot(true);
				
			case LightType.CONE:
				drawLightCone();
		}
	}
	
	private function drawLightSpot(concentric:Bool):Void
	{
		var alpha = 0x00;
		var radius = thickness;
		var counter = 0;
		var maxCounter = thickness > 100 ? 5 : 20;
		var da = Math.round(thickness > 100 ? 256 / maxCounter : 20);
		
		while (alpha < 0xFF && radius > 0 && counter < maxCounter)
		{
			canvas.drawCircle(x + (concentric ? 0 : 1) * radius / 2, y + (concentric ? 0 : 1) * radius / 2, radius, (alpha << 24) | 0xFFFFFF);
			
			alpha += da;
			radius -= 10;
			++counter;
		}
	}
	
	private function drawLightLine():Void
	{
		var gradient = FlxGradient.createGradientFlxSprite(thickness, span, [FlxColor.BLACK, FlxColor.WHITE, FlxColor.BLACK], 1, 0);
		gradient.origin.set(thickness / 2, 0);
		gradient.angle = angle * 180.0 / Math.PI - 90;
		canvas.stamp(gradient, Std.int(x), Std.int(y));
		gradient.destroy();
	}
		
	private function drawLightCone():Void
	{
		var aperture = 0.5;
		var alpha = 0x00;
		
		while (aperture > 0 && alpha < 0xFF) 
		{
			var ro  = angle - aperture;
			var beta = angle + aperture;
		
			canvas.drawPolygon([getPosition(), 
								new FlxPoint(x + span * Math.cos(beta), y + Math.sin(beta) * span), 
								new FlxPoint(x + span * Math.cos(ro), y + Math.sin(ro) * span), 
								getPosition()], (alpha << 24) | 0xFFFFFF);
								
			aperture -= 0.05;
			alpha += 20;
		}
	}
}

@:enum
abstract LightType(Int) to Int
{
	var SPOT = 0;
	var LINE = 1;
	var CONCENTRIC_SPOT = 2;
	var CONE = 3;
}

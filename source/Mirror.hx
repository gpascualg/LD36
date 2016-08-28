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

import LightSource;
import GameMap;

using Main.FloatExtender;

class Mirror extends FlxSprite
{
	private var map:GameMap;
	private var lightIn:LightSource;
	private var lightOut:LightSource;
	
	public function new(map:GameMap, lights:FlxTypedGroup<LightSource>, canvas:FlxSprite, X:Float, Y:Float) 
	{
		super(X, Y);
		makeGraphic(GameMap.TILE_SIZE, 5, FlxColor.RED, true);
		
		lightOut = new LightSource(map, canvas, X, Y, 1, LightType.CONE, false);
		lights.add(lightOut);
	}
	
	override public function update(elapsed:Float):Void
	{		
		if (FlxG.keys.anyPressed([T]))
		{
			angle += 1;
		}
		
		super.update(elapsed);
	}
	
	public function connect(source:LightSource):Void
	{
		lightIn = source;
		lightIn.connection = this;
		
		var rad = (angle % 360) * Math.PI / 180;
		var abs = Math.abs(rad - lightIn.angle);
		//trace("Mirror: " + (angle * Math.PI / 180) + " Light:" + lightIn.angle + ' = ' + abs);
		if (abs < Math.PI || abs > Math.PI * 2)
		{
			lightOut.thickness = lightIn.thickness - 10;
			lightOut.enabled = true;
			
			if (lightIn.type == LightType.LINE || lightIn.type == LightType.CONE)
			{
				lightOut.angle = rad - lightIn.angle;
			}
			else
			{
				lightOut.angle = rad - Math.PI / 4.0;
			}
			
			lightOut.setTarget(Math.round(lightOut.x + Math.cos(lightOut.angle) * 10000), Math.round(lightOut.x + Math.sin(lightOut.angle) * 10000));
		}
		else
		{
			lightOut.enabled = false;
		}
	}
	
	public function disconnect():Void
	{
		lightOut.enabled = false;
	}
}

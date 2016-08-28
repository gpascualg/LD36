package;

import flash.display.InteractiveObject;
import flash.geom.Point;
import flash.media.Sound;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

import LightSource;
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
	private var sound:FlxSound;

	public function new(map:GameMap, lights:FlxTypedGroup<LightSource>, canvas: FlxSprite, X:Float, Y:Float) 
	{
		super(map, X, Y, "assets/images/train/train-head.png");
		
		new FlxTimer().start(1.0, expluseSmoke, 0);	
		light = new LightSource(map, canvas, X, Y + GameMap.TILE_SIZE / 2, 70, LightType.CONE);
		light.setTarget(Std.int(X + 10000), Std.int(Y));
		lights.add(light);
		
		sound = FlxG.sound.load(SoundManager.LOCO_SOUND, 0.3, true);
		sound.play();
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
		if (_next == Direction.EAST || _next == Direction.WEST)
		{
			var sign =_next == Direction.WEST ? -1 : 1;
			ang = ((FlxG.mouse.y - y) * sign / 500).clamp(-0.2, 0.2) + angle * Math.PI / 180;
		}
		else
		{
			var sign = _next == Direction.SOUTH ? -1 : 1;
			ang = ((FlxG.mouse.x - x) * sign / 500).clamp(-0.2, 0.2) + angle * Math.PI / 180;
		}
		
		var cx = x + GameMap.TILE_SIZE / 2.0;
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
	
	public function onGemPick(loco:Loco, gem:Gem)
	{
		if (gem.alive && gem.exists)
		{
			// Find last wagon
			var current:Wagon = this;
			while (current.next != null)
			{
				current = current.next;
			}
			
			// Set last position to be last wagon center tile
			map.endPoint.x = Std.int((current.x + GameMap.TILE_SIZE / 2.0) / GameMap.TILE_SIZE);
			map.endPoint.y = Std.int((current.y + GameMap.TILE_SIZE / 2.0) / GameMap.TILE_SIZE);
			
			// Kill gem and reset map
			var pick = FlxG.sound.play(SoundManager.PICKUP_SOUND, 0.5, false);
			gem.kill();
			
			// Adjust position (startPos is old endPos)
			//x = map.startPoint.x * GameMap.TILE_SIZE;
			//y = map.startPoint.y * GameMap.TILE_SIZE;
			//speed = 0;
		}
	}
}

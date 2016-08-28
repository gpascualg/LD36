package;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import nape.constraint.PivotJoint;
import nape.geom.Vec2;
import nape.phys.BodyType;
import nape.phys.Material;

import LightSource;

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
class Gem extends FlxSprite
{	
	private var light:LightSource;
	private var map:GameMap;
	private var lightSources:FlxTypedGroup<LightSource>;
	private var canvas:FlxSprite;
	 
	public function new(map:GameMap, lightSources:FlxTypedGroup<LightSource>, canvas:FlxSprite, X:Float, Y:Float) 
	{
		super(X, Y);
		loadGraphic("assets/images/gem.png", true, GameMap.TILE_SIZE, GameMap.TILE_SIZE);
		animation.add("glitter", [0, 1, 2], 1);
		animation.play("glitter");
		
		light = new LightSource(map, canvas, X, Y, 80, LightType.SPOT);
		lightSources.add(light);
		
		this.map = map;
		this.lightSources = lightSources;
		this.canvas = canvas;
		
		setSize(30, 30);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	override public function kill():Void
	{
		alive = false;
		FlxTween.tween(this, { alpha: 0, y: y - 16 }, .33, { ease: FlxEase.circOut });
		FlxTween.tween(light, { thickness: 1 }, 2, { ease: FlxEase.circOut, onComplete: finishKill });
		
		map.createRandomPath(lightSources, canvas, null, map.endPoint, !map.inverted);
	}

	private function finishKill(_):Void
	{
		exists = false;
		light.kill();
	}
}
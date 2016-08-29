package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;

import LightSource;

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
		#if (flash && debug)
			finishKill(null);
		#else
			FlxTween.tween(this, { alpha: 0, y: y - 16 }, .33, { ease: FlxEase.circOut });
			FlxTween.tween(light, { thickness: 1 }, 2, { ease: FlxEase.circOut, onComplete: finishKill });
		#end
		
		map.createRandomPath(lightSources, canvas, null, map.endPoint, !map.inverted);
	}

	private function finishKill(_):Void
	{
		exists = false;
		light.kill();
	}
}
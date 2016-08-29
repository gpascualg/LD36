package;

import flixel.FlxG;
import flixel.system.FlxSound;

/**
 * ...
 * @author j
 */
class SoundManager
{
#if !flash
	public static var BG_MUSIC:Array<String> = [
		"assets/sounds/background.ogg",
		"assets/sounds/background2.ogg",
		"assets/sounds/background3.ogg",
	];
#else
	public static var BG_MUSIC:Array<String> = [
		"assets/sounds/background.mp3",
		"assets/sounds/background2.mp3",
		"assets/sounds/background3.mp3",
	];
#end

	public static inline var DEATH_SOUND:String = "assets/sounds/Explode.wav";
	public static inline var PICKUP_SOUND:String = "assets/sounds/done.wav";	
	public static inline var LOCO_SOUND:String = "assets/sounds/LocoSound.wav";
	
	public static var sound:Bool = false;
	private static var n:Int = 0;
	
	public static function PlayBackgroundMusic():Void
	{
		if (!sound)
		{
			sound = true;
			FlxG.sound.playMusic(SoundManager.BG_MUSIC[n], 1, false);
			FlxG.sound.music.onComplete = onSoundComplete;
		}
	}
	
	public static function onSoundComplete()
	{
		n = (n + 3) % BG_MUSIC.length;
		FlxG.sound.playMusic(SoundManager.BG_MUSIC[n], 1, false);
		FlxG.sound.music.onComplete = onSoundComplete;
	}
}
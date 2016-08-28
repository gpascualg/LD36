package;

import flixel.FlxG;

/**
 * ...
 * @author j
 */
class SoundManager
{
	
	public static inline var BG_MUSIC_OGG:String = "assets/sounds/background.ogg";
	public static inline var BG_MUSIC_MP3:String = "assets/sounds/background.mp3";
	
	public static inline var DEATH_SOUND:String = "assets/sounds/Explode.wav";
	public static inline var PICKUP_SOUND:String = "assets/sounds/done.wav";
	
	public static inline var LOCO_SOUND:String = "assets/sounds/LocoSound.wav";
	
	public static var isPlaying:Bool = false;
	
	public static function PlayBackgroundMusic():Void
	{
		if (isPlaying) return;
				
		#if flash
			FlxG.sound.playMusic(SoundManager.BG_MUSIC_MP3, 1, true);
		#else
			FlxG.sound.playMusic(SoundManager.BG_MUSIC_OGG, 1, true);
		#end
		
		isPlaying = true;
		
	}
	
}
package;

/**
 * ...
 * @author j
 */
class StatsManager
{
	public static var secondsResisted:Float = 0;
	public static var gemsTaken:Int = 0; 
	
	public static function ResetStats():Void
	{
		gemsTaken = 0;
		secondsResisted = 0;
	}	
}
package minesweeper.pxlSq;

#if flash
import flash.external.ExternalInterface;
#end

/**
 * ...
 * @author Anthony Ganzon
 * Console logger for debugging purposes.
 * NOTE: Works only with flash build
 */
class Utils
{
	#if flash
	public static function ConsoleLog(str: String) {
		ExternalInterface.call("console.log", str);
	}
	#else
	public static function ConsoleLog(str: String) {
		trace(str);
	}
	#end
}

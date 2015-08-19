package minesweeper.core;

import minesweeper.main.MSMain;
import minesweeper.main.MSBlock;
import minesweeper.name.GameData;

/**
 * ...
 * @author Anthony Ganzon
 */
class Utils
{
	public static function ToMMSS(ms: Float): String {		
		var sec: Int = Std.int((ms % 3600) % 60);
		var secStr: String = (sec < 10) ? "0" + sec : "" + sec;
		
		var min = Std.int((ms % 3600) / 60);
		var minStr: String = (min < 10) ? "0" + min : "" + min;
		
		//var hr = Std.int(ms / 3600);
		//var hrStr: String = (hr < 10) ? "0" + hr : "" + hr;
		
		return minStr + ":" + secStr;
	}
	
	public static function GetBlockNeighbors(block: MSBlock): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		
		var curX: Int = block.idx;
		var curY: Int = block.idy;
		
		var x: Int = -1;
		while (x <= 1) {
			var y: Int = -1;
			while (y <= 1) {
				var row: Int = curX + x;
				var col: Int = curY + y;
				
				if ((row == curX && col == curY) ||	(row < 0 || col < 0) ||
					(row > (GameData.GAME_GRID_ROWS - 1) ||	col > (GameData.GAME_GRID_COLS - 1))) {
					y++;
					continue;
				}
				
				result.push(MSMain.current.boardBlocks[row][col]);				
				y++;
			}
			x++;
		}
		
		return result;
	}
	
	public static function OpenNeighbors(block: MSBlock): Void {
		for (neighbor in Utils.GetBlockNeighbors(block)) {
			if (!neighbor.isRevealed) {
				neighbor.SetIsRevealed(true);
			}
		}
	}
	
	public static function GetRevealedBlocks(): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		for (ii in 0...MSMain.current.boardBlocks.length) {
			for (blocks in MSMain.current.boardBlocks[ii]) {
				if (blocks.isRevealed) {
					result.push(blocks);
				}
			}
		}
		
		return result;
	}
}
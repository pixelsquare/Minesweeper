package minesweeper;

import minesweeper.main.MSBlock;
import minesweeper.name.GameData;
import minesweeper.main.MSMain;

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
		var blocks: Array<Array<MSBlock>> = MSMain.current.boardBlocks;
		
		var x: Int = block.idx;
		var y: Int = block.idy;
		
		if (y == 0) {
			if (x == 0) {
				result.push(blocks[x + 1][y]);
				result.push(blocks[x][y + 1]);
				result.push(blocks[x + 1][y + 1]);
			}
			else if (x == (GameData.GAME_GRID_ROWS - 1)) {
				result.push(blocks[x - 1][y]);
				result.push(blocks[x - 1][y + 1]);
				result.push(blocks[x][y + 1]);
			}
			else {
				result.push(blocks[x][y + 1]);
				result.push(blocks[x - 1][y]);
				result.push(blocks[x + 1][y]);
				result.push(blocks[x - 1][y+ 1]);
				result.push(blocks[x + 1][y + 1]);
			}
		}
		else if (y == (GameData.GAME_GRID_COLS - 1)) {
			if (x == 0) {
				result.push(blocks[x + 1][y - 1]);
				result.push(blocks[x + 1][y]);
				result.push(blocks[x][y - 1]);
			}
			else if (x == (GameData.GAME_GRID_ROWS - 1)) {
				result.push(blocks[x - 1][y-1]);
				result.push(blocks[x - 1][y]);
				result.push(blocks[x][y - 1]);
			}
			else {
				result.push(blocks[x - 1][y - 1]);
				result.push(blocks[x + 1][y - 1]);
				result.push(blocks[x - 1][y]);
				result.push(blocks[x + 1][y]);
				result.push(blocks[x][y - 1]);				
			}
		}
		else {
			if (x == 0) {
				result.push(blocks[x + 1][y - 1]);
				result.push(blocks[x + 1][y]);
				result.push(blocks[x + 1][y + 1]);
				result.push(blocks[x][y - 1]);
				result.push(blocks[x][y + 1]);	
			}
			else if (x == (GameData.GAME_GRID_ROWS - 1)) {
				result.push(blocks[x - 1][y - 1]);
				result.push(blocks[x - 1][y]);
				result.push(blocks[x - 1][y + 1]);
				result.push(blocks[x][y - 1]);
				result.push(blocks[x][y + 1]);	
			}
			else {
				result.push(blocks[x - 1][y - 1]);
				result.push(blocks[x + 1][y - 1]);
				result.push(blocks[x - 1][y]);
				result.push(blocks[x + 1][y]);
				result.push(blocks[x - 1][y + 1]);
				result.push(blocks[x + 1][y + 1]);
				result.push(blocks[x][y - 1]);
				result.push(blocks[x][y + 1]);
			}
		}
		
		return result;
	}
	
	public static function OpenNeighbors(block: MSBlock): Void {
		var blocks: Array<Array<MSBlock>> = MSMain.current.boardBlocks;
		var neighbors: Array<MSBlock> = GetBlockNeighbors(block);
		for (neighbor in neighbors) {
			if (!neighbor.isOpened) {
				neighbor.SetBlockOpen(true);
			}
		}
	}
}
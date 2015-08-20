package minesweeper.main;

import minesweeper.main.MSBlock;
import minesweeper.name.GameData;

/**
 * ...
 * @author Anthony Ganzon
 */
class MSUtils
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
	
	public static function GetNeighborBlocks(block: MSBlock, blocks: Array<Array<MSBlock>>): Array<MSBlock> {
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
				
				result.push(blocks[row][col]);				
				y++;
			}
			x++;
		}
		
		return result;
	}
	
	public static function OpenNeighborBlocks(block: MSBlock, blocks: Array<Array<MSBlock>>): Void {
		for (block in GetNeighborBlocks(block, blocks)) {
			if (!block.IsBlockRevealed() && !block.IsBlockMarked()) {
				block.RevealBlock();
			}
		}
	}
	
	public static function GetRevealedBlocks(blocks: Array<MSBlock>): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		
		for (block in blocks) {
			if (block.IsBlockRevealed()) {
				result.push(block);
			}
		}		
		
		return result;
	}
	
	public static function GetAllNonBombBlocks(blocks: Array<MSBlock>): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		
		for (block in blocks) {
			if (!block.IsBlockHasBomb()) {
				result.push(block);
			}
		}
		
		return result;
	}
	
	public static function GetAllBombBlocks(blocks: Array<MSBlock>): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		
		for (block in blocks) {
			if (block.IsBlockHasBomb()) {
				result.push(block);
			}
		}
		
		return result;
	}
	
	public static function RevealAllNonBombs(blocks: Array<MSBlock>): Void {
		for (block in GetAllNonBombBlocks(blocks)) {
			block.RevealBlock(true);
		}
	}
	
	public static function RevealAllBombs(blocks: Array<MSBlock>): Void {
		for (block in GetAllBombBlocks(blocks)) {
			block.RevealBlock(true);
		}
	}
	
	public static function RevealAllBlocks(blocks: Array<MSBlock>): Void {
		for (block in blocks) {
			block.RevealBlock(true);
		}
	}
	
	public static function GetAllUnMarkedBlocks(blocks: Array<MSBlock>): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		for (block in blocks) {
			if (!block.IsBlockMarked()) {
				result.push(block);
			}
		}
		return result;
	}
	
	public static function GetAllMarkedBlocks(blocks: Array<MSBlock>): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		for (block in blocks) {
			if (block.IsBlockMarked()) {
				result.push(block);
			}
		}
		return result;
	}
	
	public static function GetUnMarkedBombBlocks(blocks: Array<MSBlock>): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		for (block in GetAllBombBlocks(blocks)) {
			if (!block.IsBlockMarked()) {
				result.push(block);
			}
		}
		return result;
	}
	
	public static function GetMarkedBombBlocks(blocks: Array<MSBlock>): Array<MSBlock> {
		var result: Array<MSBlock> = new Array<MSBlock>();
		for (block in GetAllBombBlocks(blocks)) {
			if (block.IsBlockMarked()) {
				result.push(block);
			}
		}
		return result;
	}
}
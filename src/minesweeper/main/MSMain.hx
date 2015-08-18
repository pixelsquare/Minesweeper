package minesweeper.main;

import flambe.display.Font;
import flambe.display.Sprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.asset.AssetPack;
import flambe.math.Rectangle;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.math.FMath;
import flambe.input.MouseEvent;
import flambe.input.MouseButton;

import minesweeper.name.GameData;
import minesweeper.core.DataManager;
import minesweeper.name.AssetName;

/**
 * ...
 * @author Anthony Ganzon
 */
class MSMain extends DataManager
{
	public var boardBlocks(default, null): Array<Array<MSBlock>>;
	
	private var mineSweeperEntity: Entity;
	private var bombMax: Int;
	
	public static var current: MSMain;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) { 
		super(assetPack, storage);
		current = this;
		
		this.boardBlocks = new Array<Array<MSBlock>>();
		this.bombMax = Math.round((GameData.GAME_GRID_ROWS * GameData.GAME_GRID_COLS) * 0.9);
		//minesweeper.pxlSq.Utils.ConsoleLog(bombMax + "");
	}
	
	public function Init(): Entity {
		mineSweeperEntity = new Entity();
		
		CreateBoard();
		SpawnMines();
		SetBlockValues();
		
		//System.mouse.down.connect(function(event: MouseEvent) {
			//if (event.button == MouseButton.Left) {
				//curBlock.SetBlockOpen(true);
			//}
			//
			//if (event.button == MouseButton.Right) {
				//curBlock.SetBlockMarked(true);
			//}
		//});
		
		return mineSweeperEntity;
	}
	
	private function CreateBoard(): Void {
		var blockFont: Font = new Font(gameAsset, AssetName.FONT_BEBASNEUE_20);
		var innerTex: Texture = gameAsset.getTexture(AssetName.ASSET_PRESSED_BLOCK);
		var outerTex: Texture = gameAsset.getTexture(AssetName.ASSET_UNPRESSED_BLOCK);
		var bombTex: Texture = gameAsset.getTexture(AssetName.ASSET_BOMB);
		
		var flagTex: Texture = gameAsset.getTexture(AssetName.ASSET_FLAG);
		var questionTex: Texture = gameAsset.getTexture(AssetName.ASSET_QUESTION_MARK);
		
		var blockEntity: Entity = new Entity();
		
		for (x in 0...GameData.GAME_GRID_ROWS) {
			var blockArray: Array<MSBlock> = new Array<MSBlock>();
			for (y in 0...GameData.GAME_GRID_COLS) {
				var block: MSBlock = new MSBlock(blockFont, innerTex, outerTex, bombTex, flagTex, questionTex);
				block.SetBlockID(x, y);
				block.SetBlockXY(
					x * block.getNaturalWidth(), 
					y * block.getNaturalHeight()
				);
				
				blockArray.push(block);
				blockEntity.addChild(new Entity().add(block));
			}
			
			boardBlocks.push(blockArray);
		}
		
		var blockSprite: Sprite = new Sprite();
		blockSprite.setXY(
			System.stage.width * 0.22,
			System.stage.height * 0.115
		);
		mineSweeperEntity.addChild(blockEntity.add(blockSprite));
	}
	
	private function SpawnMines(): Void {
		var bombCounter: Int = GameData.GAME_MAX_BOMBS;
		bombCounter = FMath.clamp(bombCounter, 0, bombMax);
		
		while (bombCounter > 0) {
			var rand: Int = Math.round(Math.random() * ((GameData.GAME_GRID_ROWS * GameData.GAME_GRID_COLS) - 1));
			var row: Int = Math.floor(rand / GameData.GAME_GRID_ROWS);
			var col: Int = rand % GameData.GAME_GRID_COLS;	
			
			if (boardBlocks[row][col].hasBomb)
				continue;
			
			boardBlocks[row][col].SetBlockValue(-1);
			bombCounter--;
		}
	}
	
	private function SetBlockValues(): Void {
		var num: Int = 0;
		for (ii in 0...boardBlocks.length) {
			for (block in boardBlocks[ii]) {
				var neighbors: Array<MSBlock> = Utils.GetBlockNeighbors(block);
				var len: Int = neighbors.length;
				num = 0;
				for (jj in 0...len) {
					if (neighbors[jj].hasBomb) {
						num++;
					}
				}
				
				block.SetBlockValue(num);
			}
		}
	}
}
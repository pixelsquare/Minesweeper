package minesweeper.main;

import flambe.asset.AssetPack;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.input.MouseEvent;
import flambe.input.PointerEvent;
import flambe.subsystem.StorageSystem;
import flambe.display.Font;
import flambe.display.Texture;
import flambe.System;
import flambe.math.FMath;
import flambe.input.MouseButton;
import minesweeper.screen.GameScreen;
import minesweeper.screen.main.MainScreen;
import flambe.animation.AnimatedFloat;
import haxe.Timer;

import minesweeper.core.DataManager;
import minesweeper.name.AssetName;
import minesweeper.name.GameData;
import minesweeper.core.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class MSMain extends DataManager
{
	public var boardBlocks(default, null): Array<Array<MSBlock>>;
	public var bombCount(default, null): AnimatedFloat;
	public var markedBlocks(default, null): Int;
	public var timeElapsed(default, null): AnimatedFloat;
	public var curBlock: MSBlock;
	public var hasStarted: Bool;
	public var hasStopped: Bool;
	
	private var gameEntity: Entity;
	
	public static var current: MSMain;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
		current = this;
		
		this.bombCount = new AnimatedFloat(GameData.GAME_MAX_BOMBS);
		this.timeElapsed = new AnimatedFloat(GameData.GAME_DEFAULT_TIME);
		this.markedBlocks = 0;
		this.hasStarted = false;
		this.hasStopped = false;
		
		Init();
	}
	
	public function Init(): Void {
		gameEntity = new Entity();
		
		CreateBoard();
		SpawnBombs();
		EvaluateBlocks();
		
		if(System.mouse.supported) {
			System.mouse.down.connect(function(event: MouseEvent) {
				if (hasStopped) return;
				
				if (event.button == MouseButton.Left) {
					curBlock.SetIsRevealed(true);
					hasStarted = true;
					if (curBlock.hasBomb) {
						hasStopped = true;
					}
				}
				
				if (event.button == MouseButton.Right) {
					curBlock.SetIsMarked(true);
				}
			});
		}
		else {
			System.pointer.down.connect(function(event: PointerEvent) {
				curBlock.SetIsRevealed(true);
			});
		}
	}
	
	public function CreateBoard(): Void {
		var blockEntity: Entity = new Entity();
		boardBlocks = new Array<Array<MSBlock>>();
		
		var x: Int = 0;
		while (x < GameData.GAME_GRID_ROWS) {
			var blockArray: Array<MSBlock> = new Array<MSBlock>();
			var y: Int = 0;
			while(y < GameData.GAME_GRID_COLS) {
				var block: MSBlock = new MSBlock(
					gameAsset.getTexture(AssetName.ASSET_PRESSED_BLOCK),
					new Font(gameAsset, AssetName.FONT_BEBASNEUE_20),
					gameAsset.getTexture(AssetName.ASSET_BOMB),
					gameAsset.getTexture(AssetName.ASSET_UNPRESSED_BLOCK),
					gameAsset.getTexture(AssetName.ASSET_FLAG),
					gameAsset.getTexture(AssetName.ASSET_QUESTION_MARK)
				);
				block.SetBlockXY(
					x * block.GetNaturalWidth(),
					y * block.GetNaturalHeight()
				);
				block.SetBlockID(x, y);
				//block.SetIsRevealed(true);
				
				blockArray.push(block);
				blockEntity.addChild(new Entity().add(block));
				y++;
			}
			boardBlocks.push(blockArray);
			x++;
		}
		
		var blockSprite: Sprite = new Sprite();
		blockSprite.setXY(
			System.stage.width * 0.22,
			System.stage.height * 0.115
		);
		gameEntity.addChild(blockEntity.add(blockSprite));
	}
	
	public function SpawnBombs(): Void {
		var bombMax: Int = Math.round((GameData.GAME_GRID_ROWS * GameData.GAME_GRID_COLS) * 0.9);
		var bombCount: Int = GameData.GAME_MAX_BOMBS;
		bombCount = FMath.clamp(bombCount, 0, bombMax); 
		
		while (bombCount > 0) {
			var rand = Math.round(Math.random() * ((GameData.GAME_GRID_ROWS * GameData.GAME_GRID_COLS) - 1));
			var x: Int = Math.floor(rand / GameData.GAME_GRID_ROWS);
			var y: Int = rand % GameData.GAME_GRID_COLS;
			
			if (boardBlocks[x][y].hasBomb) {
				continue;
			}
			
			boardBlocks[x][y].SetBlockValue(-1);
			bombCount--;
		}
	}
	
	public function EvaluateBlocks(): Void {
		for (ii in 0...boardBlocks.length) {
			for (block in boardBlocks[ii]) {				
				var num: Int = 0;
				for (neighbor in Utils.GetBlockNeighbors(block)) {
					if (neighbor.hasBomb) {
						num++;
					}
				}
				
				block.SetBlockValue(num);
			}
		}
	}
	
	public function AddMarkedBlocks(amt: Int = 1): Void {
		markedBlocks += amt;
		SetBombCountDirty();

	}
	
	public function SubtractMarkedBlocks(amt: Int = 1): Void {
		markedBlocks -= amt;
		SetBombCountDirty();
	}
	
	public function SetBombCountDirty(): Void {
		bombCount._ = GameData.GAME_MAX_BOMBS - markedBlocks;
	}
	
	override public function onAdded() {
		super.onAdded();
		owner.addChild(gameEntity);
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		if (hasStarted) {
			timeElapsed._ += dt;
		}
	}
}
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
import flambe.util.Signal1.Listener1;
import flambe.util.SignalConnection;
import minesweeper.screen.GameScreen;
import minesweeper.screen.main.MainScreen;
import flambe.animation.AnimatedFloat;
import haxe.Timer;
import flambe.util.Signal1;
import minesweeper.pxlSq.Utils;

import minesweeper.core.DataManager;
import minesweeper.name.AssetName;
import minesweeper.name.GameData;
import minesweeper.core.MSUtils;
import minesweeper.core.SceneManager;

/**
 * ...
 * @author Anthony Ganzon
 */
class MSMain extends DataManager
{
	public var markedBlocks(default, null): Int;
	public var bombCount(default, null): AnimatedFloat;
	public var timeElapsed(default, null): AnimatedFloat;
	
	public var blocksOpened: Int;
	public var hasStarted: Bool;
	public var hasStopped: Bool;
	public var canMove: Bool;
	public var onMouseClick: Signal1<MSBlock>;
	
	private var gameEntity: Entity;
	private var boardBlocks: Array<Array<MSBlock>>;
	private var boardBlockList: Array<MSBlock>;
	
	// For Debugging!
	private var visualize: Bool = false;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
		
		this.markedBlocks = 0;
		this.bombCount = new AnimatedFloat(GameData.GAME_MAX_BOMBS);
		this.timeElapsed = new AnimatedFloat(GameData.GAME_DEFAULT_TIME);
		
		this.hasStarted = false;
		this.hasStopped = false;
		this.canMove = true;
		
		Init();
	}
	
	public function Init(): Void {
		gameEntity = new Entity();
		
		CreateBoard();
		SpawnBombs();
		EvaluateBlocks();
		
		// TODO: block should use pointer for phones and html version
		// try removing curBlock

		var curBlock: MSBlock = null;
		onMouseClick = new Signal1<MSBlock>();
		onMouseClick.connect(function(block: MSBlock) {
			curBlock = block;
		});
		
		if (System.mouse.supported) {
			System.mouse.down.connect(function(event: MouseEvent) {
				if (curBlock == null)
					return;
				
				if (event.button == MouseButton.Left) {
					if (canMove && !hasStopped) {
						StartGame();
						curBlock.RevealBlock();
					}
				}
				
				if (event.button == MouseButton.Right) {
					curBlock.MarkBlock();
				}
			});
		}
	}
	
	public function CreateBoard(): Void {
		var blockEntity: Entity = new Entity();
		boardBlocks = new Array<Array<MSBlock>>();
		boardBlockList = new Array<MSBlock>();
		
		var x: Int = 0;
		while (x < GameData.GAME_GRID_ROWS) {
			var blockArray: Array<MSBlock> = new Array<MSBlock>();
			var y: Int = 0;
			while(y < GameData.GAME_GRID_COLS) {
				var block: MSBlock = new MSBlock(this, visualize);
				block.Init(
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
				boardBlockList.push(block);
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
			
			if (boardBlocks[x][y].IsBlockHasBomb()) {
				continue;
			}
			
			boardBlocks[x][y].SetBlockHasBomb();
			bombCount--;
		}
	}
	
	public function EvaluateBlocks(): Void {
		for (ii in 0...boardBlocks.length) {
			for (block in boardBlocks[ii]) {				
				var num: Int = 0;
				for (neighbor in MSUtils.GetNeighborBlocks(block, boardBlocks)) {
					if (neighbor.IsBlockHasBomb()) {
						num++;
					}
				}
				
				block.SetBlockValue(num);
			}
		}
	}
	
	public function GetAllBlocks(): Array<MSBlock> {
		return boardBlockList;
	}
	
	public function GetBoardBlocks(): Array<Array<MSBlock>> {
		return boardBlocks;
	}
	
	public function StartGame(): Void {
		if (hasStarted && !hasStopped)
			return;
		
		hasStarted = true;
		hasStopped = false;
	}
	
	public function StopGame(): Void {
		if (!hasStarted && hasStopped)
			return;
		
		hasStarted = false;
		hasStopped = true;
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
	
	public function SetOpenBlocksDirty(): Void {
		this.blocksOpened = MSUtils.GetRevealedBlocks(GetAllBlocks()).length;
	}
	
	public function IsMarkedBlocksMax(): Bool {
		return markedBlocks >= GameData.GAME_MAX_BOMBS;
	}
	
	public function HasReachedGoals(): Bool {
		return ((GameData.GAME_GRID_ROWS * GameData.GAME_GRID_COLS) - GameData.GAME_MAX_BOMBS) == blocksOpened;
	}
	
	override public function onAdded() {
		super.onAdded();
		owner.addChild(gameEntity);
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (hasStarted && !hasStopped) {
			timeElapsed._ += dt;
		}
	}
}
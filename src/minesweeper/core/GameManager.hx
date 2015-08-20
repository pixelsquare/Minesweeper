package minesweeper.core;

import flambe.asset.AssetPack;
import flambe.Entity;
import flambe.subsystem.StorageSystem;

import minesweeper.main.MSMain;
import minesweeper.main.MSUtils;
import minesweeper.name.GameData;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameManager
{
	public var gameTimeElapsed(default, null): Float;
	public var gameBombCount(default, null): Int;
	
	private var gameDataManager: DataManager;
	private var minesweeperMain: MSMain;
	
	public static var current: GameManager;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {
		current = this;
		gameDataManager = new DataManager(assetPack, storage);
	}
	
	public function InitMSGame(entity: Entity): Void {
		gameTimeElapsed = GameData.GAME_DEFAULT_TIME;
		gameBombCount = GameData.GAME_MAX_BOMBS;
		
		minesweeperMain = new MSMain(gameDataManager.gameAsset, gameDataManager.gameStorage);
		minesweeperMain.bombCount.watch(function(a: Float, b: Float) {
			gameBombCount = Std.int(minesweeperMain.bombCount._);
		});
		
		minesweeperMain.timeElapsed.watch(function(a: Float, b:Float) {
			gameTimeElapsed = minesweeperMain.timeElapsed._;
		});
		entity.addChild(new Entity().add(minesweeperMain));
	}
	
	public function SetBombCountDirty(): Void {
		gameBombCount = GameData.GAME_MAX_BOMBS - MSUtils.GetMarkedBombBlocks(minesweeperMain.GetAllBlocks()).length;
	}
	
	public function GetGameDataManager(): DataManager {
		return gameDataManager;
	}
	
	public function GetMSMain(): MSMain {
		return minesweeperMain;
	}
}
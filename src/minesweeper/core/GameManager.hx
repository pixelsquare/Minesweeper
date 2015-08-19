package minesweeper.core;
import flambe.asset.AssetPack;
import flambe.Entity;
import flambe.subsystem.StorageSystem;
import flambe.animation.AnimatedFloat;
import minesweeper.main.MSMain;
import minesweeper.name.GameData;
import minesweeper.main.MSUtils;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameManager
{
	public static var gameTimeElapsed(default, null): Float;
	public static var gameBombCount(default, null): Int;
	
	private static var gameDataManager: DataManager;
	private static var minesweeperMain: MSMain;
	
	public static function Init(assetPack: AssetPack, storage: StorageSystem) {	
		gameDataManager = new DataManager(assetPack, storage);
	}
	
	public static function InitMSGame(entity: Entity) {
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
	
	public static function SetBombCountDirty(): Void {
		gameBombCount = GameData.GAME_MAX_BOMBS - MSUtils.GetMarkedBombBlocks(minesweeperMain.GetAllBlocks()).length;
	}
	
	public static function GetGameDataManager(): DataManager {
		return gameDataManager;
	}
	
	public static function GetMSMain(): MSMain {
		return minesweeperMain;
	}
}
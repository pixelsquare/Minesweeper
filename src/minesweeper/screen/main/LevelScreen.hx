package minesweeper.screen.main;

import flambe.asset.AssetPack;
import flambe.Entity;
import flambe.subsystem.StorageSystem;
import minesweeper.screen.GameScreen;
import minesweeper.name.ScreenName;

/**
 * ...
 * @author Anthony Ganzon
 */
class LevelScreen extends GameScreen
{

	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_LEVEL;
	}
}
package minesweeper.core;

import flambe.asset.AssetPack;
import flambe.subsystem.StorageSystem;
import flambe.Disposer;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameData
{
	public var gameAsset(default, null): AssetPack;
	public var gameStorage(default, null): StorageSystem;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		this.gameAsset = assetPack;
		this.gameStorage = storage;
	}
	
	//public function InitData(assetPack: AssetPack, storage: StorageSystem) {
		//this.gameAsset = assetPack;
		//this.gameStorage = storage;
	//}
}
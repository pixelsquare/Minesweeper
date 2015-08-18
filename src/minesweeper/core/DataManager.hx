package minesweeper.core;

import flambe.asset.AssetPack;
import flambe.Component;
import flambe.subsystem.StorageSystem;
import flambe.Disposer;

/**
 * ...
 * @author Anthony Ganzon
 */
class DataManager extends Component
{
	public var gameAsset(default, null): AssetPack;
	public var gameStorage(default, null): StorageSystem;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		this.gameAsset = assetPack;
		this.gameStorage = storage;
	}
}
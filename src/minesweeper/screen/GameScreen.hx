package minesweeper.screen;

import flambe.asset.AssetPack;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Disposer;
import flambe.Entity;
import flambe.scene.Scene;
import flambe.subsystem.StorageSystem;
import flambe.System;

import minesweeper.core.DataManager;
import minesweeper.name.AssetName;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameScreen extends DataManager
{	
	public var screenEntity(default, null): Entity;
	
	private var screenScene: Scene;
	private var screenDisposer: Disposer;
	
	private var screenBackground: FillSprite;
	private var screenTitleText: TextSprite;
	
	private static inline var DEFAULT_BG_COLOR: Int = 0x000000;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	public function CreateScreen(): Entity {
		screenEntity = new Entity()
			.add(screenScene = new Scene(false))
			.add(screenDisposer = new Disposer());
			
		screenBackground = new FillSprite(DEFAULT_BG_COLOR, System.stage.width, System.stage.height);
		screenEntity.addChild(new Entity().add(screenBackground));
		
		var screenTitleFont: Font = new Font(gameAsset, AssetName.FONT_VANADINE_32);
		screenTitleText = new TextSprite(screenTitleFont, GetScreenName());
		screenTitleText.centerAnchor();
		screenTitleText.setXY(
			System.stage.width / 2,
			System.stage.height / 2
		);
		screenEntity.addChild(new Entity().add(screenTitleText));
		
		return screenEntity;
	}
	
	public function ShowScreen(): Void { }
	
	public function HideScreen(): Void { }
	
	public function GetScreenName(): String {
		return "";
	}
	
	private function RemoveTitleText(): Void {
		screenEntity.removeChild(new Entity().add(screenTitleText));
	}
}
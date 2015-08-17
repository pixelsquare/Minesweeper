package minesweeper.screen.main;

import flambe.asset.AssetPack;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;

import minesweeper.core.SceneManager;
import minesweeper.name.AssetName;
import minesweeper.name.ScreenName;
import minesweeper.screen.GameScreen;

import minesweeper.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class TitleScreen extends GameScreen
{

	private var titleText: ImageSprite;
	private var playButton: ImageSprite;
	private var playButtonSprite: Sprite;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		RemoveTitleText();
		
		var titleBG: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_MENU_BG));
		screenEntity.addChild(new Entity().add(titleBG));
		
		var script: Script = new Script();
		script.run(new Sequence([
			new Delay(0.1),
			new CallFunction(function() {
				SceneManager.current.ShowPromptScreen(
					AssetName.ASSET_LOGO,
					[
						"Play", function() {
							SceneManager.current.ShowMainScreen(true);
						}
					]
				);	
			})
		]));
		screenEntity.add(script);
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_TITLE;
	}
}
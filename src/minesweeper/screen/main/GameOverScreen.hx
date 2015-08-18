package minesweeper.screen.main;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.script.AnimateTo;
import flambe.script.Parallel;

import minesweeper.name.ScreenName;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.script.Delay;
import flambe.script.CallFunction;
import minesweeper.core.SceneManager;
import minesweeper.name.AssetName;
import flambe.asset.AssetPack;
import flambe.subsystem.StorageSystem;
import flambe.System;
import minesweeper.core.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameOverScreen extends GameScreen
{

	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		screenBackground.alpha._ = 0;
		//screenBackground.alpha.animate(0, 0.5, 0.5);
		RemoveTitleText();
		
		var mainScreen: MainScreen = SceneManager.current.gameMainScreen;
		
		var bombsLeftFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
		var bombsLeftText: TextSprite = new TextSprite(bombsLeftFont, "Bombs Left ");
		bombsLeftText.alpha._ = 0;
		//bombsLeftText.alpha.animate(0, 1, 0.5);
		bombsLeftText.centerAnchor();
		bombsLeftText.setXY( 
			System.stage.width * 0.2,
			System.stage.height * 0.55
		);
		screenEntity.addChild(new Entity().add(bombsLeftText));
		
		var bombsCountFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
		var bombsCountText: TextSprite = new TextSprite(bombsCountFont, mainScreen.gameBombCount + "");
		bombsCountText.alpha._ = 0.0;
		//bombsCountText.alpha.animate(0, 1, 0.5);
		bombsCountText.centerAnchor();
		bombsCountText.setXY(
			bombsLeftText.x._,
			bombsLeftText.y._ + bombsLeftText.getNaturalHeight()
		);
		screenEntity.addChild(new Entity().add(bombsCountText));
		
		var timeElapsedFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
		var timeElapsedText: TextSprite = new TextSprite(timeElapsedFont, "Time Elapsed ");
		timeElapsedText.alpha._ = 0.0;
		//timeElapsedText.alpha.animate(0, 1, 0.5);
		timeElapsedText.centerAnchor();
		timeElapsedText.setXY(
			System.stage.width * 0.825,
			System.stage.height * 0.55
		);
		screenEntity.addChild(new Entity().add(timeElapsedText));
		
		var timeElapsedNumFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
		var timeElapsedNumText: TextSprite = new TextSprite(timeElapsedNumFont, Utils.ToMMSS(mainScreen.gameTimeElapsed) + "");
		timeElapsedNumText.alpha._ = 0.0;
		//timeElapsedNumText.alpha.animate(0, 1, 0.5);
		timeElapsedNumText.centerAnchor();
		timeElapsedNumText.setXY(
			timeElapsedText.x._,
			timeElapsedText.y._ + timeElapsedText.getNaturalHeight()
		);
		screenEntity.addChild(new Entity().add(timeElapsedNumText));
		
		//minesweeper.pxlSq.Utils.ConsoleLog(screenBackground.alpha._ + "");
		
		var script: Script = new Script();
		script.run(new Sequence([
			new Delay(0.1),
			new Parallel([
				new AnimateTo(screenBackground.alpha, 0.5, 0.5),
				new AnimateTo(bombsLeftText.alpha, 1, 0.5),
				new AnimateTo(bombsCountText.alpha, 1, 0.5),
				new AnimateTo(timeElapsedText.alpha, 1, 0.5),
				new AnimateTo(timeElapsedNumText.alpha, 1, 0.5)
			]),
			new CallFunction(function() {
				SceneManager.current.ShowPromptScreen(
				AssetName.ASSET_GAME_OVER_HEADER,
				[
					"Retry", function() {
						SceneManager.current.ShowMainScreen();
					},
					"Quit", function() {
						SceneManager.current.ShowTitleScreen(true);
					}
				]);	
			})
		]));
		screenEntity.addChild(new Entity().add(script));
		
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_GAME_OVER;
	}
}
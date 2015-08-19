package minesweeper.screen.main;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.script.AnimateTo;
import flambe.script.Parallel;
import flambe.script.Action;

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
		screenBackground.alpha.animate(0, 0.5, 0.25);
		RemoveTitleText();
		
		var mainScreen: MainScreen = SceneManager.current.gameMainScreen;
		var actions: Array<Action> = new Array<Action>();
		
		var bombsLeftFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
		var bombsLeftText: TextSprite = new TextSprite(bombsLeftFont, "Bombs Left\n        " + mainScreen.gameBombCount);
		bombsLeftText.alpha._ = 0;
		bombsLeftText.centerAnchor();
		bombsLeftText.setXY( 
			System.stage.width * 0.2,
			System.stage.height * 0.55
		);
		
		if(!mainScreen.HasReachedGoals()) {
			screenEntity.addChild(new Entity().add(bombsLeftText));
			actions.push(new AnimateTo(bombsLeftText.alpha, 1, 0.5));
		}
		
		var timeElapsedFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
		var timeElapsedText: TextSprite = new TextSprite(timeElapsedFont, "Time Elapsed\n       " + Utils.ToMMSS(mainScreen.gameTimeElapsed));
		timeElapsedText.alpha._ = 0.0;
		timeElapsedText.centerAnchor();
		timeElapsedText.setXY(
			System.stage.width * 0.825,
			System.stage.height * 0.55
		);
		screenEntity.addChild(new Entity().add(timeElapsedText));		
		actions.push(new AnimateTo(timeElapsedText.alpha, 1, 0.5));
		
		var script: Script = new Script();
		script.run(new Sequence([
			new Delay(0.25),
			new Parallel(actions),
			new CallFunction(function() {
				if (mainScreen.HasReachedGoals()) {
					SceneManager.current.ShowPromptTextScreen(
					"YOU WIN!",
					[
						"Retry", function() {
							SceneManager.current.ShowMainScreen();
						},
						"Quit", function() {
							SceneManager.current.ShowTitleScreen(true);
						}
					]);
				}
				else {
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
				}
			})
		]));
		screenEntity.addChild(new Entity().add(script));
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_GAME_OVER;
	}
}
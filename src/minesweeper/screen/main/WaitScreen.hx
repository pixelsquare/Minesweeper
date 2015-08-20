package minesweeper.screen.main;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Repeat;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.System;

import minesweeper.core.SceneManager;
import minesweeper.name.AssetName;
import minesweeper.name.ScreenName;
import minesweeper.screen.GameScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class WaitScreen extends GameScreen
{
	private static inline var STARTING_TIME: Int = 3;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		screenBackground.alpha.animate(0, 0.5, 0.5);
		RemoveTitleText();
		
		var gameStartingFont: Font = new Font(gameAsset, AssetName.FONT_VANADINE_32);
		var gameStartingText: TextSprite = new TextSprite(gameStartingFont, "Game starting in");
		gameStartingText.centerAnchor();
		gameStartingText.setXY(
			System.stage.width / 2,
			System.stage.height * 0.45
		);
		screenEntity.addChild(new Entity().add(gameStartingText));
		
		var countdownFont: Font = new Font(gameAsset, AssetName.FONT_VANADINE_32);
		var countdownText: TextSprite = new TextSprite(countdownFont, "3");
		countdownText.centerAnchor();
		countdownText.setXY(
			gameStartingText.x._,
			gameStartingText.y._ + gameStartingText.getNaturalHeight()
		);
		screenEntity.addChild(new Entity().add(countdownText));
		
		var time = STARTING_TIME;
		var script: Script = new Script();
		script.run(new Repeat(
			new Sequence([
				new CallFunction(function() {
					countdownText.text = (time == 0) ? "GO!" : time + "";
					countdownText.alpha.animate(-1, 1, 0.8);
					
					var posY: Float = countdownText.y._;
					countdownText.y.animate(0, posY, 1, Ease.elasticInOut);
					
					// Re-position the text
					gameStartingText.centerAnchor();
					gameStartingText.setXY(
						System.stage.width / 2,
						System.stage.height * 0.45
					);
		
				}),
				new Delay(1),
				new CallFunction(function() {
					time--;
					if (time < 0) {
						time = 0;
						countdownText.alpha.animate(1, 0, 1);
						SceneManager.current.UnwindToScene(SceneManager.current.curGameScreen.screenEntity);
					}
				})
			])
		));
		
		screenEntity.add(script);
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_WAIT;
	}
}
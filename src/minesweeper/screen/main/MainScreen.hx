package minesweeper.screen.main;

import flambe.asset.AssetPack;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.subsystem.StorageSystem;
import flambe.System;

import minesweeper.core.GameManager;
import minesweeper.core.SceneManager;
import minesweeper.main.MSUtils;
import minesweeper.name.AssetName;
import minesweeper.screen.GameScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class MainScreen extends GameScreen
{	
	public var boardBG(default, null): ImageSprite;
	
	private var timerText: TextSprite;
	private var bombsText: TextSprite;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		
		// DEBUGGING --
		screenDisposer.add(System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (event.key == Key.F1) {
				SceneManager.current.ShowPauseScreen();
			}
			
			if (event.key == Key.F2) {
				SceneManager.current.ShowGameOverScreen();
			}
			
			if (event.key == Key.F3) {
				MSUtils.RevealAllNonBombs(GameManager.current.GetMSMain().GetAllBlocks());
			}
			
			if (event.key == Key.F4) {
				MSUtils.RevealAllBlocks(GameManager.current.GetMSMain().GetAllBlocks());
			}
			
			if (event.key == Key.P) {
				if(GameManager.current.GetMSMain().hasStarted) {
					SceneManager.current.ShowPauseScreen();
				}
			}
		}));
		// END-OF-DEBUGGING --
		
		//var background: FillSprite = new FillSprite(0x253F47, System.stage.width, System.stage.height);
		//screenEntity.addChild(new Entity().add(background));
		//
		//var board: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BOARD));
		//board.centerAnchor();
		//board.setXY(
			//System.stage.width / 2,
			//System.stage.height / 2
		//);
		//screenEntity.addChild(new Entity().add(board));
		
		#if android
			var background: FillSprite = new FillSprite(0x253F47, System.stage.width, System.stage.height);
			screenEntity.addChild(new Entity().add(background));
			
			boardBG = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BOARD));
			boardBG.centerAnchor();
			boardBG.setXY(
				System.stage.width / 2,
				System.stage.height * 0.4
			);
			screenEntity.addChild(new Entity().add(boardBG));
		#else
			var background: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_INGAME_BG));
			screenEntity.addChild(new Entity().add(background));
		#end
		
		// Wait before starting
		//var script: Script = new Script();
		//script.run(new Sequence([
			//new Delay(0.1),
			//new CallFunction(function() {
				//SceneManager.current.ShowWaitScreen();
			//})
		//]));
		//screenEntity.add(script);
		
		var timerEntity: Entity = new Entity();
		var timerBg: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_TIMER_CONTAINER));
		timerBg.centerAnchor();
		timerBg.setXY(
			System.stage.width * 0.29,
			System.stage.height * 0.91
		);
		timerEntity.addChild(new Entity().add(timerBg));
		
		var timerFont: Font = new Font(gameAsset, AssetName.FONT_VANADINE_32);
		timerText = new TextSprite(timerFont, MSUtils.ToMMSS(GameManager.current.gameTimeElapsed));
		timerText.centerAnchor();
		timerText.setXY(
			timerBg.x._ + 20,
			timerBg.y._
		);
		timerEntity.addChild(new Entity().add(timerText));
		
		screenEntity.addChild(timerEntity);
		
		var bombsEntity: Entity = new Entity();
		var bombsBg: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BOMB_CONTAINER));
		bombsBg.centerAnchor();
		bombsBg.setXY(
			System.stage.width * 0.71,
			System.stage.height * 0.91
		);
		bombsEntity.addChild(new Entity().add(bombsBg));
		
		var bombsFont: Font = new Font(gameAsset, AssetName.FONT_VANADINE_32);
		bombsText = new TextSprite(bombsFont, GameManager.current.gameBombCount + "");
		bombsText.centerAnchor();
		bombsText.setXY(
			bombsBg.x._ + 20,
			bombsBg.y._
		);
		bombsEntity.addChild(new Entity().add(bombsText));
		
		screenEntity.addChild(bombsEntity);
		
		GameManager.current.InitMSGame(screenEntity);
		
		// Update all GUI
		GameManager.current.GetMSMain().bombCount.watch(function(a: Float, b: Float) {
			bombsText.text = GameManager.current.gameBombCount + "";
		});
		
		GameManager.current.GetMSMain().timeElapsed.watch(function(a: Float, b:Float) {
			timerText.text = MSUtils.ToMMSS(GameManager.current.gameTimeElapsed);
		});
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return super.GetScreenName();
	}
	
	public function HasReachedGoals(): Bool {
		return GameManager.current.GetMSMain().HasReachedGoals();
	}
}
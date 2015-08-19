package minesweeper.screen.main;

import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.KeyboardEvent;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.display.ImageSprite;
import flambe.System;
import flambe.input.Key;
import minesweeper.main.MSMain;

import minesweeper.core.SceneManager;
import minesweeper.screen.GameScreen;
import minesweeper.name.AssetName;
import minesweeper.core.Utils;
import minesweeper.name.GameData;

/**
 * ...
 * @author Anthony Ganzon
 */
class MainScreen extends GameScreen
{

	public var gameTimeElapsed(default, null): Float;
	public var gameBombCount(default, null) : Int;
	
	private var timerText: TextSprite;
	private var bombsText: TextSprite;
	
	private var msMain: MSMain;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
		
		this.gameTimeElapsed = GameData.GAME_DEFAULT_TIME;
		this.gameBombCount = GameData.GAME_MAX_BOMBS;
		
		System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (event.key == Key.B) {
				SceneManager.current.ShowPauseScreen();
				//SceneManager.current.ShowGameOverScreen();
			}
		});
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		
		var background: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_INGAME_BG));
		screenEntity.addChild(new Entity().add(background));
		
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
		timerText = new TextSprite(timerFont, Utils.ToMMSS(gameTimeElapsed));
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
		bombsText = new TextSprite(bombsFont, gameBombCount + "");
		bombsText.centerAnchor();
		bombsText.setXY(
			bombsBg.x._ + 20,
			bombsBg.y._
		);
		bombsEntity.addChild(new Entity().add(bombsText));
		
		screenEntity.addChild(bombsEntity);
		
		msMain = new MSMain(gameAsset, gameStorage);
		screenEntity.addChild(new Entity().add(msMain));
		
		msMain.bombCount.watch(function(a: Float, b: Float) {
			gameBombCount = Std.int(msMain.bombCount._);
			bombsText.text = gameBombCount + "";
		});
		
		msMain.timeElapsed.watch(function(a: Float, b: Float) {
			gameTimeElapsed = msMain.timeElapsed._;
			timerText.text = Utils.ToMMSS(gameTimeElapsed);
		});
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return super.GetScreenName();
	}
	
	public function HasReachedGoals(): Bool {
		return msMain.HasReachedGoals();
	}
}
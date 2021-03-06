package minesweeper.core;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.Component;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.math.FMath;
import flambe.scene.Director;
import flambe.scene.FadeTransition;
import flambe.subsystem.StorageSystem;
import flambe.System;

import minesweeper.screen.GameScreen;
import minesweeper.screen.main.GameOverScreen;
import minesweeper.screen.main.MainScreen;
import minesweeper.screen.main.PromptScreen;
import minesweeper.screen.main.PromptTextScreen;
import minesweeper.screen.main.TitleScreen;
import minesweeper.screen.main.WaitScreen;
import minesweeper.name.AssetName;

/**
 * ...
 * @author Anthony Ganzon
 */
class SceneManager
{
	public var gameDirector(default, null): Director;
	public var curGameScreen(default, null): GameScreen;
	
	public var gameTitleScreen(default, null): TitleScreen;
	public var gameWaitScreen(default, null): WaitScreen;
	public var gameMainScreen(default, null): MainScreen;
	public var gameOverScreen(default, null): GameOverScreen;
	private var gamePromptScreen: PromptScreen;
	private var gamePromptTextScreen: PromptTextScreen;
	
	private var gameScreens: Array<GameScreen>;
	
	public static inline var TARGET_WIDTH: 	Int = 200;
	public static inline var TARGET_HEIGHT: Int = 200;
	
	private static inline var TRANSITION_SHORT: Float = 0.5;
	private static inline var TRANSITION_LONG: Int = 1;
	
	public static var current(default, null): SceneManager;
	
	public function new(director: Director) {
		current = this;
		this.gameDirector = director;
	}
	
	public function InitScenes(assetPack: AssetPack, storage: StorageSystem) {
		System.stage.resize.connect(OnScreenResize);
		gameScreens = new Array<GameScreen>();
		
		gameScreens.push(gameTitleScreen = new TitleScreen(assetPack, storage));
		gameScreens.push(gameWaitScreen = new WaitScreen(assetPack, storage));
		gameScreens.push(gameMainScreen = new MainScreen(assetPack, storage));
		gameScreens.push(gameOverScreen = new GameOverScreen(assetPack, storage));
		gameScreens.push(gamePromptScreen = new PromptScreen(assetPack, storage));
		gameScreens.push(gamePromptTextScreen = new PromptTextScreen(assetPack, storage));
		
		var sprite: ImageSprite = new ImageSprite(assetPack.getTexture(AssetName.ASSET_BOMB));
		var testEntity: Entity = new Entity()
			.addChild(new Entity().add(new Sprite()))
			.addChild(new Entity().add(sprite));
		
		//spriteEntity.add(sprite);
		//spriteEntity.addChild(new Entity().add(sprite));
		//testEntity.addChild(spriteEntity);
		
		//minesweeper.pxlSq.Utils.ConsoleLog(testEntity.toString() + "");
		//minesweeper.pxlSq.Utils.ConsoleLog(testEntity.firstChild + " " + spriteEntity.firstChild + " "  + testEntity);
		
		recursion(testEntity);
		
		//testEntity.has
		
		//var child = testEntity.firstChild;
		//while (child != null) {
			//var next = child.next;
			//
			//minesweeper.pxlSq.Utils.ConsoleLog(child.has(Sprite) + "");
			//
			//child = next;
		//}
	}
	
	private function recurse<A:Component>(componentClass:Class < A > ): Void {
		
	}
	
	private function recursion(root: Entity): Void {
		var child = root.firstChild;
		while (child != null) {
			var next = child.next;
			
			minesweeper.pxlSq.Utils.ConsoleLog(child.has(Sprite) + "");
			
			recursion(child);
			child = next;
		}
	}
	
	public function OnScreenResize() {
		var targetWidth: Int = TARGET_WIDTH;
		var targetHeight: Int = TARGET_HEIGHT;
		
		var scale = FMath.min(System.stage.width / targetWidth, System.stage.height / targetHeight);
		if (scale > 1) scale = 1;
		
		for (screen in gameScreens) {
			screen.screenEntity.get(Sprite).setScale(scale).setXY(
				(System.stage.width - targetWidth * scale) / 2, 
				(System.stage.height - targetHeight * scale) / 2
			);
		}
	}
	
	public function ShowScreen(gameScreen: GameScreen, willAnimate: Bool = false): Void {
		gameDirector.unwindToScene(gameScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null);
		this.curGameScreen = gameScreen;
	}
	
	public function UnwindToScene(scene: Entity): Void {
		if (scene == null)
			return;
		
		gameDirector.unwindToScene(scene);
	}
	
	public function UnwindToCurrentScene(): Void {
		UnwindToScene(curGameScreen.screenEntity);
	}
	
	public function ShowTitleScreen(willAnimate: Bool = false): Void {
		gameDirector.unwindToScene(gameTitleScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null);
		this.curGameScreen = gameTitleScreen;
	}
	
	public function ShowWaitScreen(willAnimate: Bool = false): Void {
		gameDirector.pushScene(gameWaitScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null);
	}
	
	public function ShowPauseScreen(willAnimate: Bool = false): Void {
		ShowPromptTextScreen(
		"Paused!",
		[
			"Resume", function() {
				UnwindToScene(this.curGameScreen.screenEntity);
			},
			"Retry", function() {
				ShowMainScreen();
			}
		], true);
	}
	
	public function ShowMainScreen(willAnimate: Bool = false): Void {
		gameDirector.unwindToScene(gameMainScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null);
		this.curGameScreen = gameMainScreen;
	}
	
	public function ShowGameOverScreen(willAnimate: Bool = false): Void {
		gameDirector.pushScene(gameOverScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null);
		this.curGameScreen = gameOverScreen;		
	}
	
	public function ShowPromptScreen(imgName: String, buttons: Array<Dynamic>, animateBG: Bool = false, willAnimate: Bool = false): Void {
		if (gameDirector.topScene == gamePromptScreen.screenEntity)
			return;
			
		gamePromptScreen.InitPrompt(imgName, buttons, animateBG);
		gameDirector.pushScene(gamePromptScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null);
		gamePromptScreen.ShowScreen();
	}
	
	public function ShowPromptTextScreen(titleName: String, buttons: Array<Dynamic>, animateBG: Bool = false, willAnimate: Bool = false): Void {
		if (gameDirector.topScene == gamePromptTextScreen.screenEntity)
			return;
		
		gamePromptTextScreen.InitPrompt(titleName, buttons, animateBG);
		gameDirector.pushScene(gamePromptTextScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear): null);
		gamePromptTextScreen.ShowScreen();
	}
}
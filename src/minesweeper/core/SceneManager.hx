package minesweeper.core;

import flambe.Entity;
import flambe.scene.Director;
import flambe.asset.AssetPack;
import flambe.subsystem.StorageSystem;
import flambe.math.FMath;
import flambe.System;
import flambe.display.Sprite;
import flambe.scene.FadeTransition;
import flambe.scene.SlideTransition;
import flambe.animation.Ease;

import minesweeper.screen.GameScreen;
import minesweeper.screen.main.TitleScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class SceneManager
{
	public var gameDirector(default, null): Director;
	public var curGameScreen(default, null): GameScreen;
	
	private var gameScreens: Array<GameScreen>;
	private var gameTitleScreen: TitleScreen;
	
	public static inline var TARGET_WIDTH: 	Int = 640;
	public static inline var TARGET_HEIGHT: Int = 800;
	
	private static inline var TRANSITION_SHORT: Float = 0.5;
	private static inline var TRANSITION_LONG: Int = 1;
	
	public static var current(default, null): SceneManager;
	
	public function new(director: Director) {
		current = this;
		this.gameDirector = director;
	}
	
	public function InitScenes(assetPack: AssetPack, storage: StorageSystem) {
		gameScreens = new Array<GameScreen>();
		
		gameScreens.push(gameTitleScreen = new TitleScreen(assetPack, storage));
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
	
	public function ShowTitleScreen(willAnimate: Bool): Void {
		gameDirector.unwindToScene(gameTitleScreen.CreateScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null);
		this.curGameScreen = gameTitleScreen;
	}
}
package minesweeper;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.Entity;
import flambe.scene.Director;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.util.Promise;

import minesweeper.core.GameManager;
import minesweeper.core.SceneManager;
import minesweeper.screen.PreloadScreen;
import minesweeper.screen.SplashScreen;

class Main
{
	private static inline var PRELOAD_PATH: String = "preload";
	private static inline var MAIN_PATH: String = "main";
	
    private static function main ()
    {
        // Wind up all platform-specific stuff
        System.init();
		
		var gameDirector: Director = new Director();
		System.root.addChild(new Entity().add(gameDirector));
		
		var gameStorage: StorageSystem = System.storage;
		
		System.loadAssetPack(Manifest.fromAssets(PRELOAD_PATH)).get(function(preloadPack: AssetPack) {
			//Utils.ConsoleLog("Preload Initialize");
			
			var sceneManager: SceneManager = new SceneManager(gameDirector);
			
			var promise: Promise<AssetPack> = System.loadAssetPack(Manifest.fromAssets(MAIN_PATH));
			promise.get(function(mainPack: AssetPack) {
				//Utils.ConsoleLog("Main Initialize");
				
				// Load up all asset data
				var gameManager: GameManager = new GameManager(mainPack, gameStorage);
				sceneManager.InitScenes(mainPack, gameStorage);
				
				#if flash
					sceneManager.ShowTitleScreen(true);
					//sceneManager.ShowMainScreen(true);
				#else
					sceneManager.ShowScreen(new SplashScreen(preloadPack), true);
				#end
			});
			
			// Preloading goes here
			sceneManager.ShowScreen(new PreloadScreen(preloadPack, promise));
		});
    }
}

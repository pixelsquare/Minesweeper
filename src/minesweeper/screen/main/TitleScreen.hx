package minesweeper.screen.main;

import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import minesweeper.screen.GameScreen;
import flambe.System;
import flambe.animation.Ease;

import minesweeper.name.ScreenName;
import minesweeper.name.AssetName;

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
		
		titleText = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_LOGO));
		titleText.centerAnchor();
		titleText.setXY(
			System.stage.width / 2,
			System.stage.height * 0.3
		);
		screenEntity.addChild(new Entity().add(titleText));
		
		var playButtonEntity: Entity = new Entity();
		playButton = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BUTTON_UP));
		playButton.centerAnchor();
		playButtonEntity.addChild(new Entity().add(playButton));
		
		var playButtonFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
		var playButtonText: TextSprite = new TextSprite(playButtonFont, "Play");
		playButtonText.centerAnchor();
		playButtonText.setXY(
			playButton.x._,
			playButton.y._
		);
		playButtonEntity.addChild(new Entity().add(playButtonText));
		
		playButtonSprite = new Sprite();
		playButtonSprite.setXY(
			System.stage.width / 2,
			System.stage.height * 0.6
		);
		playButtonSprite.pointerDown.connect(function(event: PointerEvent) {
			HideScreen();
		});
		
		screenEntity.addChild(playButtonEntity.add(playButtonSprite));
		
		ShowScreen();
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_TITLE;
	}
	
	override public function ShowScreen(): Void {
		
		titleText.x._ = -(titleText.getNaturalWidth());
		playButtonSprite.y._ = System.stage.height + playButton.getNaturalHeight();
		
		var script: Script = new Script();
		script.run(new Sequence([
			new AnimateTo(titleText.x, System.stage.width / 2, 0.5, Ease.backInOut),
			new AnimateTo(playButtonSprite.y, System.stage.height * 0.6, 0.5, Ease.backInOut)
		]));
		screenEntity.add(script);
		
		//titleText.x.animate( -(titleText.getNaturalWidth()), System.stage.width / 2, 0.5, Ease.backInOut);
		//playButtonSprite.y.animate(System.stage.height + playButton.getNaturalHeight(), System.stage.height * 0.5, 0.5, Ease.backInOut);
	}
	
	override public function HideScreen():Void {
		titleText.x._ = System.stage.width / 2;
		playButtonSprite.y._ = System.stage.height * 0.6;
		
		var script: Script = new Script();
		script.run(new Sequence([
			new AnimateTo(playButtonSprite.y, System.stage.height + playButton.getNaturalHeight(), 0.5, Ease.backOut),
			new CallFunction(function() {
				Utils.ConsoleLog("Next Screen!");
			})
		]));
		screenEntity.add(script);
		
		//titleText.x.animateTo(-(titleText.getNaturalWidth()), 0.5, Ease.backOut);
		//playButtonSprite.y.animateTo(System.stage.height + playButton.getNaturalHeight(), 0.5, Ease.backOut);
	}
}
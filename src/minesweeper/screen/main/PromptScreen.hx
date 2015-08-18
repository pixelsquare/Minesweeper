package minesweeper.screen.main;

import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.math.Rectangle;
import flambe.script.Action;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.animation.Ease;

import minesweeper.screen.GameScreen;
import minesweeper.name.ScreenName;
import minesweeper.name.AssetName;
import minesweeper.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PromptScreen extends GameScreen
{
	private var titleText: ImageSprite;
	private var buttonSpriteList: Array<Sprite>;
	
	private var textureName: String;
	private var buttons: Array<Dynamic>;
	
	private var animateBG: Bool;
	
	private var buttonFunc: Void->Void;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	public function InitPrompt(imgName: String, buttons: Array<Dynamic>, animateBG: Bool) {
		this.textureName = imgName;
		this.buttons = buttons;
		this.animateBG = animateBG;
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		screenBackground.alpha._ = 0;
		RemoveTitleText();
		
		titleText = new ImageSprite(gameAsset.getTexture(textureName));
		titleText.centerAnchor();
		titleText.setXY(
			System.stage.width / 2,
			System.stage.height * 0.3
		);
		screenEntity.addChild(new Entity().add(titleText));
		
		var buttonsEntity: Entity = new Entity();
		buttonSpriteList = new Array<Sprite>();
		
		var len: Float = buttons.length / 2;
		var half: Float = len / 2;
		
		var jj: Float = -(half / len);
		var ii: Int = 0;
		while (ii < this.buttons.length) {
			var buttonName: String = this.buttons[ii++];
			var buttonHandler = this.buttons[ii++];
			
			var buttonEntity: Entity = new Entity();
			var buttonBG: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BUTTON_UP));
			buttonBG.centerAnchor();			
			buttonEntity.addChild(new Entity().add(buttonBG));
			
			var buttonFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_32);
			var buttonText: TextSprite = new TextSprite(buttonFont, buttonName);
			buttonText.centerAnchor();
			buttonText.setXY(
				buttonBG.x._,
				buttonBG.y._
			);
			buttonEntity.addChild(new Entity().add(buttonText));
			
			var buttonSprite: Sprite = new Sprite();
			buttonSprite.y._ = ((buttonBG.getNaturalHeight() * 3) * jj);
			jj += (half / len);
			
			buttonSprite.pointerIn.connect(function(event: PointerEvent) {
				buttonBG.texture = gameAsset.getTexture(AssetName.ASSET_BUTTON_HOVER);
			});
			
			buttonSprite.pointerOut.connect(function(event: PointerEvent) {
				buttonBG.texture = gameAsset.getTexture(AssetName.ASSET_BUTTON_UP);
			});
			
			buttonSprite.pointerUp.connect(function(event: PointerEvent) {
				buttonBG.texture = gameAsset.getTexture(AssetName.ASSET_BUTTON_HOVER);
				buttonFunc = buttonHandler;
				HideScreen();
			});
			
			buttonSprite.pointerDown.connect(function(event: PointerEvent) {
				buttonBG.texture = gameAsset.getTexture(AssetName.ASSET_BUTTON_DOWN);
			});			
			
			buttonSpriteList.push(buttonSprite);
			buttonsEntity.addChild(buttonEntity.add(buttonSprite));
		}
		
		var buttonsRect: Rectangle = Sprite.getBounds(buttonsEntity);
		var buttonsSprite: Sprite = new Sprite();
		buttonsSprite.setXY(
			System.stage.width / 2,
			System.stage.height * 0.85 - (buttonsRect.height / 2)
		);
		screenEntity.addChild(buttonsEntity.add(buttonsSprite));
		
		return screenEntity;
	}
	
	public function SetAnimateBG(willAnimate: Bool) : Void {
		this.animateBG = willAnimate;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_PROMPT;
	}
	
	override public function ShowScreen(): Void {
		if (animateBG) {
			screenBackground.alpha.animate(0, 0.5, 0.5);
		}
		
		var buttonYPos: Array<Float> = new Array<Float>();
		titleText.x._ = -(titleText.getNaturalWidth());
		for (button in buttonSpriteList) {
			buttonYPos.push(button.y._);
			button.y._ = (System.stage.height) + button.getNaturalHeight();
		}
		
		var script: Script = new Script();
		script.run(new Sequence([
			new AnimateTo(titleText.x, System.stage.width / 2, 0.5, Ease.backInOut),
			new CallFunction(function() {
				var ii: Int = 0;	
				for (button in buttonSpriteList) {
					button.y.animate((System.stage.height) + button.getNaturalHeight(), buttonYPos[ii], 0.25 * (ii + 1), Ease.backInOut);
					ii++;
				}
			})
		]));
		
		screenEntity.add(script);
	}
	
	override public function HideScreen(): Void {		
		var actions: Array<Action> = new Array <Action>();
		
		var ii: Int = 0;
		for (button in buttonSpriteList) {
			actions.push(new AnimateTo(button.y, (System.stage.height), 0.25 * (ii + 1), Ease.backInOut));
			ii++;
		}
		
		actions.push(new CallFunction(function() {
			if(buttonFunc != null) {
				buttonFunc();
			}
		}));
		
		var script: Script = new Script();
		script.run(new Sequence(actions));
		
		screenEntity.add(script);
		
		if (animateBG) {
			screenBackground.alpha.animateTo(0, 0.5);
		}
	}
}
package minesweeper.screen.main;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.System;

import minesweeper.name.AssetName;

/**
 * ...
 * @author Anthony Ganzon
 */
class PromptTextScreen extends PromptScreen
{

	private var titleName: String;
	private var titleText: TextSprite;
	
	public function new(assetPack:AssetPack, storage:StorageSystem) {
		super(assetPack, storage);
	}
	
	override public function InitPrompt(titleName: String, buttons:Array<Dynamic>, animateBG:Bool) {
		super.InitPrompt("", buttons, animateBG);
		this.titleName = titleName;
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		
		var titleTextFont: Font = new Font(gameAsset, AssetName.FONT_UNCERTAIN_SANS_40);
		titleText = new TextSprite(titleTextFont, this.titleName);
		titleText.centerAnchor();
		titleText.setXY(
			System.stage.width / 2,
			System.stage.height * 0.3
		);
		screenEntity.addChild(new Entity().add(titleText));
		
		return screenEntity;
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
		super.HideScreen();
	}
}
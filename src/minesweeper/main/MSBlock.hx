package minesweeper.main;

import flambe.animation.AnimatedFloat;
import flambe.Component;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.scene.Scene;
import flambe.script.Action;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Script;
import flambe.script.Sequence;
import minesweeper.core.Utils;
import minesweeper.core.SceneManager;

/**
 * ...
 * @author Anthony Ganzon
 */
class MSBlock extends Component
{
	public var x(default, null): AnimatedFloat;
	public var y(default, null): AnimatedFloat;
	
	public var idx(default, null): Int;
	public var idy(default, null): Int;
	
	public var hasBomb(default, null): Bool;
	public var isRevealed(default, null): Bool;
	public var isMarked(default, null): Bool;
	private var blockValue: Int;

	public var innerTexture: Texture;
	private var innerImage: ImageSprite;
	
	public var blockValueFont: Font;
	private var blockValueText: TextSprite;
	
	public var bombTexture: Texture;
	private var bombImage: ImageSprite;
	
	public var outerTexture: Texture;
	private var outerImage: ImageSprite;
	
	public var flagTexture: Texture;
	public var qMarkTexture: Texture;
	private var markerImage: ImageSprite;
	private var markerCount: UInt;
	
	private var blockEntity: Entity;
	private var blockSprite: Sprite;
	
	public function new(innerTex: Texture, valueFont: Font, bombTex: Texture, outerTex: Texture, flagTex: Texture, qMarkTex: Texture ) {
		this.x = new AnimatedFloat(0);
		this.y = new AnimatedFloat(0);
		
		this.innerTexture = innerTex;
		this.blockValueFont = valueFont;
		this.bombTexture = bombTex;
		this.outerTexture = outerTex;
		this.flagTexture = flagTex;
		this.qMarkTexture = qMarkTex;
		this.markerCount = 0;
		
		CreateBlock();
	}
	
	public function CreateBlock(): Void {
		blockEntity = new Entity();
		blockSprite = new Sprite();
		
		var blockButtonEntity: Entity = new Entity();
		
		innerImage = new ImageSprite(innerTexture);
		innerImage.centerAnchor();
		innerImage.visible = false;
		blockButtonEntity.addChild(new Entity().add(innerImage));
		
		blockValueText = new TextSprite(blockValueFont, blockValue + "");
		blockValueText.centerAnchor();
		//blockValueText.visible = false;
		blockButtonEntity.addChild(new Entity().add(blockValueText));
		
		bombImage = new ImageSprite(bombTexture);
		bombImage.centerAnchor();
		//bombImage.visible = false;
		blockButtonEntity.addChild(new Entity().add(bombImage));
		
		outerImage = new ImageSprite(outerTexture);
		outerImage.centerAnchor();
		outerImage.setAlpha(0.25);
		blockButtonEntity.addChild(new Entity().add(outerImage));
		
		markerImage = new ImageSprite(flagTexture);
		markerImage.centerAnchor();
		markerImage.visible = false;
		blockButtonEntity.addChild(new Entity().add(markerImage));
		
		blockEntity.addChild(blockButtonEntity.add(blockSprite));
		
		//blockSprite.pointerDown.connect(function(event: PointerEvent) {
			//SetIsRevealed(true);
		//});
		
		blockSprite.pointerIn.connect(function(event: PointerEvent) {
			MSMain.current.curBlock = this;
		});
	}
	
	public function SetBlockID(x: Int, y: Int): Void {
		this.idx = x;
		this.idy = y;
	}
	
	public function SetBlockXY(x: Float, y: Float): MSBlock {
		this.x._ = x;
		this.y._ = y;
		SetBlockDirty();
		return this;
	}
	
	public function SetBlockValue(value: Int): Void {
		//if (value == 0)
			//return;
		
		if (this.hasBomb)
			return;
		
		this.blockValue = value;
			
		if (value == -1) {
			bombImage.visible = true;
			blockValueText.visible = false;
			SetHasBomb(true);
			return;
		}
		
		blockValueText.visible = true;
		bombImage.visible = false;
		blockValueText.text = this.blockValue + "";
	}
	
	public function SetHasBomb(hasBomb: Bool): Void {
		if (this.hasBomb == hasBomb)
			return;
		
		this.hasBomb = hasBomb;
	}
	
	public function SetIsRevealed(isRevealed: Bool): Void {
		if (this.isRevealed == isRevealed)
			return;
			
		if (this.isMarked && markerCount == 1)
			return;
		
		innerImage.visible = true;
		if (hasBomb) {
			bombImage.visible = true;
		}
		else {
			if (blockValue > 0) {
				blockValueText.visible = true;
			}
		}
			
		var action;
		if (isRevealed) {
			outerImage.alpha._ = 1;
			action = new AnimateTo(outerImage.alpha, 0, 0.5);
		}
		else {
			outerImage.alpha._ = 0;
			action = new AnimateTo(outerImage.alpha, 1, 0.5);
		}
		
		var script: Script = new Script();
		script.run(new Sequence([
			action,
			new CallFunction(function() {
				if (this.hasBomb) {
					SceneManager.current.ShowGameOverScreen();
				}
				outerImage.visible = false;
			})
		]));
		
		markerImage.visible = false;
		this.isRevealed = isRevealed;
		
		if (this.blockValue == 0) {
			Utils.OpenNeighbors(this);
		}
		
		blockEntity.addChild(new Entity().add(script));
	}
	
	public function SetIsMarked(isMarked: Bool): Void {			
		if (this.isRevealed)
			return;
			
		if (MSMain.current.bombCount._ <= 0 && markerCount == 0)
			return;
			
		markerCount++;
		if (markerCount > 2) {
			markerCount = 0;
			isMarked = false;
		}
		
		if (markerCount == 1) {				
			markerImage.texture = flagTexture;
			MSMain.current.AddMarkedBlocks();
			markerImage.visible = true;
		}
		else if (markerCount == 2) {
			markerImage.texture = qMarkTexture;
			MSMain.current.SubtractMarkedBlocks();
			markerImage.visible = true;
		}
		
		var action: Action;
		if (isMarked) {
			markerImage.alpha._ = 0;
			action = new AnimateTo(markerImage.alpha, 1, 0.5);
		}
		else {
			markerImage.alpha._ = 1;
			action = new AnimateTo(markerImage.alpha, 0, 0.5);
		}
		
		var script: Script = new Script();
		script.run(new Sequence([
			action,
			new CallFunction(function() {
				if(!isMarked) {
					markerImage.visible = false;
				}
			})
		]));
			
		blockEntity.addChild(new Entity().add(script));
		
		this.isMarked = isMarked;
	}
	
	public function GetNaturalWidth(): Float {
		return innerImage.getNaturalWidth();
	}
	
	public function GetNaturalHeight(): Float {
		return innerImage.getNaturalHeight();
	}
	
	public function SetBlockDirty(): Void {
		blockSprite.setXY(this.x._, this.y._);
	}
	
	override public function onAdded() {
		super.onAdded();
		owner.addChild(blockEntity);
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		x.update(dt);
		y.update(dt);
	}
}
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
		blockButtonEntity.addChild(new Entity().add(innerImage));
		
		blockValueText = new TextSprite(blockValueFont, blockValue + "");
		blockValueText.alpha._ = 0.0;
		blockValueText.centerAnchor();
		blockButtonEntity.addChild(new Entity().add(blockValueText));
		
		bombImage = new ImageSprite(bombTexture);
		bombImage.alpha._ = 0.0;
		bombImage.centerAnchor();
		blockButtonEntity.addChild(new Entity().add(bombImage));
		
		outerImage = new ImageSprite(outerTexture);
		outerImage.centerAnchor();
		blockButtonEntity.addChild(new Entity().add(outerImage));
		
		markerImage = new ImageSprite(flagTexture);
		markerImage.alpha._ = 0.0;
		markerImage.centerAnchor();
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
		if (value == 0 || this.hasBomb)
			return;
		
		this.blockValue = value;
			
		if (value == -1) {
			SetHasBomb(true);
			return;
		}
		
		bombImage.alpha._ = 0;
		blockValueText.alpha._ = 1;
		blockValueText.text = this.blockValue + "";
	}
	
	public function SetHasBomb(hasBomb: Bool): Void {
		if (this.hasBomb == hasBomb)
			return;
		
		if (hasBomb) {
			blockValueText.alpha._ = 0;
			bombImage.alpha._ = 1;
		}
		else {
			bombImage.alpha._ = 0;
			blockValueText.alpha._ = 1;
		}
		
		this.hasBomb = hasBomb;
	}
	
	public function SetIsRevealed(isRevealed: Bool): Void {
		if (this.isRevealed == isRevealed)
			return;
		
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
			})
		]));
		
		markerImage.alpha._ = 0;
		this.isRevealed = isRevealed;
		
		if (this.blockValue == 0) {
			Utils.OpenNeighbors(this);
		}
		
		blockEntity.addChild(new Entity().add(script));
	}
	
	public function SetIsMarked(isMarked: Bool): Void {
		//if (this.isMarked == isMarked)
			//return;
			
		if (this.isRevealed)
			return;
			
		markerCount++;
		if (markerCount > 2) {
			markerCount = 0;
			isMarked = false;
		}
		
		if (markerCount == 1) {
			markerImage.texture = flagTexture;
			MSMain.current.AddMarkedBlocks();
		}
		else if (markerCount == 2) {
			markerImage.texture = qMarkTexture;
			MSMain.current.SubtractMarkedBlocks();
		}
		
		if (isMarked) {
			markerImage.alpha.animate(0, 1, 0.5);
		}
		else {
			markerImage.alpha.animate(1, 0, 0.5);
		}
			
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
package minesweeper.main;

import flambe.Component;
import flambe.animation.AnimatedFloat;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.TextSprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.PointerEvent;

/**
 * ...
 * @author Anthony Ganzon
 */
class MSBlock extends Component
{
	public var x(default, null): AnimatedFloat;
	public var y(default, null): AnimatedFloat;
	
	public var width(default, null): AnimatedFloat;
	public var height(default, null): AnimatedFloat;
	
	public var idx(default, null): Int;
	public var idy(default, null): Int;
	
	public var hasBomb(default, null): Bool;
	public var isOpened(default, null): Bool;
	public var isMarked(default, null): Bool;
	public var blockValue: Int;
	
	private var blockFont: Font;
	private var innerTexture: Texture;
	private var outerTexture: Texture;
	private var bombTexture: Texture;
		
	private var flagTexture: Texture;
	private var questionTexture: Texture;
	
	private var innerBG: ImageSprite;
	private var blockValueText: TextSprite;
	private var outerBG: ImageSprite;
	private var bombBG: ImageSprite;
	private var markBG: ImageSprite;
	
	private var blockEntity: Entity;
	
	public function new(blockFont: Font, innerTex: Texture, outerTex: Texture, bombTex: Texture, flagTex: Texture, questionTex: Texture) {
		this.x = new AnimatedFloat(0);
		this.y = new AnimatedFloat(0);
		
		this.blockFont = blockFont;
		this.innerTexture = innerTex;
		this.outerTexture = outerTex;
		this.bombTexture = bombTex;
		
		this.flagTexture = flagTex;
		this.questionTexture = questionTex;
		
		this.width = new AnimatedFloat(innerTexture.width);
		this.height = new AnimatedFloat(innerTexture.height);
		
		this.hasBomb = false;
		this.isOpened = false;
		this.isMarked = false;
		this.blockValue = 0;
		
		CreateBlock();
	}
	
	public function CreateBlock(): Void {
		blockEntity = new Entity();
		
		innerBG = new ImageSprite(innerTexture);
		innerBG.centerAnchor();
		blockEntity.addChild(new Entity().add(innerBG));
		
		bombBG = new ImageSprite(bombTexture);
		bombBG.alpha._ = 0;
		bombBG.centerAnchor();
		bombBG.setXY(
			innerBG.x._,
			innerBG.y._
		);
		blockEntity.addChild(new Entity().add(bombBG));
		
		blockValueText = new TextSprite(blockFont, blockValue + "");
		blockValueText.alpha._ = 0;
		blockValueText.centerAnchor();
		blockValueText.setXY(
			innerBG.x._,
			innerBG.y._
		);
		blockEntity.addChild(new Entity().add(blockValueText));
		
		outerBG = new ImageSprite(outerTexture);
		outerBG.centerAnchor();
		outerBG.setXY(
			innerBG.x._,
			innerBG.y._
		);
		blockEntity.addChild(new Entity().add(outerBG));
		
		outerBG.pointerDown.connect(function(event: PointerEvent) {
			SetBlockOpen(true);
		});
		
		markBG = new ImageSprite(flagTexture);
		markBG.alpha._ = 0;
		markBG.centerAnchor();
		markBG.setXY(
			innerBG.x._,
			innerBG.y._
		);
		blockEntity.addChild(new Entity().add(markBG));
	}
	
	public function SetBlockValue(value: Int): Void {
		this.blockValue = value;
		blockValueText.text = blockValue + "";
		
		if (blockValue == -1) {
			SetHasBomb(true);
		}
		else {
			blockValueText.alpha._ = (blockValue == 0) ? 0 : 1;
		}
	}
	
	public function SetHasBomb(hasBomb: Bool): Void {
		this.hasBomb = hasBomb;
		
		if (hasBomb) {
			bombBG.alpha._ = 1;
			blockValueText.alpha._ = 0;
		}
		else {
			blockValueText.alpha._ = 1;
			bombBG.alpha._ = 0;
		}
	}
	
	public function SetBlockOpen(opened: Bool): Void {		
		this.isOpened = opened;
		
		if (isOpened) {
			outerBG.alpha.animate(1, 0, 0.5);
		}
		else {
			outerBG.alpha.animate(0, 1, 0.5);
		}
		
		if(this.blockValue == 0) {
			Utils.OpenNeighbors(this);
		}
	}
	
	public function SetBlockMarked(marked: Bool): Void {		
		this.isMarked = marked;
		if (isMarked) {
			markBG.alpha.animate(0, 1, 0.5);
		}
		else {
			markBG.alpha.animate(1, 0, 0.5);
		}
	}
	
	public function SetBlockID(x: Int, y: Int): Void {
		this.idx = x;
		this.idy = y;
	}
	
	public function SetBlockXY(x: Float, y: Float): MSBlock {
		this.x._ = x;
		this.y._ = y;
		return this;
	}
	
	public function SetBlockSize(w: Float, h: Float): MSBlock {
		this.width._ = w;
		this.height._ = h;
		return this;
	}
	
	public function getNaturalWidth(): Float {
		return width._;
	}
	
	public function getNaturalHeight(): Float {
		return height._;
	}
	
	override public function onAdded() {
		super.onAdded();
		owner.addChild(blockEntity);
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		x.update(dt);
		y.update(dt);
		width.update(dt);
		height.update(dt);
		
		innerBG.setXY(this.x._, this.y._);
		blockValueText.setXY(innerBG.x._, innerBG.y._);
		outerBG.setXY(innerBG.x._, innerBG.y._);
		bombBG.setXY(innerBG.x._, innerBG.y._);
		markBG.setXY(innerBG.x._, innerBG.y._);
	}
}
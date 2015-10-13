package minesweeper.main;

import flambe.animation.AnimatedFloat;
import flambe.Component;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.display.Texture;
import flambe.Disposer;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Repeat;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.System;

import minesweeper.core.SceneManager;
import minesweeper.main.MSUtils;

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

	private var innerTexture: Texture;
	private var innerImage: ImageSprite;
	
	private var blockValueFont: Font;
	private var blockValueText: TextSprite;
	
	private var bombTexture: Texture;
	private var bombImage: ImageSprite;
	
	private var outerTexture: Texture;
	private var outerImage: ImageSprite;
	
	private var flagTexture: Texture;
	private var qMarkTexture: Texture;
	private var markerImage: ImageSprite;
	private var markerCount: UInt;
	
	private var blockEntity: Entity;
	private var blockSprite: Sprite;
	
	private var blockRevealed: Bool;
	private var blockMarked: Bool;
	private var blockHasBomb: Bool;
	private var blockValue: Int;
	
	private var msMain: MSMain;
	private var disposer: Disposer;
	
	// Used to make images underneath the outer image visible even though it is hidden
	private var visualize: Bool;
	
	public function new(main: MSMain, visualize: Bool = false) {
		this.msMain = main;
		this.x = new AnimatedFloat(0);
		this.y = new AnimatedFloat(0);
		
		this.idx = 0;
		this.idy = 0;
		this.markerCount = 0;
		
		this.blockHasBomb = false;
		this.blockRevealed = false;
		this.blockMarked = false;
		this.blockValue = -1;
		
		this.visualize = visualize;
	}
	
	public function Init(innerTex: Texture, valueFont: Font, bombTex: Texture, outerTex: Texture, flagTex: Texture, qMarkTex: Texture) {
		this.innerTexture = innerTex;
		this.blockValueFont = valueFont;
		this.bombTexture = bombTex;
		this.outerTexture = outerTex;
		this.flagTexture = flagTex;
		this.qMarkTexture = qMarkTex;
		
		CreateBlock();
	}
	
	public function CreateBlock(): Void {
		blockEntity = new Entity();
		blockSprite = new Sprite();
		
		var blockButtonEntity: Entity = new Entity();
		
		innerImage = new ImageSprite(innerTexture);
		innerImage.centerAnchor();
		innerImage.visible = false;
		innerImage.setScaleXY(1, (System.stage.width / System.stage.height) + 1);
		blockButtonEntity.addChild(new Entity().add(innerImage));
		
		blockValueText = new TextSprite(blockValueFont, blockValue + "");
		blockValueText.centerAnchor();
		blockValueText.visible = false;
		blockValueText.setScaleXY(1, (System.stage.width / System.stage.height) + 1);
		blockButtonEntity.addChild(new Entity().add(blockValueText));
		
		bombImage = new ImageSprite(bombTexture);
		bombImage.centerAnchor();
		bombImage.visible = false;
		bombImage.setScaleXY(1, (System.stage.width / System.stage.height) + 1);
		blockButtonEntity.addChild(new Entity().add(bombImage));
		
		outerImage = new ImageSprite(outerTexture);
		outerImage.centerAnchor();
		outerImage.setAlpha(visualize ? 0.2 : 1);
		outerImage.setScaleXY(1, (System.stage.width / System.stage.height) + 1);
		blockButtonEntity.addChild(new Entity().add(outerImage));
		
		markerImage = new ImageSprite(flagTexture);
		markerImage.centerAnchor();
		markerImage.visible = false;
		markerImage.setScaleXY(1, (System.stage.width / System.stage.height) + 1);
		blockButtonEntity.addChild(new Entity().add(markerImage));
		
		blockEntity.addChild(blockButtonEntity.add(blockSprite));
	}
	
	public function SetBlockValue(value: Int): Void {
		if (blockHasBomb)
			return;
		
		this.blockValue = value;
		this.blockValueText.text = this.blockValue + "";
		
		if (visualize) {
			blockValueText.visible = (blockValue > 0) ? true : false;
		}
	}
	
	public function SetBlockHasBomb(): Void {
		if (blockValue > -1)
			return;
		
		this.blockHasBomb = true;
		
		if (visualize) {
			bombImage.visible = true;
		}
	}
	
	public function RevealBlock(forceReveal: Bool = false): Void {
		if (!forceReveal && (blockRevealed || blockMarked))
			return;
			
		markerImage.visible = (blockMarked && blockHasBomb) ? true : false;
		
		var script: Script = new Script();
		script.run(new Sequence([
			new CallFunction(function() {
				innerImage.visible = true;
				msMain.canMove = false;
			
				if(!visualize) {
					bombImage.visible = blockHasBomb ? true : false;				
					blockValueText.visible = (blockValue > 0) ? true : false;
				}
				
				if (blockValue == 0) {
					MSUtils.OpenNeighborBlocks(this, msMain.GetBoardBlocks());
				}
			}),
			new AnimateTo(outerImage.alpha, 0, 0.5),
			
			// After all the animation is done.
			new CallFunction(function() {
				outerImage.visible = false;
				msMain.canMove = true;
				msMain.SetOpenBlocksDirty();
				
				if(!forceReveal) {
					if (blockHasBomb) {
						MSUtils.RevealAllBombs(msMain.GetAllBlocks());
						ShakeBomb();
					}
					
					// Trigger game over screen when player picks a bomb block or goal is complete
					if (blockHasBomb || msMain.HasReachedGoals()) {
						msMain.StopGame();
						var gameOverScript: Script = new Script();
						gameOverScript.run(new Sequence([
							new Delay(2.5),
							new CallFunction(function() {
								SceneManager.current.ShowGameOverScreen();
							})
						]));
						
						blockEntity.addChild(new Entity().add(gameOverScript));
					}
				}
				
				// DEBUGGING!
				//if (forceReveal) {
					//SceneManager.current.ShowGameOverScreen();
				//}
				
				// Gradually revealing blocks
				//if (blockValue == 0) {
					//MSUtils.OpenNeighborBlocks(this, msMain.boardBlocks);
				//}
			})
		]));
		
		blockEntity.addChild(new Entity().add(script));
			
		blockRevealed = true;
	}
	
	public function MarkBlock(): Void {
		if (blockRevealed)
			return;
		
		if (msMain.IsMarkedBlocksMax() && markerCount == 0)
			return;
		
		blockMarked = true;
		markerImage.visible = true;
		
		markerCount++;
		if (markerCount > 2) {
			markerCount = 0;
			blockMarked = false;
			markerImage.visible = false;
			markerImage.alpha.animate(1, 0, 0.2);
		}
		
		// Flag
		if (markerCount == 1) {
			markerImage.texture = flagTexture;
			markerImage.alpha.animate(0, 1, 0.2);
			msMain.AddMarkedBlocks();
		}
		// Question Mark
		else if (markerCount == 2) {
			blockMarked = false;
			markerImage.texture = qMarkTexture;
			markerImage.alpha.animate(0, 1, 0.2);
			msMain.SubtractMarkedBlocks();
		}
	}
	
	public function GetBlockValue(): Int {
		return blockValue;
	}
	
	public function IsBlockHasBomb(): Bool {
		return blockHasBomb;
	}
	
	public function IsBlockRevealed(): Bool {
		return blockRevealed;
	}
	
	public function IsBlockMarked(): Bool {
		return blockMarked;
	}
	
	public function ShakeBomb(): Void {
		var shakeScript: Script = new Script();
		shakeScript.run(new Repeat(new Sequence([
			new AnimateTo(bombImage.x, bombImage.x._ + 1, 0.05),
			new AnimateTo(bombImage.x, bombImage.x._ - 1, 0.05),
		])));
		blockEntity.addChild(new Entity().add(shakeScript));
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
		disposer = owner.get(Disposer);
		if (disposer == null) 
			owner.add(disposer = new Disposer());
			
		owner.addChild(blockEntity);
		
		// Send signal to MS Main
		disposer.add(blockSprite.pointerIn.connect(function(event: PointerEvent) {
			msMain.onMouseClick.emit(this);
		}));
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		x.update(dt);
		y.update(dt);
	}
}
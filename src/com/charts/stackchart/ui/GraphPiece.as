package com.charts.stackchart.ui
{
    import com.greensock.TweenMax;
    import com.greensock.easing.Sine;
    import com.greensock.events.TweenEvent;
    
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
	
    public class GraphPiece extends Sprite
    {
    	public var myId:int;
		public var myData:Object;
		public var startX:int;
		public var startY:int;
		public var itemPercent:Number;
		
		private var owner:Object;
		private var myCompleteNum:int;
		private var myColor:uint;
		private var pieceWidth:Number;
		private var pieceDepth:Number;
		private var chartTotalHgt:Number;
		private var useAnimation:Boolean;
		private var floatingHeight:int;
		private var topTrapezoid:Sprite;
		private var whiteLine:Sprite;
		private var sideTrapezoid:Shape;
		private var sideTrapeMask:Shape;
		private var sideTrapeGrade:Shape;
		private var frontRectangle:Shape;
		private var frontRectMask:Shape;
		private var frontRectGrade:Shape;
		private var paramObj:Object = {t:0};
		
		public function GraphPiece(_owner:Object, _myData:Object, _myId:int, _myCompleteNum:Number, _itemPercent:Number, _pieceWidth:Number, _pieceDepth:Number, _chartTotalHgt:int, _useAnimation:Boolean)
		{
			// set vars:
			owner =         _owner;
			myData = 		_myData;
			myId = 			_myId;
			myCompleteNum = _myCompleteNum;
			pieceWidth = 	_pieceWidth;
			pieceDepth = 	_pieceDepth;
			chartTotalHgt = _chartTotalHgt;
			useAnimation =  _useAnimation;
			itemPercent = 	_itemPercent;
			
			// set props:
			mouseChildren = false;
			buttonMode = useHandCursor = true;
			
			// add event listeners:
			// addEventListener(Event.ADDED_TO_STAGE, doSetup);
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		public function doSetup(/* event:Event */):void
		{
			// create the various pieces, add gradients & masks:
			sideTrapezoid = new Shape();
			sideTrapezoid.x = pieceWidth - pieceDepth;
			addChild(sideTrapezoid);
			
			sideTrapeGrade = new Shape()
			sideTrapeGrade.x = pieceWidth - pieceDepth;
			addChild(sideTrapeGrade);
			
			sideTrapeMask = new Shape();
			sideTrapeMask.x = pieceWidth - pieceDepth;
			addChild(sideTrapeMask);
			sideTrapeGrade.mask = sideTrapeMask;
			
			frontRectangle = new Shape();
			addChild(frontRectangle);
			
			frontRectGrade = new Shape();
			addChild(frontRectGrade)
			
			frontRectMask = new Shape();
			addChild(frontRectMask);
			frontRectGrade.mask = frontRectMask;
			
			topTrapezoid = new Sprite();
			topTrapezoid.visible = false;
			topTrapezoid.y = myCompleteNum - pieceDepth;
			addChild(topTrapezoid);
			
			whiteLine = new Sprite();
			whiteLine.visible = false;
			whiteLine.y = myCompleteNum - pieceDepth;
			addChild(whiteLine);
			
			// create top shape (cap), and whiteout fill:
			topTrapezoid.graphics.beginFill(myData.myColor, 1);
			topTrapezoid.graphics.moveTo(pieceDepth, 0);
			topTrapezoid.graphics.lineTo(pieceWidth, 0);
			topTrapezoid.graphics.lineTo((pieceWidth - pieceDepth), pieceDepth);
			topTrapezoid.graphics.lineTo(0, pieceDepth);
			topTrapezoid.graphics.lineTo(pieceDepth, 0);
			topTrapezoid.graphics.endFill();
			
			// topTrapezoid.graphics.lineStyle(1, 0xFFFFFF);
			// lighten cap:
			topTrapezoid.graphics.beginFill(0xFFFFFF, 0.5);
			topTrapezoid.graphics.moveTo(pieceDepth, 0);
			topTrapezoid.graphics.lineTo(pieceWidth, 0);
			topTrapezoid.graphics.lineTo((pieceWidth - pieceDepth), pieceDepth);
			topTrapezoid.graphics.lineTo(0, pieceDepth);
			topTrapezoid.graphics.lineTo(pieceDepth, 0);
			topTrapezoid.graphics.endFill();
			
			// draw white line:
			whiteLine.graphics.beginFill(0xFFFFFF, 1);
			whiteLine.graphics.moveTo(0, pieceDepth);
			whiteLine.graphics.lineTo(0, (pieceDepth + 1));
			whiteLine.graphics.lineTo((pieceWidth - pieceDepth), (pieceDepth + 1));
			whiteLine.graphics.lineTo(pieceWidth, 1);
			whiteLine.graphics.lineTo(pieceWidth, 0);
			whiteLine.graphics.lineTo((pieceWidth - pieceDepth), pieceDepth);
			whiteLine.graphics.lineTo(0, pieceDepth);
			whiteLine.graphics.lineTo(0, (pieceDepth + 1));
			whiteLine.graphics.endFill();
			
			// create gradient fills for front & side:
			// KITEMATH is requesting no gradient fill on this project:
			/* 
		 	var ratios:Array = [0, 255];
		 	var sideColors:Array = [0x000000, 0x000000];
            var sideAlphas:Array = [0.3, 0.6];
			var sideMatrix:Matrix = new Matrix();
            sideMatrix.createGradientBox(pieceDepth, chartTotalHgt, Math.PI / 2, 0, 0 - startY);
            sideTrapeGrade.graphics.beginGradientFill(GradientType.LINEAR, sideColors, sideAlphas, ratios, sideMatrix);
            */
            sideTrapeGrade.graphics.beginFill(0x000000, 0.33);
			sideTrapeGrade.graphics.moveTo(0, pieceDepth);
			sideTrapeGrade.graphics.lineTo(pieceDepth, 0);
			sideTrapeGrade.graphics.lineTo(pieceDepth, (myCompleteNum - pieceDepth));
			sideTrapeGrade.graphics.lineTo(0, myCompleteNum);
			sideTrapeGrade.graphics.lineTo(0, pieceDepth);
			sideTrapeGrade.graphics.endFill();
			
			/*  
            var frontColors:Array = [0xFFFFFF, 0x000000];
            var frontAlphas:Array = [0.15, 0.3];
			var frontMatrix:Matrix = new Matrix();
            frontMatrix.createGradientBox(pieceWidth, chartTotalHgt, Math.PI / 2, 0, 0 - startY);
            frontRectGrade.graphics.beginGradientFill(GradientType.LINEAR, frontColors, frontAlphas, ratios, frontMatrix);
			frontRectGrade.graphics.drawRect(0, 0, (pieceWidth - pieceDepth), (myCompleteNum + pieceDepth));
			frontRectGrade.graphics.endFill();
			*/
			frontRectGrade.graphics.beginFill(0xff0000, 0);
			frontRectGrade.graphics.drawRect(0, 0, (pieceWidth - pieceDepth), (myCompleteNum + pieceDepth));
			frontRectGrade.graphics.endFill();
			// TODO - replace gradients for next project if we use this iteration.
			
			// draw immediately, or wait for animation cue:
			if (useAnimation)
			{
				floatingHeight = 0;
			}
			else
			{
				floatingHeight = myCompleteNum - pieceDepth;
				topTrapezoid.visible = true;	
				whiteLine.visible = true;
				drawTop();
				drawSide();
				drawFront();
			}
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- 
		// do animation:
		
		public function startAnimation(timeNum:Number, delayNum:Number):void
		{
			TweenMax.to(paramObj, timeNum, {t:(myCompleteNum - pieceDepth), delay:delayNum, ease:Sine.easeOut, onUpdateListener:drawObjects, onStart:makeElementsVisible()});
			TweenMax.from(this, timeNum/2, {alpha:0, delay:delayNum, ease:Sine.easeOut});
		}
		
		private function makeElementsVisible():void
		{
			topTrapezoid.visible = true;
			whiteLine.visible = true;
		}
		
		private function drawObjects(tweenEvent:TweenEvent):void
		{
			floatingHeight = paramObj.t;
			
			drawTop();
			drawSide();
			drawFront();
		}
		
		public function rolloverAnim(timeNum:Number):void
		{
			if (owner.selectedGraphPiece != this)
			{
				TweenMax.to(this, timeNum/2, {x:Math.round(startX - pieceDepth/3), y:Math.round(startY + pieceDepth/3), ease:Sine.easeOut});
				// TweenMax.to(whiteLine, timeNum/2, {alpha:0, ease:Sine.easeOut});
			}
			
		}
		
		public function rolloutAnim(timeNum:Number):void
		{
			if (owner.selectedGraphPiece != this)
			{
				 TweenMax.to(this, timeNum/2, {x:startX, y:startY, ease:Sine.easeIn});
				 // TweenMax.to(whiteLine, timeNum/2, {alpha:1, ease:Sine.easeIn});
			}
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- 
		// draw all sides:
		
        private function drawTop():void
        {	
			// update y position:
			topTrapezoid.y = myCompleteNum - (floatingHeight + pieceDepth);
			whiteLine.y = myCompleteNum - (floatingHeight + pieceDepth);
        }
		
		private function drawSide():void
		{
			// clear:
			sideTrapezoid.graphics.clear();
			 
			// draw:
			sideTrapezoid.graphics.beginFill(myData.myColor, 1);
			sideTrapezoid.graphics.moveTo(0, pieceDepth);
			sideTrapezoid.graphics.lineTo(pieceDepth, 0);
			sideTrapezoid.graphics.lineTo(pieceDepth, floatingHeight);
			sideTrapezoid.graphics.lineTo(0, (floatingHeight + pieceDepth));
			sideTrapezoid.graphics.lineTo(0, pieceDepth);
			sideTrapezoid.graphics.endFill();
			  
			sideTrapeMask.graphics.beginFill(0x0000FF, 1);
			sideTrapeMask.graphics.moveTo(0, pieceDepth);
			sideTrapeMask.graphics.lineTo(pieceDepth, 0);
			sideTrapeMask.graphics.lineTo(pieceDepth, floatingHeight);
			sideTrapeMask.graphics.lineTo(0, (floatingHeight + pieceDepth));
			sideTrapeMask.graphics.lineTo(0, pieceDepth);
			sideTrapeMask.graphics.endFill();
			
			// update y positions:
			sideTrapezoid.y = sideTrapeMask.y = myCompleteNum - (floatingHeight + pieceDepth);
        }
		
		private function drawFront():void
		{
			// clear:
			frontRectangle.graphics.clear();
			
			// draw:
			frontRectangle.graphics.beginFill(myData.myColor, 1);
			frontRectangle.graphics.drawRect(0, 0, (pieceWidth - pieceDepth), floatingHeight);
			frontRectangle.graphics.endFill();
			
			frontRectMask.graphics.beginFill(0x0000FF, 1);
			frontRectMask.graphics.drawRect(0, 0, (pieceWidth - pieceDepth), floatingHeight);
			frontRectMask.graphics.endFill();
			
			// update y positions:
			frontRectangle.y = frontRectMask.y = myCompleteNum - floatingHeight;
        }
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		// cleanup:
		
		private function cleanup(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		
    }
}

package com.charts.stackchart
{
	import com.charts.events.ChartClickEvent;
	import com.charts.stackchart.ui.BaseBackground;
	import com.charts.stackchart.ui.GraphPiece;
	import com.charts.stackchart.ui.LegendItem;
	import com.charts.stackchart.ui.RolloverTip;
	import com.charts.stackchart.ui.TitlePanel;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.utils.*;
	
	import mx.core.UIComponent;

	public class StackChartComponent extends UIComponent
	{
		// creation vars:
		public var myRoot:Object;
		public var myData:Object;
		public var chartWidth:int;
		public var chartHeight:int;
		public var pieceWidth:int;
		public var pieceDepth:int;
		public var legendBoxSize:int;
		public var legendTextSize:int;
		public var legendPadding:int;
		public var transTime:Number;
		public var themeColor:uint;
		public var legendTextColor:uint;
		public var titleTextSize:int;
		public var titleTextColor:uint;
		public var useBgGfx:Boolean;
		public var useAnimation:Boolean;
		public var useDollarsLegend:Boolean;
		public var useTitlePanel:Boolean;
		public var legendLocation:String;
		public var enableChartRollover:Boolean;
		public var enableLegendRollover:Boolean;
		public var graphPieces:Array;
		public var legendItems:Array;
		public var selectedGraphPiece:GraphPiece;
		
		// public vars to store completed layout width & height - essential for FLEX framework:
		public var myCompleteHeight:int;
		public var myCompleteWidth:int;
		
		// layout vars & items:
		private var chartTitle:String;    // set in the parent view, and passed along with the data object
		private var chartTotalHgt:int; 	  // total height of the column of pieces (filled AND unfilled) equal to chartHeight MINUS offset for base gfx
		private var dollarsTotal:Number;
		private var holderSprite:Sprite;
		private var legendSprite:Sprite;
		private var blockerSprite:Sprite;
		private var baseBg:BaseBackground;
		private var titlePanel:TitlePanel;
		private var rolloverTip:RolloverTip;
		private var dropShadow:DropShadowFilter = new DropShadowFilter(5, 315, 0x000000, 0.15, 5, 5, 1, 3);
		private var timeOut:uint;
		private var completeNumbers:Array = new Array();
		private var itemPercents:Array = new Array();
		private var isCreated:Boolean = false;
		
		public function StackChartComponent(){}
		
		public function setupGraph():void
		{
			if(!myData)
			{
				return;
			}
			
			if(pieceDepth <= (pieceWidth / 4))
			{
				// init vals:
				graphPieces = new Array();
				legendItems = new Array();	
				completeNumbers = new Array();
				itemPercents = new Array();
				
				chartTotalHgt = chartHeight - (pieceDepth * 2);
				
				// ** ** ** ** ** ** 
				// create children:
				 chartTitle = myData.chart.chartName;
				titlePanel = new TitlePanel(myData, chartTitle, titleTextSize, titleTextColor, chartWidth, pieceDepth, useTitlePanel);
				addChild(titlePanel); 
				titlePanel.doSetup();
				
				baseBg = new BaseBackground(chartHeight, chartWidth, pieceDepth, themeColor, useBgGfx, legendLocation);
				addChild(baseBg);
				baseBg.doSetup();
				
				legendSprite = new Sprite();
				addChild(legendSprite);
				
				holderSprite = new Sprite();
				holderSprite.filters = [/* dropShadow */];
				addChild(holderSprite);
				
				blockerSprite = new Sprite();
				blockerSprite.graphics.beginFill(0xFF0000, 0);
				blockerSprite.graphics.drawRect(0, 0, chartWidth, chartHeight);
				blockerSprite.graphics.endFill();
				addChild(blockerSprite);
				
				// ** ** ** ** ** ** 
				// add up the total of all the myDollars:
				dollarsTotal = 0;
				var segmentsMax:int = myData.chart.chartVals.length;
				for (var l:int = 0; l < segmentsMax; l++)
				{
					dollarsTotal += myData.chart.chartVals[l].myDollars;
				}
				
				// ** ** ** ** ** ** 
				// set up graph pieces and legend:
				var data:Array = myData.chart.chartVals; // shortcut to data for each graph piece
				var pieceOffset:int = (data.length > 1) ? pieceDepth * (data.length) : pieceDepth; // account for depth offset of each graph piece, excluding the top graph piece
				var leftOvers:Number = 0;
				
				// ** ** ** ** ** ** 
				// start calculating piece heights - start by getting the height for each piece, then comparing to see if it's tall enough:
				var minimumHeight:Number = pieceDepth + 4; // arbitrary min height - 'height' PLUS pieceDepth
				for (var i:int = 0; i < data.length; i++)
				{
					var completeNum:Number = Math.round((data[i].myDollars / dollarsTotal) * (chartTotalHgt + pieceOffset));
					var itemPercent:Number = Math.round((data[i].myDollars / dollarsTotal) * 100);
					
					if (completeNum < minimumHeight)
					{
						leftOvers += (minimumHeight - completeNum);
						completeNum = minimumHeight;
					}
					
					itemPercents.push(itemPercent);
					completeNumbers.push(completeNum);
				}	
				
				// **** SUBTRACT 'leftOvers' from the all segments TALLER than min height ****
				if(data.length > 1)
				{
					// get the amount of items TALLER than the min height, to subtract from each later
					var tallerThanMinHgt:int = 0;
					
				    for (var m:int = 0; m < completeNumbers.length; m++) 
				    {
				    	if (completeNumbers[m] > minimumHeight)
				    	{
				    		tallerThanMinHgt ++;
				    	}
				    }
				    
				    // subtract a portion of 'leftOver' from each piece TALLER than min height:
				    for (var n:int = 0; n < completeNumbers.length; n++) 
				    {
				    	if (completeNumbers[n] > minimumHeight)
				    	{
							var newCompleteNum:Number = Math.floor( completeNumbers[n] - (leftOvers / tallerThanMinHgt) );
							if( newCompleteNum > minimumHeight ){
				    			completeNumbers[n] = newCompleteNum;
							}
				    	}
				    }
				}
				
				// ** ** ** ** ** ** 
				// now that we've got all the numbers - do visual layout:
				layoutGraph();
			}

			else
			{
				// condition where depth is too great:
				throw new Error("pieceDepth must be 1/4 pieceWidth or less. This pieceDepth is not allowed", 69);
			}
		}
		
		// -- -- -- -- -- -- -- -- -- -- --
		// do actual layout:
		
		private function layoutGraph():void
		{ 
			var data:Array = myData.chart.chartVals; 				   // shortcut to data for each graph piece
			var pieceOffset:int = pieceDepth * (data.length - 1); 	   // account for depth offset of each graph piece, excluding the top graph piece
			var startPos:int = 0;
			
			if(dollarsTotal > 0)
			{	
				for (var i:int = 0; i < data.length; i++)
				{	
					// set up graph pieces:
					var graphPiece:GraphPiece = new GraphPiece(this, data[i], i, completeNumbers[i], itemPercents[i], pieceWidth, pieceDepth, chartTotalHgt, useAnimation);
					graphPiece.x = graphPiece.startX = 0;
					graphPiece.y = graphPiece.startY = startPos;
					startPos += (completeNumbers[i] - pieceDepth);
					graphPiece.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					graphPiece.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
					graphPiece.addEventListener(MouseEvent.CLICK, clickHandler);
					holderSprite.addChild(graphPiece);
					graphPieces.push(graphPiece);
					graphPiece.doSetup();
					
					// set up legend:
					var legendItem:LegendItem = new LegendItem(data[i], i, legendTextSize, legendBoxSize, legendTextColor, useDollarsLegend, useAnimation);
					if(enableLegendRollover){
						legendItem.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
						legendItem.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
						legendItem.addEventListener(MouseEvent.CLICK, clickHandler);
						legendItem.mouseChildren = false;
						legendItem.buttonMode = legendItem.useHandCursor = true;
						legendItem.cacheAsBitmap = true;
					}
					legendItems.push(legendItem);
					legendSprite.addChild(legendItem);
					legendItem.doSetup();
				}
			}
			
			completeLayout();
		}
		
		public function getGraphPieceIndexByDataID(id:int):int
		{
			var totalPieces:int = this.graphPieces.length;
			var gp:GraphPiece;
			for(var i:int = 0; i < totalPieces; i++)
			{
				gp = this.graphPieces[i] as GraphPiece;
				if(gp.myData.id == id)
				{
					return i;
				}
			}
			return null;
		}
		
		// -- -- -- -- -- -- -- -- -- -- --
		// layout completion handler:
		
		private function completeLayout():void
		{
			var startPos:int = 0;
			var data:Array = myData.chart.chartVals; 
			
			// sort z depths for graph pieces:
			for (var i:int = graphPieces.length - 1; i > - 1; i--)
			{
				holderSprite.setChildIndex(graphPieces[i], holderSprite.numChildren - 1);
			}
			
			// position items within legend sprite, account for items created:
			for (var j:int = 0; j < legendItems.length; j++)
			{	
				legendItems[j].y = Math.round(startPos);
				startPos += legendItems[j].height + legendPadding;	
			}
			
			// position ALL holder sprites, account for items created, rounded numbers:
			switch (legendLocation.toLowerCase())
			{
				case "left":
					baseBg.y = titlePanel.height + pieceDepth;
					legendSprite.x = pieceDepth;
					legendSprite.y = (baseBg.y + baseBg.height) - ( legendSprite.height + 10 );
					holderSprite.x = chartWidth - (pieceWidth + pieceDepth * 2);
					// set complete height - for FLEX:
					myCompleteHeight = titlePanel.height + pieceDepth + baseBg.height;
					myCompleteWidth = chartWidth;
				break;
				case "right":
					baseBg.y = titlePanel.height + pieceDepth;
					legendSprite.x = pieceDepth + pieceWidth + pieceDepth + 24;
					legendSprite.y = (baseBg.y + baseBg.height) - ( legendSprite.height + 10 );
					holderSprite.x = pieceDepth * 2;
					// set complete height - for FLEX:
					myCompleteHeight = titlePanel.height + pieceDepth + baseBg.height;
					myCompleteWidth = chartWidth;
				break;
				case "top":
					holderSprite.x = (chartWidth - (pieceWidth + pieceDepth))/2;
					legendSprite.x = pieceDepth;
					if(useTitlePanel)
					{
						legendSprite.y = titlePanel.height + pieceDepth;
						baseBg.y = titlePanel.height + legendSprite.height + pieceDepth;
					}
					else
					{
						legendSprite.y = 0;
						baseBg.y = legendSprite.height + pieceDepth;
					}
					// set complete height - for FLEX:
					myCompleteHeight = titlePanel.height + pieceDepth + legendSprite.y + legendSprite.height + pieceDepth + baseBg.height;
					myCompleteWidth = chartWidth;
				break;
				case "bottom":
					holderSprite.x = (chartWidth - (pieceWidth + pieceDepth))/2;
					legendSprite.x = pieceDepth;
					if(useTitlePanel)
					{
						baseBg.y = titlePanel.height + pieceDepth;
					}
					else
					{
						baseBg.y = 0;
					}
					legendSprite.y = baseBg.y + baseBg.height + pieceDepth;
					// set complete height - for FLEX:
					myCompleteHeight = titlePanel.height + pieceDepth + baseBg.y + baseBg.height + pieceDepth + legendSprite.height;
					myCompleteWidth = chartWidth;
				break;
			}
			
			holderSprite.y = (baseBg.y + baseBg.height) - holderSprite.height;
			blockerSprite.y = baseBg.y;
			
			// notify FLEX framework about height & width - so these can be bindable:
			isCreated = true;
			measure();
			
			// stop blocking interactions, now that layout is complete - ELSE see buildChartAnim method:
			if(!useAnimation)
			{
				blockerSprite.visible = false;
			} 
			else
			{
				buildChartAnim();
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			
			if(isCreated)
			{
				width = myCompleteWidth;
				height = myCompleteHeight;
			}
			else
			{
				width = 0;
				height = 0;
			}
			
			myRoot.validateNow();
		}
		
		public function buildChartAnim():void
		{
			var startDelay:Number = 0;
			
			for (var k:int = graphPieces.length - 1; k > - 1; k--)
			{
				graphPieces[k].startAnimation(transTime, startDelay);
				legendItems[k].startAnimation(transTime, (transTime * legendItems.length));
				startDelay += transTime;
			}
			
			var totalTime:Number = Math.round((transTime * legendItems.length) * 1000);
			timeOut = setTimeout(timeoutHandler, totalTime);
		}
		
		private function timeoutHandler():void
		{
			blockerSprite.visible = false;
		}
		
		// -- -- -- -- -- -- -- -- -- -- --
		// handlers:
		
		private function rollOverHandler(event:MouseEvent):void
		{
			var graphPiece:GraphPiece = graphPieces[event.target.myId];
			var legendItem:LegendItem = legendItems[event.target.myId];
			var itemPercent:Number = graphPieces[event.target.myId].itemPercent;
			
			legendItem.rolloverAnim(transTime);
			graphPiece.rolloverAnim(transTime);
				
			if(enableChartRollover)
			{
				// cleanup if tip is present:
				if(rolloverTip != null)
				{
					myRoot.removeElement(rolloverTip);
					rolloverTip = null;
				}
				
				// create new tip:
				rolloverTip = new RolloverTip(graphPiece.myData, graphPiece.myId, legendTextSize, legendTextColor, dollarsTotal, itemPercent, themeColor, legendLocation);
				rolloverTip.doSetup();
				
				// position tip & do rollover animation:
				switch (legendLocation.toLowerCase())
				{
					case "left":
						var tipPoint:Point = new Point(holderSprite.x + holderSprite.width, holderSprite.y + (graphPiece.y + (graphPiece.height)/2) - rolloverTip.height/2);
						var tipPointGlobal:Point = localToGlobal(tipPoint);
						var myRootTipPoint:Point = myRoot.globalToContent(tipPointGlobal);
						rolloverTip.x = myRootTipPoint.x + 30;
						rolloverTip.y = myRootTipPoint.y;
					break;
					case "right":
						/*
						var tipPoint:Point = new Point((holderSprite.x - rolloverTip.width) - pieceDepth, holderSprite.y + (graphPiece.y + (graphPiece.height)/2) - rolloverTip.height/2);
						var tipPointGlobal:Point = localToGlobal(tipPoint);
						var myRootTipPoint:Point = myRoot.globalToContent(tipPointGlobal);
						rolloverTip.x = myRootTipPoint.x - (rolloverTip.width + 30);
						rolloverTip.y = myRootTipPoint.y;
						*/
						var tipPoint:Point = new Point(holderSprite.x + holderSprite.width, holderSprite.y + (graphPiece.y + (graphPiece.height)/2) - rolloverTip.height/2);
						var tipPointGlobal:Point = localToGlobal(tipPoint);
						var myRootTipPoint:Point = myRoot.globalToContent(tipPointGlobal);
						rolloverTip.x = myRootTipPoint.x + 30;
						rolloverTip.y = myRootTipPoint.y;
					break;
					default:
						var tipPoint:Point = new Point(holderSprite.x + holderSprite.width, holderSprite.y + (graphPiece.y + (graphPiece.height)/2) - rolloverTip.height/2);
						var tipPointGlobal:Point = localToGlobal(tipPoint);
						var myRootTipPoint:Point = myRoot.globalToContent(tipPointGlobal);
						rolloverTip.x = myRootTipPoint.x + 30;
						rolloverTip.y = myRootTipPoint.y;
				}
				
				myRoot.addElement(rolloverTip);
				 
				rolloverTip.animateIn(transTime, tipPointGlobal.x);
				legendItem.rolloverAnim(transTime);
				graphPiece.rolloverAnim(transTime);
			}
		}
		
		private function rollOutHandler(event:MouseEvent):void
		{
			var graphPiece:GraphPiece = graphPieces[event.target.myId];
			var legendItem:LegendItem = legendItems[event.target.myId];
			
			legendItem.rolloutAnim(transTime);
			graphPiece.rolloutAnim(transTime);
			
			if(rolloverTip != null)
			{	
				myRoot.removeElement(rolloverTip);
				rolloverTip = null;
			}
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			var legendItem:LegendItem = legendItems[event.target.myId];
			var graphPiece:GraphPiece = graphPieces[event.target.myId];
			
			legendItem.rolloutAnim(transTime);
			graphPiece.rolloutAnim(transTime);
			
			if(rolloverTip != null)
			{
				myRoot.removeChild(rolloverTip);
				rolloverTip = null;
			}
				
			// always pass the graph piece, which contains data, and positioning props:
			var evt:ChartClickEvent = new ChartClickEvent(ChartClickEvent.CHART_CLICK_EVENT, graphPiece);
			dispatchEvent(evt);
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		// cleanup:
		
		public function cleanup():void
		{
			clearTimeout(timeOut);
			
			var data:Array = myData.chart.chartVals; 	
			
			// remove listeners:
			if (dollarsTotal > 0)
			{
				for (var k:int = 0; k < data.length; k++)
				{	
					var graphPiece:GraphPiece = graphPieces[k];
					graphPiece.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					graphPiece.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
					graphPiece.removeEventListener(MouseEvent.CLICK, clickHandler);
					
					var legendItem:LegendItem = legendItems[k];
					legendItem.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					legendItem.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
					legendItem.removeEventListener(MouseEvent.CLICK, clickHandler);
				}
			}
			
			// reset arrays:
			graphPieces = null;
			legendItems = null;
			
			// remove children:
			removeChild(titlePanel); 
			titlePanel = null;
			
			removeChild(baseBg);
			baseBg = null;
			
			removeChild(legendSprite);
			legendSprite = null;
			
			removeChild(holderSprite);
			holderSprite = null;
			
			removeChild(blockerSprite);
			blockerSprite = null;
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		
	}
}
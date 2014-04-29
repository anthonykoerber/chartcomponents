package com.charts.stackchart
{
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

	public class StackDualChartComponent extends UIComponent
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
		public var selectedGraphPiece:GraphPiece;
		
		// public vars to store completed layout width & height - essential for FLEX framework:
		public var myCompleteHeight:int;
		public var myCompleteWidth:int;
		
		// layout vars & items:
		private var chartTitle:String;
		private var dollarsTotal1:Number;
		private var dollarsTotal2:Number;
		private var chartTotalHgt1:int; 	  // total height of the column of pieces (filled AND unfilled) - some percent SHORTER for comparison
		private var chartTotalHgt2:int; 	  // total height of the column of pieces (filled AND unfilled) equal to chartHeight MINUS offset for base gfx
		private var graphPieces1:Array;
		private var graphPieces2:Array;
		private var legendItems:Array;
		private var holderSprite1:Sprite;
		private var holderSprite2:Sprite;
		private var blockerSprite:Sprite;
		private var legendSprite:Sprite;
		private var baseBg:BaseBackground;
		private var titlePanel:TitlePanel;
		private var rolloverTip:RolloverTip;
		private var dropShadow:DropShadowFilter = new DropShadowFilter(5, 315, themeColor, 0.15, 5, 5, 1, 3);
		private var isCreated:Boolean = false;
		private var timeOut:uint;
		private var completeNumbers1:Array = new Array();
		private var completeNumbers2:Array = new Array();
		private var itemPercents1:Array = new Array();
		private var itemPercents2:Array = new Array();
		
		public function StackDualChartComponent(){}
		
		public function setupGraph():void
		{
			if(pieceDepth <= (pieceWidth / 4))
			{
				// init vals:
				graphPieces1 = new Array();
				graphPieces2 = new Array();
				legendItems = new Array();	
				completeNumbers1 = new Array();
				completeNumbers2 = new Array();
				itemPercents1 = new Array();
				itemPercents2 = new Array();
				
				// ** ** ** ** ** ** 
				// create children:
				chartTitle = myData.chartName;
				titlePanel = new TitlePanel(myData, chartTitle, titleTextSize, titleTextColor, chartWidth, pieceDepth, useTitlePanel);
				titlePanel.doSetup();
				addChild(titlePanel); 
				
				baseBg = new BaseBackground(chartHeight, chartWidth, pieceDepth, themeColor, useBgGfx, legendLocation);
				baseBg.doSetup();
				addChild(baseBg);
				
				legendSprite = new Sprite();
				addChild(legendSprite);
				
				holderSprite1 = new Sprite();
				holderSprite1.filters = [/*dropShadow*/];
				addChild(holderSprite1);
				
				holderSprite2 = new Sprite();
				holderSprite2.filters = [/*dropShadow*/];
				addChild(holderSprite2);
				
				blockerSprite = new Sprite();   						   // block legend and graph during animated transition:
				blockerSprite.graphics.beginFill(0xFF0000, 0);
				blockerSprite.graphics.drawRect(0, 0, chartWidth, chartHeight);
				blockerSprite.graphics.endFill();
				addChild(blockerSprite);
				
				// ** ** ** ** ** ** 
				// add up the total of all the myDollars:
				dollarsTotal1 = 0;
				dollarsTotal2 = 0;
				var segmentsMax1:int = myData.chart1.chartVals.length;
				var segmentsMax2:int = myData.chart2.chartVals.length;
				for (var i:int = 0; i < segmentsMax1; i++)
				{
					dollarsTotal1 += myData.chart1.chartVals[i].myDollars;
				}
				
				for (var j:int = 0; j < segmentsMax2; j++)
				{
					dollarsTotal2 += myData.chart2.chartVals[j].myDollars;
				}
				
				var data1:Array = myData.chart1.chartVals; 				   // shortcut to data for each graph piece of CHART 1
				var data2:Array = myData.chart2.chartVals; 				   // shortcut to data for each graph piece of CHART 2
				var pieceOffset1:int = (data1.length > 1) ? pieceDepth * (data1.length) : pieceDepth; // account for depth offset of each graph piece CHART 1
				var pieceOffset2:int = (data2.length > 1) ? pieceDepth * (data2.length) : pieceDepth; // account for depth offset of each graph piece CHART 2
				var leftOvers1:Number = 0; 								   // needed to account for rounding of CHART 1
				var leftOvers2:Number = 0; 								   // needed to account for rounding of CHART 2
				var totalPixels:int = chartHeight - (pieceDepth*2);		   // *** the TOTAL amount of pixels which the TALLEST chart should occupy ***
				
				// ** ** ** ** ** ** 
				// figure out the difference - this will make CHART 1 comparatively SHORTER than CHART 2:
				var higherNum:Number;
				var lowerNumber:Number;
				
				if(dollarsTotal1 < dollarsTotal2)
				{
					higherNum = dollarsTotal2;
					lowerNumber = dollarsTotal1;
					
					var diff:int = Math.round(higherNum - lowerNumber);
					var diffPercent:Number = Math.round((diff / higherNum) * 100);
					var diffPixels:Number = Math.round((diffPercent * totalPixels)/100);
					
					chartTotalHgt1 = totalPixels - diffPixels;
					chartTotalHgt2 = totalPixels;
				}
				else
				{
					higherNum = dollarsTotal1;
					lowerNumber = dollarsTotal2;
					
					var diff:int = Math.round((higherNum - lowerNumber));
					var diffPercent:Number = Math.round((diff / higherNum) * 100);
					var diffPixels:Number = Math.round((diffPercent * totalPixels)/100);
				
					chartTotalHgt1 = totalPixels;
					chartTotalHgt2 = totalPixels - diffPixels;
				}
				
				// ** ** ** ** ** ** 
				// start calculating piece heights - start by getting the height for each piece, then comparing to see if it's tall enough
				// this must be done twice, because we can't assume that CHART 1 & CHART2 will have *EXACTLY* the same number of segments:
				var minimumHeight:Number = pieceDepth + 4; // arbitrary min height - 'height' PLUS pieceDepth
				for (var k:int = 0; k < data1.length; k++)
				{
					var completeNum:Number = Math.round((data1[k].myDollars / dollarsTotal1) * (chartTotalHgt1 + pieceOffset1));
					var itemPercent1:Number = Math.round((data1[k].myDollars / dollarsTotal1) * 100);
					
					if (completeNum < minimumHeight)
					{
						leftOvers1 += (minimumHeight - completeNum);
						completeNum = minimumHeight;
					}
					
					itemPercents1.push(itemPercent1);
					completeNumbers1.push(completeNum);
				}	
				
				for (var l:int = 0; l < data2.length; l++)
				{
					var completeNum:Number = Math.round((data2[l].myDollars / dollarsTotal2) * (chartTotalHgt2 + pieceOffset2));
					var itemPercent2:Number = Math.round((data2[l].myDollars / dollarsTotal2) * 100);
					
					if (completeNum < minimumHeight)
					{
						leftOvers2 += (minimumHeight - completeNum);
						completeNum = minimumHeight;
					}
					
					itemPercents2.push(itemPercent2);
					completeNumbers2.push(completeNum);
				}
				
				// **** SUBTRACT 'leftOvers' from the all segments TALLER than min height ****
				// this must be done twice, because we can't assume that CHART 1 & CHART2 will have *EXACTLY* the same number of segments:
				if(data1.length > 1 && data2.length > 1)
				{
					// get the amount of items TALLER than the min height, to subtract from each later
					var tallerThanMinHgt1:int = 0;
					var tallerThanMinHgt2:int = 0;
					
				    for (var m:int = 0; m < completeNumbers1.length; m++) 
				    {
				    	if (completeNumbers1[m] > minimumHeight)
				    	{
				    		tallerThanMinHgt1 ++;
				    	}
				    }
				    
				    for (var o:int = 0; o < completeNumbers2.length; o++) 
				    {
				    	if (completeNumbers2[o] > minimumHeight)
				    	{
				    		tallerThanMinHgt2 ++;
				    	}
				    }
				    
				    // subtract a portion of 'leftOver' from each piece TALLER than min height:
				    for (var n:int = 0; n < completeNumbers1.length; n++) 
				    {
				    	var newCompleteNum = Math.floor( completeNumbers1[n] - (leftOvers1 / tallerThanMinHgt1) );
						if( newCompleteNum > minimumHeight ){
							completeNumbers1[n] = newCompleteNum;
						}
				    }
				    
				    for (var p:int = 0; p < completeNumbers2.length; p++) 
				    {
						var newCompleteNum = Math.floor( completeNumbers1[n] - (leftOvers2 / tallerThanMinHgt2) );
						if( newCompleteNum > minimumHeight ){
							completeNumbers2[n] = newCompleteNum;
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
		// do layout:
		public function layoutGraph():void
		{
			var data1:Array = myData.chart1.chartVals; 				   // shortcut to data for each graph piece of CHART 1
			var data2:Array = myData.chart2.chartVals; 				   // shortcut to data for each graph piece of CHART 2
			var startPos1:int = 0;
			var startPos2:int = 0;
			
			// set up graph pieces for CHART 1:
			if(dollarsTotal1 > 0)
			{
				for (var i:int = 0; i < data1.length; i++)
				{	
					var graphPiece1:GraphPiece = new GraphPiece(this, data1[i], i, completeNumbers1[i], itemPercents1[i], pieceWidth, pieceDepth, chartTotalHgt1, useAnimation);
					graphPiece1.x = graphPiece1.startX = 0;
					graphPiece1.y = graphPiece1.startY = startPos1;
					startPos1 += (completeNumbers1[i] - pieceDepth);
					graphPiece1.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					graphPiece1.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
					graphPiece1.addEventListener(MouseEvent.CLICK, clickHandler);
					graphPiece1.doSetup();
					holderSprite1.addChild(graphPiece1);
					graphPieces1.push(graphPiece1);
				}
			}
			
			// set up graph pieces for CHART 2:
			if(dollarsTotal2 > 0)
			{
				for (var j:int = 0; j < data2.length; j++)
				{	
					var graphPiece2:GraphPiece = new GraphPiece(this, data2[j], j, completeNumbers2[j], itemPercents2[j], pieceWidth, pieceDepth, chartTotalHgt2, useAnimation);
					graphPiece2.x = graphPiece2.startX = 0;
					graphPiece2.y = graphPiece2.startY = startPos2;
					startPos2 += (completeNumbers2[j] - pieceDepth);
					graphPiece2.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					graphPiece2.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
					graphPiece2.addEventListener(MouseEvent.CLICK, clickHandler);
					graphPiece2.doSetup();
					holderSprite2.addChild(graphPiece2);
					graphPieces2.push(graphPiece2);
				}
			}
				
			// set up legend - assumes 1 legend, with *potential* variation in number of segment types
			// this is accounted for by finding out which data has more items:
			var largerData:Array;
			if(data1.length > data2.length)
			{
				largerData = data1;	
			}
			else
			{
				largerData = data2;
			}
			
			for (var k:int = 0; k < largerData.length; k++)
			{	
				var legendItem:LegendItem = new LegendItem(largerData[k], k, legendTextSize, legendBoxSize, legendTextColor, useDollarsLegend, useAnimation);
				legendItem.doSetup();
				legendItem.buttonMode = legendItem.useHandCursor = false;
				legendItems.push(legendItem);
				legendSprite.addChild(legendItem);
			}
			
			completeLayout()
		}
		
		// -- -- -- -- -- -- -- -- -- -- --
		// layout completion handler:
		private function completeLayout():void
		{
			var startPos:int = 0;
			var data1:Array = myData.chart1.chartVals;
			var data2:Array = myData.chart2.chartVals;
			
			// sort z depths for graph pieces:
			for (var i:int = graphPieces1.length - 1; i > - 1; i--)
			{
				holderSprite1.setChildIndex(graphPieces1[i], holderSprite1.numChildren - 1);
			}
			
			for (var k:int = graphPieces2.length - 1; k > - 1; k--)
			{
				holderSprite2.setChildIndex(graphPieces2[k], holderSprite2.numChildren - 1);
			}
			
			// position items within legend sprite, account for items created:
			for (var j:int = 0; j < legendItems.length; j++)
			{	
				legendItems[j].y = Math.round(startPos);
				startPos += legendItems[j].height + legendPadding;	
			}
			
			// position ALL holder sprites, account for items created. 
			// ORDER is very important, bcause some items are positioned by others:
			switch (legendLocation.toLowerCase())
			{
				case "top":
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
			
			holderSprite1.x = 0 + pieceDepth*2;
			holderSprite2.x = chartWidth - (pieceWidth + pieceDepth*2);
			holderSprite1.y = (baseBg.y + baseBg.height) - holderSprite1.height;
			holderSprite2.y = (baseBg.y + baseBg.height) - holderSprite2.height;
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
		}
		
		public function buildChartAnim():void
		{
			 
			var startDelay1:Number = 0;
			var startDelay2:Number = 0;
			
			for (var i:int = graphPieces1.length - 1; i > - 1; i--)
			{
				graphPieces1[i].startAnimation(transTime, startDelay1);
				startDelay1 += transTime;
			}
			
			for (var j:int = graphPieces2.length - 1; j > - 1; j--)
			{
				graphPieces2[j].startAnimation(transTime, startDelay2);
				startDelay2 += transTime;
			}
			
			for (var k:int = 0; k < legendItems.length; k++)
			{	
				legendItems[k].startAnimation(transTime, 0);
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
			// cleanup if tip is present:
			if(rolloverTip != null)
			{
				myRoot.removeChild(rolloverTip);
				rolloverTip = null;
			}
			
			// create new tip:
			var dollarsTotal:int;
			var holderSprite:Sprite;
			var graphPiece:GraphPiece;
			var legendItem:LegendItem = legendItems[event.target.myId];
			var itemPercent:Number;
			
			switch (event.target.parent as Sprite)
			{
				case holderSprite1:
					dollarsTotal = dollarsTotal1;
					holderSprite = holderSprite1;
					graphPiece = graphPieces1[event.target.myId];
					itemPercent = graphPieces1[event.target.myId].itemPercent;
				break;
				case holderSprite2:
					dollarsTotal = dollarsTotal2;
					holderSprite = holderSprite2;
					graphPiece = graphPieces2[event.target.myId];
					itemPercent = graphPieces2[event.target.myId].itemPercent;
				break;
			}
			
			rolloverTip = new RolloverTip(graphPiece.myData, graphPiece.myId, legendTextSize, legendTextColor, dollarsTotal, itemPercent, graphPiece.myData.myColor, legendLocation);
			rolloverTip.doSetup();
			
			// position tip & do rollover animation:
			var tipPoint:Point = new Point(holderSprite.x + holderSprite.width, holderSprite.y + (graphPiece.y + (graphPiece.height)/2) - rolloverTip.height/2);
			var tipPointGlobal:Point = localToGlobal(tipPoint);
			var myRootTipPoint:Point = myRoot.globalToContent(tipPointGlobal);
			rolloverTip.x = myRootTipPoint.x + 30;
			rolloverTip.y = myRootTipPoint.y;
			
			myRoot.addChild(rolloverTip);
			
			rolloverTip.animateIn(transTime, tipPointGlobal.x);
			legendItem.rolloverAnim(transTime);
			graphPiece.rolloverAnim(transTime);
		}
		
		private function rollOutHandler(event:MouseEvent):void
		{
			var holderSprite:Sprite;
			var graphPiece:GraphPiece;
			var legendItem:LegendItem = legendItems[event.target.myId];
			
			switch (event.target.parent as Sprite)
			{
				case holderSprite1:
					holderSprite = holderSprite1;
					graphPiece = graphPieces1[event.target.myId];
				break;
				case holderSprite2:
					holderSprite = holderSprite2;
					graphPiece = graphPieces2[event.target.myId];
				break;
			}
			
			if(rolloverTip != null)
			{
				myRoot.removeChild(rolloverTip);
				rolloverTip = null;
			}
			
			legendItem.rolloutAnim(transTime);
			graphPiece.rolloutAnim(transTime);
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			// always pass the graph piece, which contains data, and positioning props:
			var graphPiece:GraphPiece;
			
			switch (event.target.parent as Sprite)
			{
				case holderSprite1:
					graphPiece = graphPieces1[event.target.myId];
				break;
				case holderSprite2:
					graphPiece = graphPieces2[event.target.myId];
				break;
			}
			
			var evt:ChartClickEvent = new ChartClickEvent(ChartClickEvent.CHART_CLICK_EVENT, graphPiece);
			dispatchEvent(evt);
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		// cleanup:
		
		public function cleanup():void
		{
			var data1:Array = myData.chart1.chartVals; 	
			var data2:Array = myData.chart2.chartVals; 	
			
			clearTimeout(timeOut);
			
			// remove listeners:
			if(dollarsTotal1 > 0)
			{
				for (var i:int = 0; i < data1.length; i++)
				{	
					var graphPiece1:GraphPiece = graphPieces1[i];
					graphPiece1.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					graphPiece1.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
					graphPiece1.removeEventListener(MouseEvent.CLICK, clickHandler);
				}
			}
			
			if(dollarsTotal2 > 0)
			{
				for (var j:int = 0; j < data2.length; j++)
				{	
					var graphPiece2:GraphPiece = graphPieces2[j];
					graphPiece2.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					graphPiece2.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
					graphPiece2.removeEventListener(MouseEvent.CLICK, clickHandler);
				}
			}
			
			// reset arrays:
			graphPieces1 = null;
			graphPieces2 = null;
			legendItems = null;
			
			// remove children:
			removeChild(titlePanel); 
			titlePanel = null;
			
			removeChild(baseBg);
			baseBg = null;
			
			removeChild(legendSprite);
			legendSprite = null;
			
			removeChild(holderSprite1);
			holderSprite1 = null;
			
			removeChild(holderSprite2);
			holderSprite2 = null;
			
			removeChild(blockerSprite);
			blockerSprite = null;
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		
	}
}
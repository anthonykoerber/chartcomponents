package com.charts.serieschart
{
	import com.charts.serieschart.ui.AxisLabel;
	import com.charts.serieschart.ui.SeriesGraphPiece;
	
	import flash.display.Sprite;
	
	import mx.core.UIComponent;

	public class SeriesChartComponent extends UIComponent
	{
		// creation vars:
		public var myRoot:Object;
		public var myData:Object;
		public var chartWidth:int;
		public var chartHeight:int;
		public var barColor1:uint;
		public var barColor2:uint;
		public var animTime:Number;
		public var delayTime:Number;
		
		// construct labels vars:
		public var numLabelsX:int;
		public var numLabelsY:int;
		public var startValX:Number;
		public var endValX:Number;
		public var startValY:Number;
		public var endValY:Number;
		public var xPadding:int = 5;
		public var yPadding:int = 5;
		
		// render labels vars:
		private var xAxisHolder:Sprite;
		private var xAxisLabels:Array;
		private var xAxisHeight:int;
		private var xAxisWidth:int;
		private var yAxisHolder:Sprite;
		private var yAxisLabels:Array;
		private var yAxisHeight:int;
		private var yAxisWidth:int;
		
		// construct chart vars:
		private var chartItems:Array;
		private var itemWidth:int;
		private var itemsHolder:Sprite;
		private var numItems:int;
		private var labelHeight:int;
		private var startYPos:Number;
		
		public function SeriesChartComponent(){}
		
		public function setupGraph():void
		{
			if(!myData) return;
	
			// MUST get label height before beginning layout calculations:
			var tmpLabel:AxisLabel = new AxisLabel(0, AxisLabel.AXIS_X, xPadding);
			tmpLabel.doSetup();
			labelHeight = tmpLabel.height;
			tmpLabel = null;
			
			// set MASTER layout vars:
			numItems = myData.chart.chartVals.length;
			startYPos = Math.round(labelHeight/2);
			xAxisHeight = Math.floor(labelHeight + xPadding);
			yAxisHeight = Math.floor(chartHeight - xAxisHeight - startYPos);
			
			// construct y axis values and store:
			yAxisLabels = new Array();
			var rangeY:Number = endValY - startValY;
			var incrY:Number = rangeY/(numLabelsY-1);
			
			for(var i:int = 0; i < numLabelsY; i++){
				var obj:Object = new Object();
				var pxDist:Number = Math.ceil( yAxisHeight * (i/(numLabelsY-1)) );
				var value:Number = incrY*i;
				obj.pxDist = pxDist;
				obj.value = value;
				yAxisLabels.push(obj);
			}
			
			// construct x axis values and store:
			xAxisLabels = new Array();
			var incrX:Number = Math.floor((endValX - startValX)/numLabelsX);
			var tmpStartValX:Number = startValX;
			
			xAxisLabels.push(startValX);
			for(var j:int = 0; j < numLabelsX-2; j++){
				tmpStartValX += incrX;
				xAxisLabels.push(tmpStartValX);
			}
			xAxisLabels.push(endValX);
			
			// call layout once calculations are complete:
			layoutGraph();
		}
		
		// -- -- -- -- -- -- -- -- -- -- --
		// do actual layout:
		private function layoutGraph():void
		{ 
			// create y axis:
			yAxisHolder = new Sprite();
			yAxisHolder.x = 0;
			yAxisHolder.y = startYPos;
			addChild(yAxisHolder);
			
			var longestYLabel:Number = 0;
			var tmpYAxisArray:Array = new Array();
			
			for(var i:int = 0; i < yAxisLabels.length; i++){
				var labelY:AxisLabel = new AxisLabel(yAxisLabels[i].value, AxisLabel.AXIS_Y, xPadding, 10, 0x333333, true);
				labelY.doSetup();
				longestYLabel = (labelY.width > longestYLabel) ? Math.floor(labelY.width) : longestYLabel;
				tmpYAxisArray.push(labelY);
			}
			
			yAxisWidth = longestYLabel;
			for(var j:int = 0; j < yAxisLabels.length; j++){
				var labelY:AxisLabel = tmpYAxisArray[j];
				labelY.x = Math.ceil(longestYLabel - labelY.width);
				labelY.y = yAxisHeight - yAxisLabels[j].pxDist;
				yAxisHolder.addChild(labelY);
			}
			
			yAxisHolder.graphics.beginFill(0x666666);
			yAxisHolder.graphics.drawRect(yAxisWidth, 0, 1, yAxisHeight);
			yAxisHolder.graphics.endFill();
			
			// create y axis:
			xAxisHolder = new Sprite();
			xAxisHolder.x = (longestYLabel);
			xAxisHolder.y = Math.round(labelHeight/2) + yAxisHeight;
			addChild(xAxisHolder);
			
			var startX:Number = 0;
			var longestXLabel:Number = 0;
			var tmpXAxisArray:Array = new Array();
			
			for(var k:int = 0; k < xAxisLabels.length; k++){
				var labelX:AxisLabel = new AxisLabel(xAxisLabels[k], AxisLabel.AXIS_X, yPadding, 10, 0x333333);
				labelX.doSetup();
				longestXLabel = (labelX.width > longestYLabel) ? Math.floor(labelX.width) : longestYLabel;
				tmpXAxisArray.push(labelX);
			}
			
			xAxisWidth = Math.floor( chartWidth - (yAxisHolder.width + (longestXLabel/2)) );
			for(var l:int = 0; l < xAxisLabels.length; l++){
				var labelX:AxisLabel = tmpXAxisArray[l];
				labelX.x = startX;
				startX += Math.floor( xAxisWidth/(numLabelsX-1) );
				xAxisHolder.addChild(labelX);
			}
			
			xAxisHolder.graphics.beginFill(0x666666);
			xAxisHolder.graphics.drawRect(0, 0, xAxisWidth, 1);
			xAxisHolder.graphics.endFill();
			
			// create chart area:
			itemsHolder = new Sprite();
			itemsHolder.x = yAxisWidth + 1;
			itemsHolder.y = startYPos;
			addChild(itemsHolder);
			
			itemsHolder.graphics.beginFill(0xffffff, 0.5);
			itemsHolder.graphics.drawRect(0, 0, xAxisWidth-1, yAxisHeight-1);
			itemsHolder.graphics.endFill();
			
			// create chart items:
			var data:Array = myData.chart.chartVals;
			var itemWidth:Number = Math.floor((xAxisWidth/numItems)-1);
			var yTotalHeight:Number = yAxisHeight - 1;
			var itemStartX:Number = 1;
			var largestVal:Number = data[data.length - 1].dollars; // assumes the last item in the array is the largest value
			
			for (var m:int = 0; m < data.length; m++){
				var itemHeight:Number = Math.round( yTotalHeight * (data[m].dollars/largestVal) );
				var chartItem:SeriesGraphPiece = new SeriesGraphPiece(m, data[m], itemWidth, itemHeight, yTotalHeight, barColor1, barColor2, true, animTime, delayTime*m);
				chartItem.doSetup();
				chartItem.x = itemStartX;
				itemStartX += (itemWidth + 1);
				itemsHolder.addChild(chartItem);
			}
		}
	}
}
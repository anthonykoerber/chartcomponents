package com.charts.comparechart
{
	import com.charts.comparechart.ui.CompareGraphPiece;
	import mx.core.UIComponent;

	public class CompareChartComponent extends UIComponent
	{
		// creation vars:
		public var myRoot:Object;
		public var myData:Object;
		public var chartWidth:int;
		public var chartHeight:int;
		public var bar1Color1:uint;
		public var bar1Color2:uint;
		public var bar2Color1:uint;
		public var bar2Color2:uint;
		public var animTime:Number;
		public var delayTime:Number;
		private var largestNumber:Number;
		private var higherVal:Number;
		
		public function CompareChartComponent(){}
		
		public function setupGraph():void
		{
			if(!myData) return;
			
			// create ratio based on largest number:
			largestNumber = myData.largestNumber;
			
			if ( myData.assets > myData.needs ){
				higherVal = myData.assets;
			} else {
				higherVal = myData.needs;
			}
			
			// call layout once calculations are complete:
			layoutGraph();
		}
		
		// -- -- -- -- -- -- -- -- -- -- --
		// do actual layout:
		private function layoutGraph():void{ 
			
			var itemWidth:Number = Math.floor( (chartWidth/2) - 3 );
			
			// draw needs:
			var needsItemHeight:Number = chartHeight * ( myData.needs / largestNumber );
			var needsPiece:CompareGraphPiece = new CompareGraphPiece(0, myData.needs, itemWidth, needsItemHeight, bar1Color1, bar1Color2, chartHeight, 0xffffff, 20, true, animTime, delayTime);
			needsPiece.doSetup();
			needsPiece.x = 0;
			needsPiece.y = 0;
			addChild(needsPiece);
			addChild(needsPiece);
			
			// draw assets:
			var assetsItemHeight:Number = chartHeight * ( myData.assets / largestNumber );
			var assetsPiece:CompareGraphPiece = new CompareGraphPiece(1, myData.assets, itemWidth, assetsItemHeight, bar2Color1, bar2Color2, chartHeight, 0xffffff, 20, true, animTime, delayTime*2);
			assetsPiece.doSetup();
			assetsPiece.x = itemWidth + 3;
			assetsPiece.y = 0;
			addChild(assetsPiece);
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		
	}
}
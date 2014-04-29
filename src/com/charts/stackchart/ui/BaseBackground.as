package com.charts.stackchart.ui
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;

	public class BaseBackground extends Sprite
	{
		private var chartWidth:int;
		private var chartHeight:int;
		private var pieceDepth:int;
		private var themeColor:uint;
		private var useBgGfx:Boolean;
		private var legendLocation:String;
		
		private var dividerLines:Array;
		private var numLines:int;
		private var lineHeight:int;
		
		public function BaseBackground(_chartHeight:int, _chartWidth:int, _pieceDepth:int, _themeColor:uint, _useBgGfx:Boolean, _legendLocation:String)
		{
			// set vars:
			chartHeight = 	 _chartHeight;
			chartWidth = 	 _chartWidth;
			pieceDepth = 	 _pieceDepth;
			themeColor =     _themeColor;
			useBgGfx = 		 _useBgGfx;
			legendLocation = _legendLocation;
			
			// add event listeners:
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		public function doSetup(/* event:Event */):void
		{
			graphics.clear();
			
			if (useBgGfx) 
			{
				// draw base bg:
				var ratios:Array = [0, 255];
			 	var colors:Array = [themeColor, themeColor];
	            var alphas:Array = [0, 0.3];
				var bgMatrix:Matrix = new Matrix();
				var direction:Number;
				var dividerRot:Boolean;
				var dividerLine:DividerLineAsset;
				
				switch(legendLocation.toLowerCase())
				{
					case "left":
						direction = 45/(180/Math.PI);
						dividerRot = false;
					break;
					case "right":
						direction = 135/(180/Math.PI);
						dividerRot = true;
					break;
					default:
						direction = 45/(180/Math.PI);
						dividerRot = false;
				}
				
	            bgMatrix.createGradientBox((chartWidth - pieceDepth), (chartHeight - pieceDepth * 2), direction, 0, 0);
	            graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, bgMatrix);
				graphics.drawRect(pieceDepth, 0, (chartWidth - pieceDepth), (chartHeight - pieceDepth * 2));
				graphics.endFill();
				
				// draw base:
				graphics.beginFill(themeColor, 0.5);
				graphics.moveTo(0, (chartHeight - pieceDepth));
				graphics.lineTo(pieceDepth, (chartHeight - pieceDepth * 2));
				graphics.lineTo(chartWidth, (chartHeight - pieceDepth * 2));
				graphics.lineTo(chartWidth, (chartHeight - pieceDepth));
				graphics.lineTo((chartWidth - pieceDepth), chartHeight);
				graphics.lineTo(0, chartHeight);
				graphics.lineTo(0, (chartHeight - pieceDepth));
				graphics.endFill();
				
				// draw base top (cap):
				graphics.beginFill(0xFFFFFF, 0.9);
				graphics.moveTo(pieceDepth, (chartHeight - pieceDepth * 2));
				graphics.lineTo(chartWidth, (chartHeight - pieceDepth * 2));
				graphics.lineTo((chartWidth - pieceDepth), (chartHeight - pieceDepth));
				graphics.lineTo(0, (chartHeight - pieceDepth));
				graphics.endFill();
				
				// draw base front (cap):
				graphics.beginFill(0xFFFFFF, 0.6);
				graphics.drawRect(0, (chartHeight - pieceDepth), (chartWidth - pieceDepth), pieceDepth);
				graphics.endFill();
				
				// add base divider lines:
				dividerLines = new Array();
				numLines = Math.round(((chartHeight - (pieceDepth * 2)) / pieceDepth) / 2);
				lineHeight = Math.round((chartHeight - (pieceDepth * 2))/numLines);
				
				for (var k:int = 0; k < numLines; k++)
				{
					dividerLine = new DividerLineAsset();
					dividerLine.y = lineHeight * k;
					dividerLine.width = chartWidth - pieceDepth;
					
					if (dividerRot) 
					{
						dividerLine.scaleX *= -1;
						dividerLine.x = dividerLine.width + pieceDepth;
					}
					else
					{
						dividerLine.x = pieceDepth;
					}
	
					addChild(dividerLine);
					dividerLines.push(dividerLine);
				}
			}
			else
			{
				// draw blank base:
				graphics.beginFill(0xFF0000, 0);
				graphics.drawRect(0, 0, chartWidth, chartHeight);
				graphics.endFill();
			}
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
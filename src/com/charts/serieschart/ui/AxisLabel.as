package com.charts.serieschart.ui
{
	import com.charts.utils.Formatter;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class AxisLabel extends Sprite
	{
		public static const AXIS_Y:String = "axisY";
		public static const AXIS_X:String = "axisX";
		
		private var myValue:int;	
		private var myAxis:String;	
		private var myTextSize:int;
		private var myTextColor:uint;
		private var useDollarValue:Boolean;
		private var myTextField:TextField; 
		private var myformat:TextFormat;
		private var format:Formatter = new Formatter();
		private var tick:Sprite;
		private var myPadding:Number;
		
		public function AxisLabel(_myValue:int, _myAxis:String, _myPadding:int = 5, _myTextSize:int = 8, _myTextColor:uint = 0x000000, _useDollarValue:Boolean = false)
		{
			// set vars:
			myValue = 	     _myValue;
			myAxis = 		 _myAxis;
			myTextSize =  	 _myTextSize;
			myTextColor = 	 _myTextColor;
			useDollarValue = _useDollarValue;
			myPadding =      _myPadding;
			
			// add event listeners:
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		public function doSetup():void
		{
			myTextField = new TextField();  
			addChild(myTextField);
			
			// add the text:
			myformat = new TextFormat();
			myformat.font = "ArialEmbed";
			myformat.color = myTextColor;
			myformat.size = myTextSize;
			myformat.letterSpacing = 0.3;
			
			myTextField.antiAliasType = AntiAliasType.ADVANCED;
			myTextField.gridFitType = GridFitType.PIXEL;
			
			myTextField.multiline = false;
			myTextField.embedFonts = true;
			myTextField.selectable = false;
			myTextField.defaultTextFormat = myformat;
			
			// do graphical setup and draw ticks:
			tick = new Sprite();
			addChild(tick);
			
			if(myAxis == AXIS_X){
				myTextField.autoSize = TextFieldAutoSize.CENTER;
				
				// populate label:
				if (useDollarValue){
					myTextField.htmlText = format.currency(myValue, 0);
				} else {
					myTextField.htmlText = String(myValue);
				}
				
				myTextField.x = 0 - myTextField.width/2;
				myTextField.y = myPadding;
				
				// draw tick right:
				tick.x = 0;
				tick.y = 0;
				
				tick.graphics.beginFill(myTextColor, 0.3);
				tick.graphics.drawRect(0, 0, 1, myPadding);
				tick.graphics.endFill();
			} else {
				myTextField.autoSize = TextFieldAutoSize.RIGHT; 
				
				// populate label:
				if (useDollarValue){
					myTextField.htmlText = format.currency(myValue, 0);
				} else {
					myTextField.htmlText = String(myValue);
				}
				
				myTextField.x = 0;
				myTextField.y = 0 - myTextField.height/2;
				
				// draw tick right:
				tick.x = myTextField.width + 1;
				tick.y = 0;
				
				tick.graphics.beginFill(myTextColor, 0.3);
				tick.graphics.drawRect(0, 0, myPadding, 1);
				tick.graphics.endFill();
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
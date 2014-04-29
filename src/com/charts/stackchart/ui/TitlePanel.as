package com.charts.stackchart.ui
{
	import com.charts.utils.Formatter;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TitlePanel extends Sprite
	{
		public var myData:Object;	
		private var myTitle:String;
		private var myTextSize:int;
		private var myTitleTextColor:uint;
		private var myDollarTextColor:String;
		private var chartWidth:int;
		private var pieceDepth:int;
		private var useTitlePanel:Boolean;
		private var myFont:Font;
		private var myFontBold:Font;
		private var myTextField:TextField; 
		private var myformat:TextFormat;
		private var format:Formatter = new Formatter();;
		
		public function TitlePanel(_myData:Object, _myTitle:String, _myTextSize:int, _myTitleTextColor:uint, _chartWidth:int, _pieceDepth:int, _useTitlePanel:Boolean)
		{
			// set vars:
			myData = 			_myData;
			myTitle = 			_myTitle;
			myTextSize = 		_myTextSize;
			myTitleTextColor =  _myTitleTextColor;
			chartWidth = 		_chartWidth;
			pieceDepth = 		_pieceDepth;
			useTitlePanel = 	_useTitlePanel;
			
			// add event listeners:
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);	
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		
		public function doSetup(/* event:Event */):void
		{
			if (useTitlePanel){
	
				// add the text:
				myformat = new TextFormat();
				myformat.font = "ArialEmbed"; // can use CSS font in Flex
				myformat.color = myTitleTextColor;
				myformat.size = myTextSize;
				myformat.leading = 4;
				myformat.letterSpacing = 0.5;
				
				myTextField = new TextField();  
				myTextField.x = pieceDepth;
				myTextField.autoSize = TextFieldAutoSize.LEFT; 
				myTextField.antiAliasType = AntiAliasType.ADVANCED;
				myTextField.gridFitType = GridFitType.SUBPIXEL;
				
				myTextField.multiline = true;
				myTextField.wordWrap = true;
				myTextField.embedFonts = true;
				myTextField.selectable = false;
				myTextField.defaultTextFormat = myformat;
				
				myTextField.width = chartWidth - (pieceDepth * 2);
				myTextField.htmlText = myTitle;
				
				addChild(myTextField);
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
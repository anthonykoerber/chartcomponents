package com.charts.stackchart.ui
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.charts.utils.Formatter;
	
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	public class RolloverTip extends UIComponent
	{
		public var myId:int;
		public var myData:Object;
		public var myPercent:Number;
		
		private var myTextSize:int;
		private var myTextColor:uint;
		private var dollarsTotal:int;
		private var themeColor:uint;
		private var legendLocation:String;
		private var myBg:Sprite;
		private var myBgShape:Shape;
		private var myFont:Font;
		private var myFontBold:Font;
		private var myTextField:TextField; 
		private var myformat:TextFormat;
		private var format:Formatter = new Formatter();
		private var myDrop:DropShadowFilter = new DropShadowFilter(0, 0, 0x000000, 0.25, 10, 10, 1, 3);
		private var itemPercent:Number;
		
		public function RolloverTip(_myData:Object, 
									_myId:int, 
									_myTextSize:int, 
									_myTextColor:uint, 
									_dollarsTotal:int, 
									_itemPercent:Number, 
									_themeColor:uint, 
									_legendLocation:String)
		{
			// set vars:
			myData =         _myData;
			myId = 		     _myId;
			myTextSize =     _myTextSize;
			myTextColor =    _myTextColor;
			dollarsTotal =   _dollarsTotal;
			themeColor =     _themeColor;
			legendLocation = _legendLocation;
			itemPercent = 	_itemPercent;
			
			// set props:
			alpha = 0;
			filters = [myDrop];
			mouseChildren = false;
			buttonMode = useHandCursor = true;
			
			// add bg holder (for lowest z depth):
			myBg = new Sprite();
			addChild(myBg);
			
			// add event listeners:
			// addEventListener(Event.ADDED_TO_STAGE, doSetup);
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		public function doSetup(/* event:Event */):void
		{
			myformat = new TextFormat();
			myformat.font = "ArialEmbed"; // can use CSS font in Flex
			myformat.color = myTextColor;
			myformat.size = myTextSize;
			myformat.letterSpacing = 0.5;
			
			myTextField = new TextField();  
			myTextField.autoSize = TextFieldAutoSize.LEFT; 
			myTextField.antiAliasType = AntiAliasType.ADVANCED;
			myTextField.gridFitType = GridFitType.SUBPIXEL;
			
			myTextField.multiline = true;
			myTextField.embedFonts = true;
			myTextField.selectable = false;
			myTextField.defaultTextFormat = myformat;
			
			if(myData.useAltLabel == false)
			{
				myTextField.htmlText = myData.legendLabel + "<br/><b>" + format.percent(itemPercent) + "</b>" + " or " + "<b>" + format.currency(myData.myDollars, 0) + "</b>";			
			}
			else
			{
				myTextField.htmlText = "<b>" + myData.altLabel + "</b>";
			}
			addChild(myTextField);
            
            myBgShape = new Shape();
            myBgShape.x = 0;
            myBgShape.y = 0;
            myBg.addChild(myBgShape);
            
			myBgShape.graphics.lineStyle(2, 0xFFFFFF, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE , JointStyle.MITER, 2);  
			myBgShape.graphics.beginFill(themeColor, 1);
			myBgShape.graphics.moveTo(0, (myTextField.height + 16)/2);
			myBgShape.graphics.lineTo(8, ((myTextField.height + 16)/2) - 6); 
			myBgShape.graphics.lineTo(8, 0);
			myBgShape.graphics.lineTo((myTextField.width + 24), 0);
			myBgShape.graphics.lineTo((myTextField.width + 24), (myTextField.height + 16));
			myBgShape.graphics.lineTo(8, (myTextField.height + 16));
			myBgShape.graphics.lineTo(8, ((myTextField.height + 16)/2) + 6); 
			myBgShape.graphics.lineTo(0, ((myTextField.height + 16)/2)); 
			myBgShape.graphics.endFill();
			
			// position bg elements & label:
			switch (legendLocation.toLocaleLowerCase())
			{
				case "left":
					myTextField.x = 16;
				break;
				case "right":
					/*
					myBg.scaleX *= -1; 
					myTextField.x = 8;
					myBg.x = myBg.width;
					*/
					myTextField.x = 16;
				break;
				default:
					myTextField.x = 16;
			}
			 
			myTextField.y = Math.round((myBg.height - myTextField.height)/2);
			
			// notify FLEX framework about height & width - so these can be bindable:
			measure();
		}
		
		override protected function measure():void
		{
			super.measure();
			
			width = myBg.width;
			height = myBg.height;
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		// animate:
		
		public function animateIn(timeNum:Number, targetX:Number):void
		{
			TweenMax.to(this, timeNum/2, {x:targetX, alpha:1, ease:Sine.easeOut});
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --
		// cleanup:
		
		private function cleanup(event:Event):void
		{
			// removeEventListener(Event.ADDED_TO_STAGE, doSetup);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- -- --

	}
}
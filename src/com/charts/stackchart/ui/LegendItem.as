package com.charts.stackchart.ui
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.charts.utils.Formatter;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class LegendItem extends Sprite
	{
		public var myId:int;
		public var myData:Object;	
		
		private var myTextSize:int;
		private var myBoxSize:int;
		private var myTextColor:uint;
		private var useDollarValue:Boolean;
		private var useAnimation:Boolean;
		private var myFont:Font;
		private var myFontBold:Font;
		private var myTextField:TextField; 
		private var myformat:TextFormat;
		private var format:Formatter = new Formatter();
		
		public function LegendItem(_myData:Object, _myId:int, _myTextSize:int, _myBoxSize:int, _myTextColor:uint, _useDollarValue:Boolean, _useAnimation:Boolean)
		{
			// set vars:
			myData = 	     _myData;
			myId = 		 	 _myId;
			myTextSize =  	 _myTextSize;
			myTextColor = 	 _myTextColor;
			myBoxSize =      _myBoxSize;
			useDollarValue = _useDollarValue;
			useAnimation =   _useAnimation;
			
			// add event listeners:
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		public function doSetup(/* event:Event */):void
		{
			// make the color rectangele:
			graphics.beginFill(myData.myColor, 1);
			graphics.drawRect(0, 0, myBoxSize, myBoxSize);
			graphics.endFill();
			
			myTextField = new TextField();  
			addChild(myTextField);
			
			// add the text:
			// myFont = new LegendFont();
			// myFontBold = new LegendFontBold();
			myformat = new TextFormat();
			// myformat.font =  myFont.fontName;
			myformat.font = "ArialEmbed"; // can use CSS font in Flex
			myformat.color = myTextColor;
			myformat.size = myTextSize;
			myformat.letterSpacing = 0.5;
			
			myTextField.autoSize = TextFieldAutoSize.LEFT; 
			myTextField.antiAliasType = AntiAliasType.ADVANCED;
			myTextField.gridFitType = GridFitType.SUBPIXEL;
			
			myTextField.multiline = true;
			myTextField.embedFonts = true;
			myTextField.selectable = false;
			myTextField.defaultTextFormat = myformat;
			myTextField.x = myBoxSize + 5;
			
			myTextField.htmlText = " ";					// add a single blank space, to record the height of the textField at a single line
			var lineHeight:Number = myTextField.height; // store the height of a single line
			
			// populate label:
			if (useDollarValue)
			{
				myTextField.htmlText = myData.legendLabel + "<br/><b>" + format.currency(myData.myDollars, 0) + "</b>";
			}
			else
			{
				myTextField.htmlText = myData.legendLabel;
			}
			
			// position y based off the stored line height:
			if (lineHeight > myBoxSize)
			{
				myTextField.y = Math.round(0 - ((lineHeight - myBoxSize)/2));
			}
			else
			{
				myTextField.y = Math.round((myBoxSize - lineHeight)/2);
			}
			
			// make hot spot:
			var hitSprite:Sprite = new Sprite();
			hitSprite.graphics.beginFill(0xFF0000, 0);
			hitSprite.graphics.drawRect(0, 0, width, height);
			hitSprite.graphics.endFill();
			addChild(hitSprite);
			
			// show immediately, or wait for animation cue:
			if (useAnimation)
			{
				alpha = 0;
			}
		}

		// -- -- -- -- -- -- -- -- -- -- 
		// do animation:
		
		public function startAnimation(timeNum:Number, delayNum:Number):void
		{
			TweenMax.to(this, timeNum, {alpha:1, ease:Sine.easeOut, delay:delayNum});
		}
		
		public function rolloverAnim(timeNum:Number):void
		{
			// TweenMax.to(this, timeNum/2, {x:-5,  /* colorTransform:{tint:myData.myColor, tintAmount:0.5}, */  ease:Sine.easeOut});
			// TweenMax.to(myTextField, timeNum/2, {x:(myBoxSize + 500), ease:Sine.easeOut});
		}
		
		public function rolloutAnim(timeNum:Number):void
		{
			// TweenMax.to(this, timeNum/2, {x:0,  /* colorTransform:{tint:myData.myColor, tintAmount:0}, */  ease:Sine.easeIn});
			// TweenMax.to(myTextField, timeNum/2, {x:(myBoxSize + 5), ease:Sine.easeIn});
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
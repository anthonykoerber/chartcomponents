package com.charts.comparechart.ui
{
    import com.charts.utils.Formatter;
    import com.greensock.TweenLite;
    import com.greensock.easing.Sine;
    
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.text.AntiAliasType;
    import flash.text.GridFitType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import flashx.textLayout.formats.TextAlign;
	
    public class CompareGraphPiece extends Sprite
    {
    	public var myId:int;
		public var myValue:int;
		
		private var myWidth:int;
		private var myHeight:int;
		private var totalHeight:int;
		private var bar:Sprite;
		private var myTextField:TextField; 
		private var myformat:TextFormat; 
		private var myColor1:uint;
		private var myColor2:uint;
		private var timeNum:Number;
		private var delay:Number;
		private var useAnimation:Boolean = false;
		private var textColor:uint;
		private var textSize:Number; 
		private var formatter:Formatter = new Formatter();
		
		public function CompareGraphPiece(_myId:int, 
										  _myValue:Number, 
										  _myWidth:int, 
										  _myHeight:int, 
										  _myColor1:uint, 
										  _myColor2:uint, 
										  _totalHeight:int,  
										  _textColor:uint, 
										  _textSize:Number, 
										  _useAnimation:Boolean = false, 
										  _timeNum:Number = 0.5, 
										  _delay:Number = 0)
		{
			// set vars:
			myValue =       _myValue;
			myId =          _myId
			myWidth =       _myWidth;
			myHeight =      _myHeight;
			totalHeight =   _totalHeight;
			myColor1 =      _myColor1;
			myColor2 =      _myColor2;
			useAnimation =  _useAnimation;
			timeNum = 		_timeNum;
			delay =         _delay;
			textColor =     _textColor;
			textSize =      _textSize;
			
			// set props:
			mouseChildren = false;
			buttonMode = useHandCursor = true;
			
			// add event listeners:
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		public function doSetup():void
		{
			bar = new Sprite();
			bar.y = totalHeight;
			addChild(bar);
			
			// tmp:
			graphics.beginFill(0xffffff, 0.5);
			graphics.drawRect(0, 0, myWidth, totalHeight);
			graphics.endFill();
			
			// create gradient fills:
			var gradientBoxMatrix:Matrix = new Matrix(); 
			gradientBoxMatrix.createGradientBox(myWidth, 0-myHeight, Math.PI/2, 0, 0); 
			bar.graphics.beginGradientFill(GradientType.LINEAR, [myColor1, myColor2], [1, 1], [0, 255], gradientBoxMatrix); 
			bar.graphics.drawRect(0, 0-myHeight, myWidth, myHeight);
			bar.graphics.endFill();
			
			// add text label:
			myTextField = new TextField();  
			addChild(myTextField);
			
			// add the text:
			myformat = new TextFormat();
			myformat.font = "ArialEmbed";
			myformat.color = textColor;
			myformat.size = textSize;
			myformat.letterSpacing = 0.3;
			myformat.align = TextAlign.CENTER;
			myformat.bold = true;
			
			myTextField.antiAliasType = AntiAliasType.ADVANCED;
			myTextField.gridFitType = GridFitType.PIXEL;
			myTextField.autoSize = TextFieldAutoSize.CENTER;
			
			myTextField.multiline = false;
			myTextField.embedFonts = true;
			myTextField.selectable = false;
			myTextField.defaultTextFormat = myformat;
			/*
			var drop:DropShadowFilter = new DropShadowFilter(0, 0, 0x000000, 1, 6, 6, 0.5, 3);
			myTextField.filters = [drop];
			*/
			myTextField.text = formatter.currency(myValue, 0, '$');
			myTextField.x = Math.round((bar.width - myTextField.width)/2);
			
			if(bar.height > myTextField.height){
				// position the label in the center of the bar:
				myTextField.y = totalHeight - Math.round((bar.height + myTextField.height)/2);
			} else {
				// position the abpve the bottom threshold:
				myTextField.y = (totalHeight - bar.height) - (5 + myTextField.height);
				
				// tint it a different color:
				var colorTransform:ColorTransform = myTextField.transform.colorTransform;
				colorTransform.color = 0x333333;
				myTextField.transform.colorTransform = colorTransform;
			}
			
			// draw immediately, or wait for animation cue:
			if (useAnimation){
				bar.scaleY = 0;
				myTextField.alpha = 0;
				startAnimation(timeNum, delay);
			}
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- 
		// do animation:
		public function startAnimation(timeNum:Number, delayNum:Number):void
		{
			TweenLite.to(bar, timeNum, {scaleY:1.0, delay:delayNum, ease:Sine.easeOut});
			TweenLite.to(myTextField, timeNum, {alpha:1.0, delay:delayNum + timeNum, ease:Sine.easeOut});
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

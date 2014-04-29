package com.charts.serieschart.ui
{
    import com.greensock.TweenLite;
    import com.greensock.easing.Sine;
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
	
    public class SeriesGraphPiece extends Sprite
    {
    	public var myId:int;
		public var myValue:int;
		
		private var myWidth:int;
		private var myHeight:int;
		private var totalHeight:int;
		private var bar:Sprite;
		private var myColor1:uint;
		private var myColor2:uint;
		private var timeNum:Number;
		private var delay:Number;
		private var useAnimation:Boolean = false;
		
		public function SeriesGraphPiece(_myId:int, 
										 _myValue:Number, 
										 _myWidth:int, 
										 _myHeight:int, 
										 _totalHeight:int,
										 _myColor1:uint, 
										 _myColor2:uint, 
										 _useAnimation:Boolean = false, 
										 _timeNum:Number = 0.5, 
										 _delay:Number = 0)
		{
			// set vars:
			myValue =      _myValue;
			myId =         _myId
			myWidth =      _myWidth;
			myHeight =     _myHeight;
			totalHeight =  _totalHeight;
			myColor1 =     _myColor1;
			myColor2 =     _myColor2;
			useAnimation = _useAnimation;
			timeNum =      _timeNum;
			delay =        _delay;
			
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
			graphics.beginFill(0xff0000, 0);
			graphics.drawRect(0, 0, myWidth, totalHeight);
			graphics.endFill();
			
			// create gradient fills:
			var gradientBoxMatrix:Matrix = new Matrix(); 
			gradientBoxMatrix.createGradientBox(myWidth, 0-myHeight, Math.PI/2, 0, 0); 
			bar.graphics.beginGradientFill(GradientType.LINEAR, [myColor1, myColor2], [1, 1], [0, 255], gradientBoxMatrix); 
			bar.graphics.drawRect(0, 0-myHeight, myWidth, myHeight);
			bar.graphics.endFill();
			
			// draw immediately, or wait for animation cue:
			if (useAnimation){
				bar.scaleY = 0;
				startAnimation(timeNum, delay);
			}
		}
		
		// -- -- -- -- -- -- -- -- -- -- -- 
		// do animation:
		public function startAnimation(timeNum:Number, delayNum:Number):void
		{
			TweenLite.to(bar, timeNum, {scaleY:1.0, delay:delayNum, ease:Sine.easeOut});
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

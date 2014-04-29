package com.charts.events
{
	import com.charts.stackchart.ui.GraphPiece;
	
	import flash.events.Event;

	public class ChartClickEvent extends Event
	{
		public static const CHART_CLICK_EVENT:String = "chartClickEvent";
		
		public var graphPiece:GraphPiece;
		
		public function ChartClickEvent(type:String, _graphPiece:GraphPiece, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			graphPiece = _graphPiece;
		}
		
		public override function clone():Event
		{
			return new ChartClickEvent( type, graphPiece, bubbles, cancelable );
		}
		
	}
}

/* 
package.events
{
	public class CustomEvent extends Event
	{
		public static const CUSTOM_TYPE:String = “customType”;
		
		public var customProp:String;
		
		public function CustomEvent( type:String, cp:String, bubbles:Boolean, cancelable:Boolean )
		{
			super( type, bubbles, cancelable )
		
			customProp = cp;
		}
		
		public override function clone():Event
		{
			return new CustomEvent( type, customProp, bubbles, cancelable );
		}
	}
} 
*/
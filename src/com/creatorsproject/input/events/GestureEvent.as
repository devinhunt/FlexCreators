package com.creatorsproject.input.events
{
	import flash.events.Event;
	import flash.geom.Point;

	public class GestureEvent extends Event
	{
		
		/**
		 * The users is starting a swipe.
		 * @eventType swipeStart
		 */
		public static const SWIPE_START:String = "swipeStart";
		
		/**
		 * The users swipe has ended.
		 * @eventType swipeEnd
		 */
		public static const SWIPE_END:String = "swipeEnd";
		
		/**
		 * A swipe is occuring
		 * @eventType swipe
		 */
		public static const SWIPE:String = "swipe";
		
		/**
		 * One option the majorAxis property can be 
		 */
		public static const X_AXIS:String = "xAxis";
		
		/**
		 * One option the majorAxis property can be 
		 */
		public static const Y_AXIS:String = "yAxis";
		
		public function GestureEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, 
										majorAxis:String = X_AXIS, delta:Point = null)
		{
			super(type, bubbles, cancelable);
			this.majorAxis = majorAxis
			this.delta = delta;
		}
		
		/**
		 * The axis that the significant motion is taking place on 
		 */		
		public var majorAxis:String;
		
		/**
		 * The distance travled since the last swipe event, if any
		 */
		public var delta:Point;
	}
}
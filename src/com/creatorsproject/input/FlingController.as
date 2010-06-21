package com.creatorsproject.input
{
	import com.creatorsproject.input.events.GestureEvent;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Fling Controllers offer a layer inbetween the TouchController and the TouchUI to
	 * create and simulate different physical effects, mainly, elastic flinging
	 * (you know, like that fancy iPhone you have in your pocket) 
	 * @author devin
	 */	
	
	public class FlingController
	{
		
		public static const MIN_VELOCITY:Number = 1;
		public static const SMOOTH_SAMPLES:int = 3;
		
		public var velocityMultiplier:Number = 1 / 10;
		public var dappener:Number = 0.1;
		public var isSwiping:Boolean = false;
		public var velocity:Point;
		
		private var _deltas:Array;
		
		public function FlingController()
		{
			setupFling();
		}
		
		protected function setupFling():void {
			TouchController.me.addEventListener(GestureEvent.SWIPE_START, onSwipe);
			TouchController.me.addEventListener(GestureEvent.SWIPE_END, onSwipe);
			TouchController.me.addEventListener(GestureEvent.SWIPE, onSwipe);
		}
		
		protected function breakdownFling():void {
			TouchController.me.removeEventListener(GestureEvent.SWIPE_START, onSwipe);
			TouchController.me.removeEventListener(GestureEvent.SWIPE_END, onSwipe);
			TouchController.me.removeEventListener(GestureEvent.SWIPE, onSwipe);
		}
		
		//_________________________________________________ Events
		protected function onSwipe(event:GestureEvent = null):void {
			
			switch(event.type) {
				case GestureEvent.SWIPE_START:
					_deltas = [];
					velocity = smooth(event.delta);
					break;
				case GestureEvent.SWIPE:
					velocity = smooth(event.delta);
					break;
				case GestureEvent.SWIPE_END:
					break;
			}
		}
		
		/**
		 * Returns a smoothed out delta based on a running average of a series of last frames. 
		 * @param p The new delta to incorporate into the frame
		 * @return The smoothed input as a Point
		 */		
		private function smooth(p:Point):Point {
			if(_deltas.length >= SMOOTH_SAMPLES) {
				_deltas.shift();
			}
			_deltas.push(p);
			var result:Point = new Point();
			for each(var pt:Point in _deltas) {
				result.x += pt.x;
				result.y += pt.y;
			}
			result.x /= _deltas.length;
			result.y /= _deltas.length;
			return result;
		}
		
		protected function onMatteFrame(event:Event):void {
			if(Math.abs(velocity.x) > MIN_VELOCITY || Math.abs(velocity.y) > MIN_VELOCITY) {
				velocity.x *= (1 - dappener);
				velocity.y *= (1 - dappener);
			} else {
				isSwiping = false;
				TouchController.me.matte.removeEventListener(Event.ENTER_FRAME, onMatteFrame);
			}
		}
	}
}
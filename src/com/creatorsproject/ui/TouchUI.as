package com.creatorsproject.ui
{
	import com.creatorsproject.input.FlingController;
	import com.creatorsproject.input.TouchController;
	import com.creatorsproject.input.events.GestureEvent;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * Base class for all major 3D components in the Touch UI. 
	 * @author devin
	 * 
	 */	

	public class TouchUI extends DisplayObject3D
	{
		public var fling:FlingController;
		
		public function TouchUI(fling:FlingController = null)
		{
			super();
			
			if(! fling) {
				this.fling = new FlingController();
			} else {
				this.fling = fling;
			}
			
			this.initTouch();
		}
		
		protected function initTouch():void {
			TouchController.me.addEventListener(GestureEvent.MATTE_CLICK, onMatteClick);
			TouchController.me.addEventListener(GestureEvent.SWIPE_START, onSwipe);
			TouchController.me.addEventListener(GestureEvent.SWIPE_END, onSwipe);
			TouchController.me.addEventListener(GestureEvent.SWIPE, onSwipe);
		}
		
		protected function onMatteClick(event:GestureEvent):void {
			
		}
		
		protected function onSwipe(event:GestureEvent):void {
			switch(event.type) {
				case GestureEvent.SWIPE_START:
			
					break;
				case GestureEvent.SWIPE:
			
					break;
				case GestureEvent.SWIPE_END:
			
					break;
			}
		}
	}
}
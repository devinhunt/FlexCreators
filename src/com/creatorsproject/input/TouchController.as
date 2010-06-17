package com.creatorsproject.input
{
	import com.creatorsproject.input.events.GestureEvent;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	
	/**
	 * Translates mouse actions into navigation touch gestures and clicks.
	 * Gestures are sent out as GestureEvents 
	 * @author devin
	 */	
	
	public class TouchController extends EventDispatcher
	{
		public static const SWIPE_THRESHHOLD:Number = 100;
		
		private var _stage:Stage;
		private var _initialTouch:Point;
		private var _lastTouch:Point;
		private var _state:String;
		
		public function TouchController(stage:Stage)
		{
			_stage = stage;
			_initialTouch = new Point();
			_state = "noSwipe";
			this.setup();
		}
		
		// ________________________________________________ Setup
		
		protected function setup():void {
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function breakdown():void {
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		// ________________________________________________ Interaction Events
		
		private function onMouseDown(event:MouseEvent):void {
			_initialTouch.x = event.stageX;
			_initialTouch.y = event.stageY;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(event:MouseEvent):void {
			switch(_state) {
				case "noSwipe":
					var mag:Number = (_initialTouch.x - event.stageX) * (_initialTouch.x - event.stageX) + (_initialTouch.y - event.stageY) * (_initialTouch.y - event.stageY) 
					if( mag > SWIPE_THRESHHOLD) {
						_state = "swipe";
						this.dispatchSwipeEvent(GestureEvent.SWIPE_START);
					}
					break;
				case "swipe":
					this.dispatchSwipeEvent(GestureEvent.SWIPE);
					break;
			}
		}
		
		private function onMouseUp(event:MouseEvent):void {
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_state = "noSwipe";
			this.dispatchSwipeEvent(GestureEvent.SWIPE_END);
		}
		
		public function dispatchSwipeEvent(type:String):void {
			var event:GestureEvent = new GestureEvent(type);
			this.dispatchEvent(event);
		}
	}
}
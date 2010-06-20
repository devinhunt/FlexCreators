package com.creatorsproject.input
{
	import com.creatorsproject.input.events.GestureEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//_____________________________________________________ Events
	/**
	 * Dispatched when the user touches the screen and has moved there finger enough to
	 * register as a swipe
	 *
	 *  @eventType com.creatorsproject.input.events.GestureEvent.SWIPE_START
	 */
	[Event(name="swipeStart", type="com.creatorsproject.input.events.GestureEvent")]
	
	/**
	 * Dispatched when the user is currently moving there hand across the interface.
	 *
	 *  @eventType com.creatorsproject.input.events.GestureEvent.SWIPE
	 */
	[Event(name="swipe", type="com.creatorsproject.input.events.GestureEvent")]
	
	/**
	 * Dispatched when the removes their hand from the interface
	 *
	 *  @eventType com.creatorsproject.input.events.GestureEvent.SWIPE_END
	 */
	[Event(name="swipeEnd", type="com.creatorsproject.input.events.GestureEvent")]
	
	
	/**
	 * Translates mouse actions into navigation touch gestures and clicks.
	 * Gestures are sent out as GestureEvents 
	 * @author devin
	 */	
	public class TouchController extends EventDispatcher
	{
		// ________________________________________________ Singleton
		private static var _me:TouchController;
		public static function get me():TouchController {
			if(! _me) {
				_me = new TouchController();
			}
			return _me;
		}
		
		public static const SWIPE_THRESHHOLD:Number = 100;
		
		private var _stage:Stage;
		private var _matte:DisplayObject;
		private var _initialTouch:Point;
		private var _lastTouch:Point;
		private var _currentTouch:Point;
		private var _state:String;
		
		public function get matte():DisplayObject { return _matte; }
		
		public function TouchController()
		{
		}
		
		// ________________________________________________ Setup
		
		public function setup(stage:Stage, matte:DisplayObject = null):void {
			_stage = stage;
			_matte = matte ? matte : stage;
			_initialTouch = new Point();
			_state = "noSwipe";
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
			_lastTouch = new Point(event.stageX, event.stageY);
			_currentTouch = _lastTouch.clone();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(event:MouseEvent):void {
			_lastTouch = _currentTouch;
			_currentTouch = new Point(event.stageX, event.stageY);
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
			if(_state == "swipe") {
				_state = "noSwipe";
				this.dispatchSwipeEvent(GestureEvent.SWIPE_END);
			}
		}
		
		public function dispatchSwipeEvent(type:String):void {
			var event:GestureEvent = new GestureEvent(type);
			if(Math.abs(_currentTouch.x - _initialTouch.x) >= Math.abs(_currentTouch.y - _initialTouch.y)) {
				event.majorAxis = GestureEvent.X_AXIS;
			} else {
				event.majorAxis = GestureEvent.Y_AXIS;
			}
			event.delta = _currentTouch.subtract(_lastTouch);
			this.dispatchEvent(event);
		}
	}
}
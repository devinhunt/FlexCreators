package com.creatorsproject.input
{
	import com.creatorsproject.input.events.GestureEvent;
	
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
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
	 * Dispatched when a safe click occurs on the background matte
	 *
	 * @eventType com.creatorsproject.input.events.GestureEvent.MATTE_CLICK
	 */
	[Event(name="matteClick", type="com.creatorsproject.input.events.GestureEvent")]
	
	
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
		
		protected var _stage:Stage;
		protected var _matte:InteractiveObject;
		protected var _initialTouch:Point;
		protected var _lastTouch:Point;
		protected var _currentTouch:Point;
		protected var _state:String;
		private var _mattePressed:Boolean = false;
		
		public function get state():String { return _state; } 
		public function get stage():Stage { return _stage; }
		public function get matte():InteractiveObject { return _matte; }
		
		public function TouchController()
		{
		}
		
		// ________________________________________________ Setup
		
		public function setup(stage:Stage, matte:InteractiveObject = null):void {
			_stage = stage;
			_matte = matte ? matte : stage;
			_initialTouch = new Point();
			_state = "noSwipe";
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			if(_stage != _matte) {
				_matte.addEventListener(MouseEvent.MOUSE_DOWN, onMatteDown);
			}
		}
		
		protected function breakdown():void {
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		// ________________________________________________ Interaction Events
		
		private function onMatteDown(event:MouseEvent):void {
			_mattePressed = true;
		}
		
		private function onMouseDown(event:MouseEvent):void {
			_initialTouch.x = event.stageX;
			_initialTouch.y = event.stageY;
			_lastTouch = new Point(event.stageX, event.stageY);
			_currentTouch = _lastTouch.clone();
			//_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.addEventListener(Event.ENTER_FRAME, onMouseMove);
			_state = "touching";
			this.dispatchSwipeEvent(GestureEvent.SWIPE_START);
		}
		
		//private function onMouseMove(event:MouseEvent):void {
		private function onMouseMove(event:Event):void {
			_lastTouch = _currentTouch;
			_currentTouch = new Point(_stage.mouseX, _stage.mouseY);
			switch(_state) {
				case "touching":
					var mag:Number = (_initialTouch.x - _stage.mouseX) * (_initialTouch.x - _stage.mouseX) + (_initialTouch.y - _stage.mouseY) * (_initialTouch.y - _stage.mouseY) 
					if( mag > SWIPE_THRESHHOLD) {
						_state = "swipe";
					}
					break;
				case "swipe":
					this.dispatchSwipeEvent(GestureEvent.SWIPE);
					break;
			}
		}
		
		private function onMouseUp(event:MouseEvent):void {
			if(_mattePressed && _state == "touching") {
				this.dispatchSwipeEvent(GestureEvent.MATTE_CLICK);
			}
			
			//_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(Event.ENTER_FRAME, onMouseMove);
			_stage.addEventListener(Event.ENTER_FRAME, oneMore);
			_mattePressed = false;
		}
		
		private function oneMore(event:Event):void {
			_stage.removeEventListener(Event.ENTER_FRAME, oneMore);
			_state = "noSwipe";
			this.dispatchSwipeEvent(GestureEvent.SWIPE_END);
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
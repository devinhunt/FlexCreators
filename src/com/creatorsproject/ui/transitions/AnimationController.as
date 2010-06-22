package com.creatorsproject.ui.transitions
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import mx.effects.easing.Linear;
	
	import org.papervision3d.events.AnimationEvent;
	
	/**
	 * Controls and runs a series of animations on DisplayObject3D's 
	 * @author devin
	 */	
	
	public class AnimationController extends EventDispatcher
	{
		private var _profiles:Array;
		private var _duration:int;
		private var _startTick:int;
		public var func:Function = Linear.easeInOut;
		
		public function AnimationController(duration:Number = 1000)
		{
			_profiles = []
			_duration = duration;
		}
		
		public function addAnimationProfile(profile:AnimationProfile):void {
			_profiles.push(profile);
		}
		
		/**
		 * Starts the animation 
		 */		
		public function start():void {
			_startTick = 0;
			main.instance.stage.addEventListener(Event.ENTER_FRAME, onTick);
			this.dispatchEvent(new AnimationEvent(AnimationEvent.START, 0));
			_startTick = flash.utils.getTimer();
		}
		
		/**
		 * Ends the animation
		 */
		public function stop():void {
			main.instance.stage.removeEventListener(Event.ENTER_FRAME, onTick);
			this.dispatchEvent(new AnimationEvent(AnimationEvent.STOP, 0));
		}
		
		public function breakdown():void {
			for each(var profile:AnimationProfile in _profiles) {
				profile.target = null;
				profile.startPosition = null;
				profile.endPosition = null;
			}
			_profiles = [];
		}
		
		/**
		 * Called on a new render frame 
		 * @param event The Enterframe event 
		 */		
		private function onTick(event:Event):void {
			var elapsed:int = flash.utils.getTimer() - _startTick;
			
			if(elapsed > _duration) {
				elapsed = _duration;
			}
			
			var delta:Number = func(elapsed, 0, 1, _duration);
			for each(var profile:AnimationProfile in _profiles) {
				profile.target.x = profile.startPosition.x + (profile.endPosition.x - profile.startPosition.x) * delta;
				profile.target.y = profile.startPosition.y + (profile.endPosition.y - profile.startPosition.y) * delta;
				profile.target.z = profile.startPosition.z + (profile.endPosition.z - profile.startPosition.z) * delta;
			}
			
			if(elapsed == _duration) {
				this.stop();
				this.dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE, 0));
			}
		}
	}
}
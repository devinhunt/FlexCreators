package com.creatorsproject.data
{
	import flash.utils.Dictionary;
	
	public class Schedule
	{
		
		private var events:Array;
		
		public function Schedule()
		{
			this.events = [];
		}
		
		public function addEvent(event:ScheduleEvent):void {
			this.events.push(event);
		}

	}
}
package com.creatorsproject.data
{
	import flash.events.Event;
	
	public class ScheduleEvent
	{
		
		/** The name of the event */		
		public var name:String;
		
		/** The type of the event */		
		public var eventType:String;
		
		/** The begin time of the event in local time zone */		
		public var startTime:Date;
		
		/** The end time of the event in local time zone */
		public var endTime:Date;
		
		/** And the where it's happening in */
		public var location:EventLocation;
		
		public function ScheduleEvent(name:String, eventType:String, location:EventLocation, startTime:Date, endTime:Date)
		{
			this.name = name;
			this.eventType = eventType;
			this.location = location;
			this.startTime = startTime;
			this.endTime = endTime;
		}
	}
}
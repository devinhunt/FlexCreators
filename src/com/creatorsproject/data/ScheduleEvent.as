package com.creatorsproject.data
{
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
		
		/** And where it's happening */
		public var location:EventLocation;
		
		public function ScheduleEvent()
		{
			
		}

	}
}
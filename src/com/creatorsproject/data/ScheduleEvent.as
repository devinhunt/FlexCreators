package com.creatorsproject.data
{
	import com.adobe.protocols.dict.Database;
	
	public class ScheduleEvent
	{
		
		/** The name of the event */		
		public var name:String;
		
		/** The begin time of the event in local time zone */		
		public var startTime:Date;
		
		/** The end time of the event in local time zone */
		public var endTime:Date;
		
		/** ID of the room this event is taking place in */
		public var roomId:String;
		
		/** ID of the creator for this event */
		public var creatorId:String;
		
		public function ScheduleEvent(name:String, roomId:String, creatorId:String, startTime:Date, endTime:Date)
		{
			this.name = name;
			this.roomId = roomId;
			this.creatorId = creatorId;
			this.startTime = startTime;
			this.endTime = endTime;
		}
		
		/**
		 * Static event to add object creation 
		 * @param rawEvent The raw event object model
		 */		
		public static function createEventFromJson(rawEvent:Object):ScheduleEvent {
			
			
			return new ScheduleEvent(rawEvent.fields.name, 
										rawEvent.fields.room, 
										rawEvent.fields.creator,
										dateFromJSON(rawEvent.fields.start),
										dateFromJSON(rawEvent.fields.end));
		}
		
		public static function dateFromJSON(jsonDate:String):Date {
			var dateSet:Array = (jsonDate.split(" ")[0] as String).split("-");
			var timeSet:Array = (jsonDate.split(" ")[1] as String).split(":");
			
			return new Date(dateSet[0], dateSet[1], dateSet[2], timeSet[0], timeSet[1]);
		}
	}
}
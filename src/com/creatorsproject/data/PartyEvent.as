package com.creatorsproject.data
{
	import com.adobe.protocols.dict.Database;
	
	public class PartyEvent
	{
		
		/** The PK id of the event on the live server */
		public var id:String;
		
		/** The name of the event */		
		public var name:String;
		
		/** The begin time of the event in local time zone */		
		public var startTime:Date;
		
		/** The end time of the event in local time zone */
		public var endTime:Date;
		
		/** ID of the room this event is taking place in */
		public var roomId:String;
		
		/** The name of the room this is taking place in. This is usually set when the event is added to a room object */
		public var roomName:String = "Default room";
		
		/** ID of the creator for this event */
		public var creatorId:String;
		
		public function PartyEvent(id:String, name:String, roomId:String, creatorId:String, startTime:Date, endTime:Date)
		{
			this.id = id;
			this.name = name;
			this.roomId = roomId;
			this.creatorId = creatorId;
			this.startTime = startTime;
			this.endTime = endTime;
		}
		
		//_________________________________________________ Getter and Setters
		
		/** The duration of the event in hours */
		public function get duration():Number { 
			return (endTime.getTime() - startTime.getTime()) / 1000 / 60 / 60;
		}
		
		public function get dateString():String {
			return startTime.getUTCHours() + ":" + startTime.getUTCMinutes() + " to " + endTime.getUTCHours() + ":" + endTime.getUTCMinutes(); 
		}
		
		/**
		 * Static event to add object creation 
		 * @param rawEvent The raw event object model
		 */				
		public static function createEventFromJson(rawEvent:Object):PartyEvent {
			
			
			return new PartyEvent(rawEvent.pk,
										rawEvent.fields.name, 
										rawEvent.fields.room, 
										rawEvent.fields.creator,
										PartyData.dateFromJSON(rawEvent.fields.start),
										PartyData.dateFromJSON(rawEvent.fields.end));
		}
	}
}
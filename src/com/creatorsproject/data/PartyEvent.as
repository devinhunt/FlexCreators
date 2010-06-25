package com.creatorsproject.data
{
	import com.adobe.protocols.dict.Database;
	
	public class PartyEvent
	{
		
		/** The PK id of the event on the live server */
		public var id:String;
		
		/** The name of the event */
		[Bindable]		
		public var name:String;
		
		/** The begin time of the event in local time zone */		
		public var startTime:Date;
		
		/** The end time of the event in local time zone */
		public var endTime:Date;
		
		/** ID of the room this event is taking place in */
		public var roomId:String;
		
		/** The name of the room this is taking place in. This is usually set when the event is added to a room object */
		public var roomName:String = "Default room";
		
		/** The new of the floor */
		public var floorName:String  = "Default floor";
		
		public var description:String;
		
		/** ID of the creator for this event */
		public var creatorId:String;
		
		public var chipUrl:String;
		
		public function PartyEvent(raw:Object)
		{
			this.id = raw.pk;
			this.name = raw.fields.name;
			this.roomId = raw.fields.room;
			this.creatorId = raw.fields.creator;
			this.startTime = PartyData.dateFromJSON(raw.fields.start);
			this.endTime = PartyData.dateFromJSON(raw.fields.end);
			this.description = raw.fields.description;
		}
		
		//_________________________________________________ Getter and Setters
		
		/** The duration of the event in hours */
		public function get duration():Number { 
			return (endTime.getTime() - startTime.getTime()) / 1000 / 60 / 60;
		}
		
		public function get dateString():String {
			var sHours:String = startTime.getHours() + "";
			var sMinutes:String = startTime.getMinutes() + "";
			var eHours:String = endTime.getHours() + "";
			var eMinutes:String = endTime.getMinutes() + "";
			
			sHours = sHours.length < 2 ? "0" + sHours : sHours;
			sMinutes = sMinutes.length < 2 ? "0" + sMinutes : sMinutes;
			eHours = eHours.length < 2 ? "0" + eHours : eHours;
			eMinutes = eMinutes.length < 2 ? "0" + eMinutes : eMinutes;
			
			return sHours + ":" + sMinutes + " to " + eHours + ":" + eMinutes; 
		}
	}
}
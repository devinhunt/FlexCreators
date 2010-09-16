package com.creatorsproject.data
{
	
	/**
	 * Represents a location in the party
	 * @author devin
	 */	
	public class EventRoom
	{
		public var id:String;
		public var floorId:String;
		public var name:String;
		
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		
		public var events:Array;
		
		public function EventRoom(raw:Object)
		{
			this.id = raw.pk;
			this.name = raw.fields.name;
			this.floorId = raw.fields.floor;
			this.x = parseInt(raw.fields.x, 10);
			this.y = parseInt(raw.fields.y, 10);
			this.width = parseInt(raw.fields.width, 10);
			this.height = parseInt(raw.fields.height, 10);
			
			events = [];
		}
		
		public function addEvent(event:PartyEvent):void {
			event.roomName = this.name;
			events.push(event);
		}
	}
}
package com.creatorsproject.data
{
	
	/**
	 * Represents a location in the party
	 * @author devin
	 */	
	public class EventLocation
	{
		public var floor:String;
		public var room:String;
		
		public function EventLocation(floor:String, room:String)
		{
			this.floor = floor;
			this.room = room;
		}
	}
}
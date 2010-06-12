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
		
		public function EventLocation(room:String, floor:String = "1st Floor")
		{
			this.room = room;
			this.floor = floor
		}
	}
}
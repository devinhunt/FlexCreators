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
		
		public var events:Array;
		
		public function EventRoom(id:String, name:String, floor:String)
		{
			this.id = id;
			this.name = name;
			this.floorId = floor;
			
			events = [];
		}
	}
}
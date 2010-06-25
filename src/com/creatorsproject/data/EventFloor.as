package com.creatorsproject.data
{
	import com.creatorsproject.ui.chips.EventDetailChip;
	
	public class EventFloor
	{
		public var id:String;
		public var order:int;
		public var name:String;
		
		/** All the rooms associated with this floor */
		public var rooms:Array;
		
		public function EventFloor(id:String, name:String, order:int = 0)
		{
			this.id = id;
			this.name = name;
			this.order = order;
			this.rooms = []; 
		}
		
		public function cullRooms(kill:Array):void {
			var keeps:Array = []
			for each(var room:EventRoom in rooms) {
				if(kill.indexOf(room) == -1) {
					keeps.push(room)
				}
			}
			rooms = keeps;
		}
	}
}
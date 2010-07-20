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
		
		public function EventFloor(rawFloor:Object)
		{
			this.id = rawFloor.pk;
			this.name = rawFloor.fields.name;
			this.order = parseInt(rawFloor.fields.order, 10);
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
package com.creatorsproject.data
{
	public class PartyStatus
	{
		
		public var id:int;
		public var status:String;
		public var time:Date;
		public var user:String;
		public var roomId:String;
		public var state:String; 
		
		public function PartyStatus(rawStatus:Object)
		{
			id = parseInt(rawStatus.pk, 10);
			status = rawStatus.fields.status;
			time = PartyData.dateFromJSON(rawStatus.fields.created);
			user = rawStatus.fields.user;
			roomId = rawStatus.fields.room;
			state = rawStatus.fields.state;
		}
	}
}
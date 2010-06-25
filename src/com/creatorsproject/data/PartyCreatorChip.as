package com.creatorsproject.data
{
	public class PartyCreatorChip
	{
		public var id:String;
		public var creatorId:String;
		public var relatedChipIds:Array;
		public var videoId:String;
		
		public function PartyCreatorChip(raw:Object)
		{
			this.id = raw.pk;
			this.creatorId = raw.fields.creator;
			this.relatedChipIds = raw.fields.relatedChips;
			this.videoId = raw.fields.video;
		}

	}
}
package com.creatorsproject.data
{
	public class PartyPhoto
	{
		public var id:int;
		public var created:Date;
		
		[Bindable]
		public var imageUrl:String;
		
		public function PartyPhoto(raw:Object)
		{
			id = parseInt(raw.pk, 10);
			created = PartyData.dateFromJSON(raw.fields.created);
			imageUrl = DataConstants.mediaUrl + raw.fields.image;
		}

	}
}
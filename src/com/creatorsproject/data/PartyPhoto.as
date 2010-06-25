package com.creatorsproject.data
{
	public class PartyPhoto
	{
		public var id:String;
		public var created:Date;
		
		[Bindable]
		public var imageUrl:String;
		
		public function PartyPhoto(raw:Object)
		{
			id = raw.pk;
			created = PartyData.dateFromJSON(raw.fields.created);
			imageUrl = DataConstants.mediaUrl + raw.fields.image;
		}

	}
}
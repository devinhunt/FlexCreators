package com.creatorsproject.data
{
	public class Creator
	{
		public var id:String;
		public var name:String;
		public var location:String;
		public var synopsis:String;
		public var iconKey:String;
		public var videoKey:String;
		
		public function Creator(raw:Object = null)
		{
			this.id = raw.pk;
			this.name = raw.fields.name;
			this.location = raw.fields.location;
			this.synopsis = raw.fields.description;
			this.iconKey = raw.fields.icon;
			this.videoKey = raw.fields.video_key;
		}
	}
}
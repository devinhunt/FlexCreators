package com.creatorsproject.data
{
	public class Creator
	{
		public var id:String;
		public var name:String;
		public var location:String;
		public var thumbUrl:String;
		public var synopsis:String;
		
		public function Creator(raw:Object = null)
		{
			this.id = raw.pk;
			this.name = raw.fields.name;
			this.location = raw.fields.location;
			this.thumbUrl = raw.fields.local_thumb || raw.fields.remote_thumb;
			this.synopsis = raw.fields.synopsis;
		}
	}
}
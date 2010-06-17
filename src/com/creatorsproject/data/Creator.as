package com.creatorsproject.data
{
	public class Creator
	{
		public var id:String;
		public var name:String;
		public var kind:String;
		public var thumbUrl:String;
		
		public function Creator(raw:Object = null)
		{
			this.id = raw.pk;
			this.name = raw.fields.thumbnail;
			this.kind = raw.fields.kind;
			this.thumbUrl = raw.fields.thumbnail;
		}
	}
}
package com.creatorsproject.data
{
	public class PartyVideo
	{
		public var id:String;
		public var fileName:String;
		public var title:String;
		
		public function PartyVideo(raw:Object)
		{
			this.id = raw.pk;
			this.fileName = raw.fields.file_name;
			this.title = raw.fields.title;
		}

	}
}
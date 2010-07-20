package com.creatorsproject.data
{
	import flash.filesystem.File;
	
	public class DataConstants
	{
		public static var isLocal:Boolean = true;
		
		public static var URL_SERVER:String = "http://localhost:8000/";
		
		public static const URL_LOCAL:String = "http://localhost:8000/";
		public static const URL_LIVE:String = "http://ec2-184-73-108-19.compute-1.amazonaws.com/";
		
		public static const URL_LOCAL_IMG:String = "http://localhost:8000/static/";
		public static const URL_LIVE_IMG:String = "http://ec2-184-73-108-19.compute-1.amazonaws.com/static/";
		
		public static const URL_SCHEDULE:String = "api/events/normal/";
		public static const URL_CREATOR:String = "api/creators/";
		public static const URL_ROOM:String = "api/rooms/";
		public static const URL_FLOOR:String = "api/floors/";
		public static const URL_VIDEO:String = "api/videos/";
		public static const URL_STATUS:String = "api/status/";
		public static const URL_STATUS_SINCE:String = "api/status/since/";
		public static const URL_PHOTO:String = "api/photos/";
		public static const URL_PHOTO_LATEST:String = "api/photos/latest/";
		public static const URL_ASSETS:String = "api/assets/";
		
		public static function get mediaUrl():String { return isLocal ? URL_LOCAL_IMG : URL_LIVE_IMG; }
		public static function get serverUrl():String { return isLocal ? URL_LOCAL : URL_LIVE; }
		
		public static const floorColors:Object = { "1st Floor" : 0xED1C8F,
												   "Second Floor" : 0xf8941d,
												   "Eighth Floor" : 0x00AFDB }
		
		public static const roomColors:Object = { "First Floor" : 0xffffff,
												   "Second Floor" : 0xffffff,
												   "Eighth Floor" : 0xffffff }
												   
		public static var videoDir:File;
	}
}
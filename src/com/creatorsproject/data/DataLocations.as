package com.creatorsproject.data
{
	public class DataLocations
	{
		public static var isLocal:Boolean = true;
		
		public static var URL_SERVER:String = "http://localhost:8000/";
		
		public static const URL_LOCAL:String = "http://localhost:8000/";
		public static const URL_LIVE:String = "http://ec2-184-73-108-19.compute-1.amazonaws.com/";
		
		public static const URL_LOCAL_IMG:String = "http://localhost:8000/static/";
		public static const URL_LIVE_IMG:String = "http://ec2-184-73-108-19.compute-1.amazonaws.com/static/";
		
		public static const URL_SCHEDULE:String = "api/schedule/";
		public static const URL_CREATOR:String = "api/creator/";
		public static const URL_ROOM:String = "api/room/";
		public static const URL_FLOOR:String = "api/floor/";
		public static const URL_VIDEO:String = "api/videos/";
		public static const URL_STATUS:String = "api/status/";
		public static const URL_PHOTO_LATEST:String = "api/livephoto/latest/";
		
		public static function get mediaUrl():String { return isLocal ? URL_LOCAL_IMG : URL_LIVE_IMG; }
		public static function get serverUrl():String { return isLocal ? URL_LOCAL : URL_LIVE; }
	}
}
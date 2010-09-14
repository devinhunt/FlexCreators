package com.creatorsproject.data
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class AssetLoader extends EventDispatcher
	{
		public var key:String;
		public var isLoaded:Boolean = false;
		public var assetUrl:String = "";
		
		public function AssetLoader(key:String)
		{
			this.key = key;
		}
		
		/**
		 * Get the URL for the actual image from the server 
		 * @param suffix Special suffix to append
		 */		
		public function load(suffix:String = ""):void {
			var url:String = DataConstants.serverUrl + DataConstants.URL_ASSETS + "?key=" + this.key + suffix;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, this.onAssetUrlRecieved);
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.onImageError);
			loader.load(new URLRequest(url));
		}
		
		private function onAssetUrlRecieved(event:Event):void {
			var rawData:String = (event.target as URLLoader).data;
			var rawAsset:Object = JSON.decode(rawData);
			assetUrl = rawAsset.data[0].fields.image;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onImageError(event:Event):void {
			
		}
	}
}
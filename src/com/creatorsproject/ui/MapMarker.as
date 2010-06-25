package com.creatorsproject.ui
{
	import com.creatorsproject.data.DataConstants;
	import com.creatorsproject.data.PartyEvent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;

	public class MapMarker extends UIComponent
	{
		public function MapMarker(event:PartyEvent, w:Number = 50, h:Number = 50)
		{
			super();

			var loader:Loader = new Loader();
			var req:URLRequest = new URLRequest(DataConstants.mediaUrl + event.chipUrl);
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			this.addChild(loader);
		}
		
		private function onLoadComplete(event:Event):void {
			
		}
	}
}
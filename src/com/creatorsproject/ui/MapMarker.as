package com.creatorsproject.ui
{
	import com.creatorsproject.data.AssetLoader;
	import com.creatorsproject.data.DataConstants;
	import com.creatorsproject.data.PartyEvent;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;


	/**
	 * Simple object that shows the current chip of the event on the map. Should be placed on the front UI. 
	 * @author devin
	 * 
	 */	
	public class MapMarker extends UIComponent
	{
		public var event:PartyEvent;
		public var assetUrlLoader:AssetLoader;		
		
		public function MapMarker(event:PartyEvent, w:Number = 50, h:Number = 50)
		{
			super();
			this.event = event;
			assetUrlLoader = new AssetLoader(this.event.assetKey);
			assetUrlLoader.addEventListener(Event.COMPLETE, loadChip);
			assetUrlLoader.load();
		}
		
		public function loadChip(event:Event = null):void {
			var loader:Loader = new Loader();
			var req:URLRequest = new URLRequest(DataConstants.mediaUrl + assetUrlLoader.assetUrl);
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			this.addChild(loader);
			this.width = 50;
			this.height = 50;
		}
		
		private function onLoadComplete(event:Event):void {
			
		}
	}
}
package com.creatorsproject.ui
{
	import com.adobe.serialization.json.JSON;
	import com.creatorsproject.data.Creator;
	import com.creatorsproject.data.DataConstants;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.primitives.Plane;
	
	/**
	 * The creators plan adds functionality to a plane to load and draw an Image from
	 * a URL as it's main texture.  
	 * @author devin
	 */	

	public class CreatorPlane extends Plane
	{
		private var _imageLoader:Loader;
		public var creator:Creator;
		
		/**
		 * 
		 * @param creator
		 * 
		 */
		public function CreatorPlane(creator:Creator)
		{
			var c:ColorMaterial = new ColorMaterial();
			c.interactive = true;
			super(c, 401, 352);
			this.creator = creator;
			this.getAndLoadImage();
		}
		
		private function getAndLoadImage():void {
			var url:String = DataConstants.serverUrl + DataConstants.URL_ASSETS + "?key=" + creator.iconKey + "_hirez";
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, this.onAssetUrlRecieved);
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.onImageError);
			loader.load(new URLRequest(url));
		}
		
		private function onAssetUrlRecieved(event:Event):void {
			var rawData:String = (event.target as URLLoader).data;
			var rawAsset:Object = JSON.decode(rawData);
			this.loadImage(rawAsset.data[0].fields.image);
		}
		
		private function loadImage(assetUrl:String):void {
			_imageLoader = new Loader();
			_imageLoader.load(new URLRequest(DataConstants.mediaUrl + assetUrl));
			_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
		}
		
		private function onLoadComplete(event:Event):void {
			
			var tex:MovieClip = new MovieClip();
			tex.addChild(_imageLoader);
			
			var t:TextField = new TextField();
			t.text = creator.name;
			var format:TextFormat = new TextFormat("Neo Sans Intel", 32);
			t.setTextFormat(format);
			t.x = 20;
			t.y = _imageLoader.height + 10;
			t.width = 2 * _imageLoader.width / 3;
			t.height = 40;
			
			tex.addChild(t);
			
			var mMat:MovieMaterial = new MovieMaterial(tex, true, false);
			mMat.interactive = true;
			this.material = mMat;
		}
		
		private function onImageError(event:IOErrorEvent):void {
			
		}
	}
}
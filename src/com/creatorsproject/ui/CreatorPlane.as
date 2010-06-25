package com.creatorsproject.ui
{
	import com.creatorsproject.data.Creator;
	import com.creatorsproject.data.DataConstants;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Plane;

	public class CreatorPlane extends Plane
	{
		private var _imageLoader:Loader;
		public var creator:Creator;
		
		public function CreatorPlane(creator:Creator)
		{
			var c:ColorMaterial = new ColorMaterial();
			c.interactive = true;
			super(c, 401, 307, 1, 1);
			this.creator = creator;
			this.loadImage();
		}
		
		private function loadImage():void {
			_imageLoader = new Loader();
			_imageLoader.load(new URLRequest(DataConstants.mediaUrl + creator.thumbUrl));
			_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			_imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
		}
		
		private function onLoadComplete(event:Event):void {
			var image:Bitmap = _imageLoader.content as Bitmap;
			var bMat:BitmapMaterial = new BitmapMaterial(image.bitmapData);
			bMat.interactive = true;
			this.material = bMat;
		}
		
		private function onImageError(event:IOErrorEvent):void {
			
		}
	}
}
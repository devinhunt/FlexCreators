package com.creatorsproject.ui
{
	import flash.display.MovieClip;

	public class MapMarker extends MovieClip
	{
		public function MapMarker(title:String, chipUrl:String, w:Number = 50, h:Number = 50)
		{
			super();
			
			this.name = title;
			
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(w / 2, h / 2, w, h);
			this.graphics.endFill();
		}
		
	}
}
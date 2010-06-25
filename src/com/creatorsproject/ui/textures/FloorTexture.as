package com.creatorsproject.ui.textures
{
	import com.creatorsproject.data.EventFloor;
	import com.creatorsproject.data.PartyEvent;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	 * Special texture that lays out the event division off a floor. 
	 * @author devin
	 */	
	
	public class FloorTexture extends MovieClip
	{
		/** The floor that everything happens on */		
		private var _floor:EventFloor;
		
		private var _totalHours;
		private var _widthPerHour:Number;
		private var _height:Number;
		
		/**
		 *  
		 * @param floor The floor we're building a texture for
		 * 
		 */		
		public function FloorTexture(floor:EventFloor, totalHours:Number, widthPerHour:Number = 100, height:Number = 100)
		{
			super();
			_floor = floor;
			_totalHours = totalHours;
			_widthPerHour = widthPerHour;
			_height = height;
		}
		
		private function buildTexture():void {
			
			for each(var event:PartyEvent in _floor) {
				
			}
		}
		
		private function getTextField(msg:String, w:Number = 100, h:Number = 100):TextField {
			var text:TextField = new TextField();
			text = new TextField();
			text.wordWrap = true;
			text.width = w;
			text.height = h;
			text.multiline = true;
			text.htmlText = msg;
			return text;
		}
	}
}
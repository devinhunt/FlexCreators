package com.creatorsproject.ui
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;

	public class ScheduleMarker extends UIComponent
	{
		// private var _title:String;
		// private var _width:Number;
		// private var _height:Number;
		
		public function ScheduleMarker(title:String, format:TextFormat = null, w:Number = 100, h:Number = 50)
		{
			super();
			
			this.name = title;
			
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.moveTo(w, h / 2 - 10);
			this.graphics.lineTo(w + 10, h / 2);
			this.graphics.lineTo(w, h / 2 + 10);
			this.graphics.endFill();
			
			var text:TextField = new TextField();
			text.wordWrap = true;
			text.width = w;
			text.height = h;
			text.multiline = true;
			text.htmlText = title;
			
			text.x = 10;
			text.y = h / 2 - text.textHeight / 2 - 3;
			
			if(format) {
				text.setTextFormat(format);
			} else {
				var f:TextFormat = new TextFormat("Neo Sans Intel", null, 0xffffff);
				text.setTextFormat(f);
			}
			
			this.addChild(text);
		}
	}
}
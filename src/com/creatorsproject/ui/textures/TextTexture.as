package com.creatorsproject.ui.textures
{
	import flash.display.MovieClip;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TextTexture extends MovieClip
	{
		private var _text:TextField
		
		public function TextTexture(w:Number = 100, h:Number = 100, msg:String = "Default Text", bgColor:Number = 0xff00ff, format:TextFormat = null)
		{
			super();
			
			_text = new TextField();
			_text.wordWrap = true;
			_text.width = w;
			_text.height = h;
			_text.multiline = true;
			_text.htmlText = msg;
			
			_text.autoSize = TextFieldAutoSize.CENTER;
			
			if(format) {
				_text.setTextFormat(format);
			}
			
			_text.antiAliasType = AntiAliasType.NORMAL;
			
			this.graphics.beginFill(bgColor);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.endFill();
			
			this.addChild(_text);
		}
		
	}
}
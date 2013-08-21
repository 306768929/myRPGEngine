package CCUICoponent
{
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * 三国志专用TextField
	 * @author Howard.Ren [ D5Power Studio ]
	 */
	public class D5TLFText extends TextField
	{
		public static const TYPEID:uint = 4;
		
		private var _maxWidth:uint=200;
		private var lockWidth:uint = 0;
		private var _format:TextFormat;
		public var filter:GlowFilter;
		public static const LEFT:uint = 0;
		public static const CENTER:uint = 1;
		public static const RIGHT:uint = 2;
		public var data:*;
		
		/**
		 * 
		 * @param	_text		字符内容
		 * @param	fontcolor	字体颜色
		 * @param	bgcolor		文本框背景颜色
		 * @param	border		文本框边线颜色
		 */
		public function D5TLFText(_text:String = '', fontcolor:int = -1, bgcolor:int = -1, border:int = -1,size:uint=12) 
		{
			super();
			if (fontcolor>=0) textColor = fontcolor;
			if (bgcolor>=0) bgColor = bgcolor;
			if (border>=0) fontBorder = border;
			_format = new TextFormat(null, size);
			selectable = false;
			height = 18;
			if (_text != '')
			{
				text = _text;
				flush();
			}
			addEventListener(Event.CHANGE, autoAlignHandle);
		}
		
		public function get textFormat():TextFormat
		{
			return _format;
		}
		
		private var _beginIndex:int = -1;
		private var _endIndex:int = -1;
		override public function setTextFormat(format:TextFormat, beginIndex:int=-1, endIndex:int=-1):void
		{
			super.setTextFormat(format,beginIndex,endIndex);
			_beginIndex = beginIndex;
			_endIndex = endIndex;
			_format = format;
		}
		
		/**
		 * 设置最大宽度
		 */ 
		public function set maxWidth(v:uint):void
		{
			_maxWidth = v;	
		}
		
		/**
		 * 自动调整宽度和高度
		 */ 
		public function autoGrow():void
		{
			width = _maxWidth==0 || multiline==false ? textWidth+int(int(_format.size)/2) : _maxWidth;
			height = textHeight+int(Number(_format.size)/2);
		}
		
		/**
		 * 设置文本框的背景颜色
		 */
		public function set bgColor(color:uint):void
		{
			background = true;
			backgroundColor = color;
		}
		
		/**
		 * 设置文本内容的描边
		 */
		public function set fontBorder(color:uint):void
		{
			filter = new GlowFilter(color, 1, 2, 2, 1000);
			filters = new Array(filter);
		}
		
		public function light(color:uint,size:uint,round:Number,inner:Boolean=false):void
		{
			filter = new GlowFilter(color,.8, size, size, round,1,inner);
			filters = new Array(filter);
		}
		
		/**
		 * 设置对齐
		 */
		public function set align(type:uint):void
		{
			switch(type)
			{
				case CENTER:
					_format.align = TextFormatAlign.CENTER;
					break;
				case LEFT:
					_format.align = TextFormatAlign.LEFT;
					break;
				case RIGHT:
					_format.align = TextFormatAlign.RIGHT;
					break;
			}
			flush();
		}
		
		override public function set text(t:String):void
		{
			if(wordWrap)
			{
				wordWrap=false;
				super.text = t;
				if(textWidth>_maxWidth) lockWidth = _maxWidth;
				wordWrap=true;
			}else{
				super.text = t;
			}
			
			flush();
		}
		
		override public function set htmlText(value:String):void
		{
			if(wordWrap)
			{
				wordWrap=false;
				super.htmlText = value;
				if(textWidth>_maxWidth) lockWidth = _maxWidth;
				wordWrap=true;
			}else{
				super.htmlText = value;
			}
			
			flush();
		}
		
		/**
		 * 刷新文本样式
		 */
		public function flush():void
		{
			setTextFormat(_format);
		}
		
		/**
		 * 将文本框锁定在某背景元素上,使文本框的宽\高\坐标与目标完全一致
		 * @param	d
		 */
		private var _d:DisplayObject;
		public function lockTo(d:DisplayObject,changeHeight:Boolean=false,padding:uint=0):void
		{
			_d = d;
			width = d.width-padding*2;
			if (changeHeight)
			{
				height = d.height-padding*2;
			}
			x = d.x+padding+5;
			y = d.y+padding+1;
			
		}
		
		/**
		 * 重新定义文本框偏移
		 * @param	xpos	X偏移
		 * @param	ypos	Y偏移
		 */
		public function XYpos(xpos:int,ypos:int):void
		{
			if(_d==null) return;
			_d.x += xpos;
			_d.y += ypos;
		}
		
		/**
		 * 设置字体大小
		 */
		public function set fontSize(size:uint):void
		{
			_format.size = size;
			flush();
		}
		
		public function set fontBold(b:Boolean):void
		{
			_format.bold = b;
			flush();
		}
		
		/**
		 * 设置字体
		 */
		public function set fontName(fontname:String):void
		{
			if(fontname!=null && fontname!='')
			{
//				_format.font = SanguoGlobal.embedFont.fontName;
			}
			flush();
		}
		
		/**
		 * 设置为多行，并自动设置为自动换行
		 */
		override public function set multiline(t:Boolean):void
		{
			super.multiline = t;
			wordWrap = t;
		}
		
		/**
		 * 设置文本的输入类型（是否允许输入）
		 */
		override public function set type(s:String):void
		{
			super.type = s;
			selectable = true;
		}
		
		/**
		 * 用于自动对齐
		 * @param	e
		 */
		private function autoAlignHandle(e:Event):void
		{
			if (text == '') return;
			flush();
		}
		
		public function clear():void
		{
			removeEventListener(Event.CHANGE, autoAlignHandle);
			filters = null;
			text = '';
			htmlText = '';
		}
		
	}
	
}
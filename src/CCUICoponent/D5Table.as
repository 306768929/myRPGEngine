package CCUICoponent
{
	import CCUICoponent.D5IVfaceButton;
	import CCUICoponent.D5TLFText;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * 表格
	 * 以下说明中，TR表示表格的标题头
	 * TD表示表格的内容
	 * @example
	 * <listing version="3.0">
	 * var table:Table = new Table();
	 * table.addTr('第一列', 50);
	 * table.addTr('第二列', 100);
	 * table.addTr('第三列', 200);
	 * table.addTr('第四列', 100);
	 * table.endTr();
	 * 
	 * table.addTd(new Array(1, 2, 3, 4, 5));
	 * table.addTd(new Array(1, 2, 3, 4, 5));
	 * table.addTd(new Array(1, 2, 3, 4, 5));
	 * table.addTd(new Array(1, 2, 3, 4, 5));
	 * table.addTd(new Array(1, 2, 3, 4, new D5Button(new TB0_LEFT(0, 0), 1, 0, 1)),true);
	 * 
	 * addChild(table);
	 * </listing>
	 */
	public class D5Table extends D5Component
	{
		/**
		 * 文本事件
		 */ 
		public var textEventListener:Function;
		
		public static const TYPEID:uint = 5;

		/**
		 * TR右侧素材（一般通过左侧翻转得来）
		 */
		public var tr_right:BitmapData;
		/**
		 * TR的X位置记录，每增加一个TR，此位置均会向右移动TR的宽度-1象素的距离，同时也是表格的宽度
		 */
		public var tr_x:uint = 0;
		/**
		 * TR的文字描边颜色
		 */
		public var tr_borderColor:uint = 0x3D1300;
		/**
		 * TR的文字颜色
		 */
		public var tr_fontColor:uint = 0xFFDA93;
		/**
		 * TR的文字大小
		 */
		public var tr_fontSize:uint = 12;
		/**
		 * TR的文字格式
		 */
		public var tr_format:TextFormat;
		/**
		 * TR的描边滤镜
		 */
		private var tr_filter:GlowFilter;
		/**
		 * TR是否添加完毕
		 */
		private var tr_isend:Boolean = false;

		/**
		 * 记录每个TR宽度的数组
		 */
		public var tr_arr:Array;
		
		/**
		 * TD内容箱
		 */
		public var td_box:Sprite;
		public var td_bg:uint;
		
		/**
		 * TD的第一线颜色
		 */
		public var td_line:int = 0x190B0C;
		/**
		 * TD的第二线颜色
		 */
		public var td_line0:int = 0x937C66;
		
		/**
		 * 每行TD是否自动划线
		 */
		public var hasTDLine:Boolean = true;
		
		/**
		 * TD的高度
		 */
		public var td_height:uint = 25;
		/**
		 * TD的字体样式
		 */
		public var td_format:TextFormat;
		
		/**
		 * 表格TD部分的高度
		 */
		private var tableHeight:uint = 0;
		
		/**
		 * 表格的实际宽度（除去滚动条）
		 */
		private var tableWidth:uint = 0;
		
		/**
		 * 外框颜色
		 */
		public var maxBorder:uint = 0x3E1A00;
		
		/**
		 * 是否有滚动条
		 */
		public var hasScoll:Boolean;
		
		/**
		 * 是否有大外框
		 */
		public var hasMaxborder:Boolean;
		
		/**
		 * 最大显示行数，如果没有滚动条且内容超过最大行数，则超出的部分不会被显示
		 */
		public var maxLine:uint;
		
		/**
		 * 是否自动填充（当表格输入结束后自动补到maxLine行）
		 */
		public var AutoFill:Boolean = true;
		
		/**
		 * 已经用过的行数
		 */
		public var usedLine:uint = 0;
		/**
		 * 鼠标指在文本上事件
		 */
		public var onMouseOverItem:Function;
		/**
		 * 鼠标离开文本事件
		 */
		public var onMouseOutItem:Function;
		private var mainBG:Shape;
		
		private var trLineUsed:uint = 0;
		
		private var _trTemp:Vector.<Sprite>;
		
		public var scrollBarWidth:uint = 20;
		
		private var _callback:Function;
		
		private var _value:Array = new Array();
		
		public static function makeResource(b:BitmapData,leftsize:uint,bgsize:uint):Vector.<BitmapData>
		{
			var res:Vector.<BitmapData> = new Vector.<BitmapData>;
			
			var part1:BitmapData;
			var part2:BitmapData;
			var part3:BitmapData;
			
			part1 = new BitmapData(leftsize,b.height,true,0x00000000);
			part2 = new BitmapData(bgsize,b.height,true,0x00000000);
			part3 = new BitmapData(b.width-bgsize-leftsize,b.height,true,0x00000000);
			
			part1.copyPixels(b,new Rectangle(0,0,part1.width,part1.height),new Point(),null,null,true);
			part2.copyPixels(b,new Rectangle(part1.width,0,part2.width,part2.height),new Point(),null,null,true);
			part3.copyPixels(b,new Rectangle(b.width-part3.width,0,part3.width,part3.height),new Point(),null,null,true);
			
			res.push(part1);
			res.push(part2);
			res.push(part3);
			
			return res;
		}
		
		private static const lightFilter:ColorMatrixFilter = new ColorMatrixFilter([
			1,0,0,0,30,
			0,1,0,0,30,
			0,0,1,0,30,
			0,0,0,1,0
		]); 
		
		/**
		 * 
		 * @param	res			素材资源，若有2个元素，则每个tr单元都有开头和结尾，如果有三个元素，则整行tr单元使用一个开头和结尾
		 * @param	MaxBorder	是否有大边框
		 * @param	autoFill	是否自动填充（当表格输入结束后自动补到maxLine行）
		 */
		public function D5Table(res:Vector.<BitmapData> ,MaxBorder:Boolean=true,_autoFill:Boolean = true) 
		{
			_resource = res;
			
			if(_resource.length==2)
			{
			
				tr_right = new BitmapData(_resource[0].width, _resource[0].height,true,0x00000000);
			
				var turnM:Matrix = new Matrix(-1,0,0,1,_resource[0].width);
				tr_right.draw(_resource[0], turnM);
			}
			
			hasMaxborder = MaxBorder;
			AutoFill = _autoFill;
			maxLine = 5;
			
			tr_arr = new Array();
			
			mainBG = new Shape();
			addChild(mainBG);
		}
		
		/**
		 * 设置背景
		 */ 
		public function setBackground(color:uint, alpha:Number):void
		{
			mainBG.y = _resource[1].height;
			mainBG.graphics.beginFill(color, alpha);
			mainBG.graphics.drawRect(0, 0, tableWidth, maxLine*td_height);
		}
		
		/**
		 * 创建表格标题头
		 * @param	lable	标题头标签
		 * @param	trwidth	标题头的宽度
		 */
		public function addTr(lable:String,trwidth:uint,isHidden:Boolean=false):void
		{
			if(!isHidden)
			{
				if(_trTemp == null) _trTemp = new Vector.<Sprite>;
				var sprite:Sprite = new Sprite();
				sprite.x = tr_x;
				_trTemp.push(sprite);
				if(_resource.length==2)
				{
					// 创建背景层
					var spritebg:Shape = new Shape();
					spritebg.name = 'background';
					spritebg.graphics.beginBitmapFill(_resource[1]);
					spritebg.graphics.drawRect(0, 0, trwidth, _resource[1].height);
					sprite.addChild(spritebg);
					
					// 创建左边
					var lb:Bitmap = new Bitmap(_resource[0]);
					lb.name = 'lb';
					// 创建右边
					var rb:Bitmap = new Bitmap(tr_right);
					rb.name = 'rb';
					
					
					sprite.addChild(lb);
					sprite.addChild(rb);
					rb.x = sprite.width - rb.width;
				}
				
				if (lable != '')
				{
					// 增加标签文字
					var lab:TextField = new TextField();
					lab.height = 18;
					lab.text = lable;
					lab.width = trwidth;
					setTrFormat(lab);
					sprite.addChild(lab);
				}
			}
			
			tr_arr.push(trwidth);
			
			tr_x += trwidth;
		}
		
		/**
		 * 结束标题头的创建。只有执行了本操作，才能向表格中添加内容
		 * @param	trWidth	tr宽度数组，若不设置则默认为tr自动生成的宽度
		 */
		public function endTr():void
		{
			if (tr_isend) return;

			tr_isend = true;
			tableWidth = tr_x;
			
			if(_trTemp!=null)
			{
				var head:Sprite = new Sprite();
				
				
				if(_resource.length==3)
				{
					var left:Bitmap = new Bitmap(_resource[0]);
					var right:Bitmap = new Bitmap(_resource[2]);
					
					head.graphics.beginBitmapFill(_resource[1]);
					head.graphics.drawRect(left.width,0,width-right.width-left.width,_resource[1].height);
					right.x = width-right.width;
					head.addChild(left);
					head.addChild(right);
				}
				
				for each(var spr:Sprite in _trTemp)
				{
					head.addChild(spr);
				}
				
				var bitmap:BitmapData = new BitmapData(head.width,head.height,true,0x00000000);
				bitmap.draw(head);
				
				_trTemp.splice(0,_trTemp.length);
				_trTemp = null;
				
				head = null;
				
				graphics.beginBitmapFill(bitmap);
				graphics.drawRect(0,0,bitmap.width,bitmap.height);
			}
		}
		
		public function drawTRLine(h:uint, color:uint, padding:uint=2, _alpha:Number=1):void
		{
			if (!tr_isend)
			{
				trace('Please End Tr Building first!');
				return;
			}
			var line:Shape = new Shape();
			line.graphics.beginFill(color, _alpha);
			line.graphics.drawRect(0, 0, tableWidth, h);
			line.graphics.endFill();
			if (td_box == null)
			{
				line.y = trLineUsed + padding + _resource[0].height;
			}else{
				line.y = td_box.numChildren * td_height + trLineUsed + padding + _resource[0].height;
			}
			addChild(line);
			trLineUsed += h + padding;
		}
		
		/**
		 * 向表格中添加内容
		 * @param	data	与表格标题头总数相符的数据数组
		 * @param	islast	是否最后一行数据，如果是的话，则不绘制底线
		 * @param	vcenter	是否垂直居中
		 * @param	callback 鼠标点击该行 返回函数
		 * @oaram	value	标记
		 */
		public function addTd(data:Array=null,islast:Boolean=false,vcenter:Boolean = true,fontcolor:uint = 0xFFCC66,callback:Function=null,value:*=null,isAutoGrow:Boolean=false,n:uint=0):*
		{
			if(callback != null) _callback = callback;
			if(value != null) _value.push(value);
			if (td_box == null)
			{
				td_box = new Sprite();
				td_box.name = String(value);
				td_box.y = _resource[0].height;
			}
			if (!tr_isend)
			{
				trace('Please End Tr Building first!');
				return;
			}
			
			if (!hasScoll && td_box.numChildren >= maxLine)
			{
				maxLine++;
			}
			
			addChild(td_box);
			
			var sprite:Sprite = new Sprite();
			sprite.name = 'tableBody';
			sprite.tabIndex = value;//无效属性
			sprite.addEventListener(MouseEvent.CLICK, changeTopDepthHandle);
			sprite.addEventListener(MouseEvent.MOUSE_OVER, changeFiltes);
			sprite.addEventListener(MouseEvent.MOUSE_OUT, resetFiltes);
			sprite.name=n.toString();
			var flyx:uint=0;
			for (var k:String in tr_arr)
			{
				if (!islast && hasTDLine)
				{
					if(td_line!=-1)
					{
						// 绘制第一线
						sprite.graphics.moveTo(flyx, td_height - 1);
						sprite.graphics.lineStyle(1, td_line);
						sprite.graphics.lineTo(flyx + tr_arr[k], td_height - 1);
					}
					if(td_line0!=-1)
					{
						// 绘制第二线
						sprite.graphics.moveTo(flyx, td_height);
						sprite.graphics.lineStyle(1, td_line0);
						sprite.graphics.lineTo(flyx + tr_arr[k], td_height);
					}
				}
				
				if (data!=null && data[k]!=null && data[k]!=undefined)
				{				
					// 显示内容
					try
					{
						if (data[k].toString().substr(0, 7) == '[object')
						{
							var middlex:int = int(tr_arr[k] - data[k].width)/2;
							if (middlex < 0) middlex = 0;	// 横向只向右隐藏
							data[k].x = flyx+middlex;
							data[k].y = vcenter ? (td_height>data[k].height ? int((td_height - data[k].height)*.5)+1 : 3) : 0;
							sprite.addChild(data[k]);
						}else {
							var content:D5TLFText = new D5TLFText('',fontcolor);
							content.width = tr_arr[k];
							content.height = 18;
							content.htmlText = data[k];
							content.align=0;
							if(isAutoGrow) content.autoGrow();
							content.x = flyx;
							content.y = (td_height - content.textHeight)*.5;
							if(textEventListener!=null) content.addEventListener(TextEvent.LINK,textEventListener);
							setTdFormat(content);
							sprite.addChild(content);
						}
					}catch(e:Error){}
				}
				
				flyx += tr_arr[k] - 1;
			}
			sprite.y = td_box.numChildren * td_height+trLineUsed;
			td_box.addChild(sprite);
			tableHeight += td_height;
			usedLine++;
			
			return sprite;
		}
		
		/**
		 * 设置Td背景
		 */
		public function set Tdbg(res:Vector.<BitmapData>):void
		{
			var bg:Sprite = new Sprite();
			bg.graphics.beginBitmapFill(res[0]);
			bg.graphics.drawRect(0,0,res[0].width,res[0].height);
			bg.graphics.endFill();
			td_box.addChildAt(bg,0);
		}
		
		/**
		 * 结束表格内容的输入，格式化表格。滚动条，外框等将会根据外部设置在此生成
		 * @param	width
		 * @param	height
		 */
		public function formatTable(width:uint=0,height:uint=0):void
		{
			if (!tr_isend)
			{
				trace('Please End Tr Building first!');
				return;
			}
			
			if (AutoFill)
			{
				for (var i:uint = usedLine; i < maxLine; i++ ) addTd();
			}
			
			if (hasMaxborder)
			{
				var maxheight:uint = td_box.numChildren>maxLine ? maxLine * td_height : tableHeight;
				// 绘制外框
				var border:Sprite = new Sprite();
				border.graphics.lineStyle(2, maxBorder);
				border.graphics.moveTo(1,0)
				border.graphics.lineTo(tr_x, 0);
				border.graphics.lineTo(tr_x, maxheight);
				border.graphics.lineTo(1, maxheight);
				border.graphics.lineTo(1, 0);
				border.y = td_box.y + 1;
				border.name = "border";
				addChild(border);
			}

		}

		/**
		 * 表格的总宽度
		 */
		override public function get width():Number
		{
			return tr_x;
		}
	
		/**
		 * 表格的总高度
		 */
		override public function get height():Number
		{
			return (td_height*maxLine + _resource[0].height+trLineUsed);
		}
		
		/**
		 * 格式化标题头的文字格式
		 * @param	lab
		 * @param	align
		 */
		private function setTrFormat(lab:TextField,align:String = TextFormatAlign.CENTER):void
		{
			if (tr_format == null)
			{
				tr_format = new TextFormat();
				tr_format.font = 'Verdana';
				tr_format.align = align;
				tr_format.size = tr_fontSize;
				tr_format.color = tr_fontColor;
			}
			
			if (tr_filter == null)
			{
				tr_filter = new GlowFilter(tr_borderColor, 1, 2, 2, 1000);
			}
			
			lab.filters = new Array(tr_filter);
			lab.setTextFormat(tr_format);
			lab.selectable = false;
			lab.y = 2;
		}
		
		/**
		 * 格式化表格内容的文字格式
		 * @param	lab
		 * @param	align
		 */
		private function setTdFormat(lab:D5TLFText):void
		{
			lab.align = D5TLFText.CENTER;
			lab.selectable = false;
		}
		
		/**
		 * 清空所有TD内容，重新输入表格
		 */
		public function resetTable():void
		{
			if (tableHeight == 0) return;
			
			if(textEventListener!=null)
			{
				var sprite:Sprite = td_box.getChildByName('tableBody') as Sprite;
				if(sprite!=null)
				{
					for(var i:uint = 0;i<sprite.numChildren;i++)
					{
						var target:TextField = sprite.getChildAt(i) as TextField;
						if(target==null) continue;
						target.removeEventListener(TextEvent.LINK,textEventListener);
					}
				}
			}
			
			while(td_box.numChildren) td_box.removeChildAt(0);
			removeChild(td_box);
			td_box = null;
			
			var border:* = getChildByName('border');
			if(border!=null)
			{
				border.clear();
				removeChild(border);
			}
			
			tableHeight = 0;
			usedLine = 0;
		}
		
		/**
		 * 当鼠标经过时，把当前TD设置为最高层
		 * @param	e
		 */
		private function changeTopDepthHandle(e:MouseEvent):void
		{
			var target:Sprite = e.currentTarget as Sprite;
			try
			{
				td_box.setChildIndex(target, td_box.numChildren - 1);
			}catch (e:Error) { };
			
			if(_callback != null && _value != null) _callback(target.tabIndex);
		}
		
		/**
		 * 当鼠标经过时，当前目标高亮显示
		 */
		private function changeFiltes(e:MouseEvent):void
		{
			var target:Sprite = e.currentTarget as Sprite;
			target.filters = new Array(lightFilter);
			if(onMouseOverItem!=null) onMouseOverItem(e);
		}
		
		/**
		 * 当鼠标移开时，高亮消失
		 */
		private function resetFiltes(e:MouseEvent):void
		{
			var target:Sprite = e.currentTarget as Sprite;
			target.filters = new Array();
			if(onMouseOutItem!=null) onMouseOutItem();
		}
		
		public function clear():void
		{
			
		}

		
	}
	
}
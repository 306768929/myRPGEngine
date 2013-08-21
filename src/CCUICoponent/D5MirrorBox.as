package CCUICoponent
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * 提供素材自动反转支持的容器盒子
	 */ 
	public class D5MirrorBox extends D5Component
	{
		public static const TYPEID:uint = 2;
		protected const Corner:uint = 0;
		protected const Top:uint = 1;
		protected const Left:uint = 2;
		protected const Bg:uint = 3;
		
		/**
		 * 左上角
		 */ 
		protected var _corner_0:Sprite;
		/**
		 * 右下角
		 */ 
		protected var _corner_1:Sprite;
		/**
		 * 右下角
		 */ 
		protected var _corner_2:Sprite;
		/**
		 * 左下角
		 */ 
		protected var _corner_3:Sprite;
		
		/**
		 * 背景
		 */ 
		protected var _bg:Sprite;
		
		/**
		 * 上边条
		 */ 
		protected var _border_0:Sprite;
		/**
		 * 右边条
		 */ 
		protected var _border_1:Sprite;
		/**
		 * 下边条
		 */ 
		protected var _border_2:Sprite;
		/**
		 * 左边条
		 */ 
		protected var _border_3:Sprite;
		
		/**
		 * 水印
		 */ 
		protected var _mask:Sprite;
		
		protected var _drawW:uint;
		
		protected var _drawH:uint;
		
		/**
		 * 内容的起始坐标X
		 */ 
		protected var _contentX:uint;
		/**
		 * 内容的其实坐标Y
		 */ 
		protected var _contentY:uint;
		
		
		public static function makeResource(b:BitmapData,rectCorner:Rectangle,rectTop:Rectangle,rectLeft:Rectangle,rectBg:Rectangle):Vector.<BitmapData>
		{
			
			var res:Vector.<BitmapData> = new Vector.<BitmapData>;
			
			var part1:BitmapData = new BitmapData(rectCorner.width,rectCorner.height,true,0x00000000);
			var part2:BitmapData = new BitmapData(rectTop.width,rectTop.height,true,0x00000000);
			var part3:BitmapData = new BitmapData(rectLeft.width,rectLeft.height,true,0x00000000);
			var part4:BitmapData = new BitmapData(rectBg.width,rectBg.height,true,0x00000000);
			
			part1.copyPixels(b,rectCorner,new Point(),null,null,true);
			part2.copyPixels(b,rectTop,new Point(),null,null,true);
			part3.copyPixels(b,rectLeft,new Point(),null,null,true);
			part4.copyPixels(b,rectBg,new Point(),null,null,true);

			res.push(part1);
			res.push(part2);
			res.push(part3);
			res.push(part4);
			
			return res;
			
		}
		/**
		 * 
		 * @param	resource		源素材
		 * @param	w				宽度
		 * @param	h				高度
		 */ 
		public function D5MirrorBox(resource:Vector.<BitmapData>,w:uint,h:uint)
		{
			_drawW = w;
			_drawH = h;
			_contentX = resource[Corner].width;
			_contentY = resource[Corner].height;
			mouseEnabled=false;
			super(resource);
		}
		
		public function get contentX():uint
		{
			return _contentX;
		}
		
		public function get contentY():uint
		{
			return _contentY;
		}
		
		/**
		 * 重置窗口大小
		 */ 
		public function resize(w:uint,h:uint):void
		{
			_drawW = w;
			_drawH = h;
			
			setup();
		}
		
		/**
		 * 设置容器水印
		 */ 
		public function setMask(b:BitmapData,alpha:Number=1.0,m:Matrix=null):void
		{
			if(_mask!=null)
			{
				_mask.graphics.clear();
			}else{
				_mask = new Sprite();
			}
			
			_mask.graphics.beginBitmapFill(b,m,false);
			_mask.alpha = 1.0;
			
			
		}
		
		override protected function setup():void
		{
			if(_corner_0==null)
			{
				_corner_0 = new Sprite();
				_corner_1 = new Sprite();
				_corner_2 = new Sprite();
				_corner_3 = new Sprite();
				_bg = new Sprite();
				_border_0 = new Sprite();
				_border_1 = new Sprite();
				_border_2 = new Sprite();
				_border_3 = new Sprite();
			}else{
				_corner_0.graphics.clear();
				_corner_1.graphics.clear();
				_corner_2.graphics.clear();
				_corner_3.graphics.clear();
				_bg.graphics.clear();
				_border_0.graphics.clear();
				_border_1.graphics.clear();
				_border_2.graphics.clear();
				_border_3.graphics.clear();
			}
			
			var Width:int = _drawW-_resource[Corner].width*2;
			var Height:int = _drawH-_resource[Corner].height*2;
			
			Width = Width <0 ? 0 : Width;
			Height = Height < 0 ? 0 : Height;
			
			_corner_0.graphics.beginBitmapFill(_resource[Corner],null,false);
			_corner_0.graphics.drawRect(0,0,_resource[Corner].width,_resource[Corner].height);
			
			_corner_1.graphics.beginBitmapFill(_resource[Corner],new Matrix(-1,0,0,1,_resource[Corner].width),false);
			_corner_1.graphics.drawRect(0,0,_resource[Corner].width,_resource[Corner].height);
			
			_corner_2.graphics.beginBitmapFill(_resource[Corner],new Matrix(-1,0,0,-1,_resource[Corner].width,_resource[Corner].height),false);
			_corner_2.graphics.drawRect(0,0,_resource[Corner].width,_resource[Corner].height);
			
			_corner_3.graphics.beginBitmapFill(_resource[Corner],new Matrix(1,0,0,-1,0,_resource[Corner].height),false);
			_corner_3.graphics.drawRect(0,0,_resource[Corner].width,_resource[Corner].height);
			
			_bg.graphics.beginBitmapFill(_resource[Bg]);
			_bg.graphics.drawRect(0,0,Width,Height);
			
			_border_0.graphics.beginBitmapFill(_resource[Top]);
			_border_0.graphics.drawRect(0,0,Width,_resource[Top].height);
			
			_border_1.graphics.beginBitmapFill(_resource[Left],new Matrix(-1,0,0,1,_resource[Left].width));
			_border_1.graphics.drawRect(0,0,_resource[Left].width,Height);
			
			_border_2.graphics.beginBitmapFill(_resource[Top],new Matrix(1,0,0,-1,0,_resource[Top].height));
			_border_2.graphics.drawRect(0,0,Width,_resource[Top].height);
			
			_border_3.graphics.beginBitmapFill(_resource[Left]);
			_border_3.graphics.drawRect(0,0,_resource[Left].width,Height);
			
			
			_corner_1.x = _drawW-_corner_1.width;
			_corner_2.x = _corner_1.x;
			_corner_2.y = _drawH-_corner_2.height;
			_corner_3.y = _corner_2.y;
			
			_bg.x = _corner_0.width;
			_bg.y = _corner_0.height;
			
			_border_0.x = _bg.x;
			_border_1.x = _drawW - _border_1.width;
			_border_1.y = _corner_1.height;
			_border_2.x = _border_0.x;
			_border_2.y = _drawH - _border_2.height;
			_border_3.y = _border_1.y;
			
			var addList:Vector.<DisplayObject> = new Vector.<DisplayObject>;
			for(var i:uint=0;i<numChildren;i++)
			{
				addList.push(getChildAt(i));
			}
			
			addChild(_bg);
			
			addChild(_border_0);
			addChild(_border_1);
			addChild(_border_2);
			addChild(_border_3);
			
			addChild(_corner_0);
			addChild(_corner_1);
			addChild(_corner_2);
			addChild(_corner_3);
			
			for each(var obj:DisplayObject in addList) addChild(obj);
			
			super.setup();
		}
	}
}
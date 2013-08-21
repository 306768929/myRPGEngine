package com._486G.ui
{
	
	import CCUICoponent.D5IVfaceButton;
	import CCUICoponent.D5MirrorBox;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	internal class XWindowBackground extends Sprite
	{
		private static var res:Vector.<BitmapData>;
		private static var isloading:Boolean;
		private static var isloaded:Boolean;
		private static var winList:Vector.<XWindowBackground>=new Vector.<XWindowBackground>;
		
		internal var target:*;
		public var _closeBtn:D5IVfaceButton;
		public var _helpBtn:D5IVfaceButton;
		
		internal var _width:uint;
		internal var _height:uint;
		
		private var _lt:Bitmap;
		private var _rt:Bitmap;
		private var _lb:Bitmap;
		private var _rb:Bitmap;
		
		private var _tloop:Shape;
		private var _lloop:Shape;
		private var _bloop:Shape;
		private var _rloop:Shape;
		private var _cloop:Shape;
		private var _hole:D5MirrorBox;
		
		private var _title:D5TLFText;
		
		private var isfirst:Boolean;
		
		/**
		 * XWindow获取一个新的窗口实例
		 * @param		w	窗口宽度
		 * @param		h	窗口高度
		 */ 
		internal static function getBackground(w:uint,h:uint,tar:XWindow):XWindowBackground
		{
			
			var winbg:XWindowBackground;
			
			winbg = winList.length==0 ? new XWindowBackground('&*(&lkjsdf7889lkjoiuwerf(*&%^%$') : winbg = winList.shift();			
			
			winbg.target = tar;
			tar._background = winbg;
			
			winbg.setSize(w,h);
			return winbg;
		}
		
		public function XWindowBackground(code:String='')
		{
			if(code!="&*(&lkjsdf7889lkjoiuwerf(*&%^%$") error();
			
			super();
			
			mouseChildren = false;
			mouseEnabled = false;
			
			if(!isloading)
			{
				isloading = true;
				SanguoGlobal.loadResource2Pool('assets/ui/newui/win_bg.png','newui/win_bg',resLoaded);
				
			}
		}
		
		/**
		 * 在背景上打出透明的窟窿
		 * @param		px	想打洞的起始位置X
		 * @param		py	想打洞的起始位置Y
		 * @param		w	打洞的宽度
		 * @param		h	打洞的高度
		 */ 
		internal function buildHole(px:uint=0,py:uint=0,w:uint=0,h:uint=0,showBroad:Boolean=false):void
		{
			_cloop.graphics.clear();
			_cloop.graphics.beginBitmapFill(res[5]);
			_cloop.graphics.drawRect(0,0,_width-res[2].width*2,_lloop.height);
			
			
			if(w!=0 && h!=0)
			{
				_cloop.graphics.drawRect(px,py,w,h);
				if(showBroad)
				{
					_hole ? _hole.resize(w+10,h+10) : (_hole = new D5MirrorBox(SanguoGlobal.resourcePool.getResource('newui/Pwind'),w+10,h+10));
					_hole.x = _cloop.x+px-5;
					_hole.y = _cloop.y+py-5;
					addChild(_hole);
				}else{
					_hole ? removeChild(_hole) : null;
				}
			}

			_cloop.graphics.endFill();
		}
		
		internal function setSize(w:uint,h:uint,isAdd:Boolean=true):void
		{
			_width = w;
			_height = h;

			if(!isloaded)
			{
				// 资源尚未加载完，开始等待
				addEventListener(Event.ENTER_FRAME,onEnterWait);
			}else{
				drawFace(isAdd);
			
			}
		}
		
		
		internal function set title(s:String):void
		{
			if(_title) _title.htmlText = s;
		}
		
		/**
		 * 释放资源
		 */ 
		internal function realse():void
		{
			if(parent!=null) parent.removeChild(this);
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME,onEnterWait);
			target = null;
			if(_title!=null) _title.text = '';
			isfirst = false;
				
			// 推入资源池待用
			if(winList!=null&&winList.indexOf(this)==-1) winList.push(this);
		}
		
		private function onEnterWait(e:Event):void
		{
			if(res!=null && _closeBtn!=null)
			{
				removeEventListener(Event.ENTER_FRAME,onEnterWait);
				drawFace();
			}
		}
		
		private function error():void
		{
			throw new Error("[XWindowBackground] 请使用getBackground静态方法获取本类的实例。");
		}
		
		private function resLoaded():void
		{
			var bd:BitmapData = SanguoGlobal.resourcePool.getResource('newui/win_bg');
			
			var rect:Rectangle = new Rectangle();
			var point:Point = new Point();
			
			var lt:BitmapData = new BitmapData(100,40,true,0);
			rect.x = 0;
			rect.y = 0;
			rect.width = lt.width;
			rect.height = lt.height;
			lt.copyPixels(bd,rect,point,null,null,true);
			
			var tloop:BitmapData = new BitmapData(179,40,true,0);
			rect.x = 100;
			rect.y = 0;
			rect.width = tloop.width;
			rect.height = tloop.height;
			tloop.copyPixels(bd,rect,point,null,null,true);
			
			var mloop:BitmapData = new BitmapData(5,160,true,0);
			rect.x = 0;
			rect.y = 40;
			rect.width = mloop.width;
			rect.height = mloop.height;
			mloop.copyPixels(bd,rect,point,null,null,true);
			
			var lb:BitmapData = new BitmapData(5,7,true,0);
			rect.x = 0;
			rect.y = 238;
			rect.width = lb.width;
			rect.height = lb.height;
			lb.copyPixels(bd,rect,point,null,null,true);
			
			var bloop:BitmapData = new BitmapData(5,10,true,0);
			rect.x = 5;
			rect.y = 238;
			rect.width = bloop.width;
			rect.height = bloop.height;
			bloop.copyPixels(bd,rect,point,null,null,true);
			
			var bgloop:BitmapData = new BitmapData(179,160,true,0);
			rect.x = 100;
			rect.y = 60;
			rect.width = bgloop.width;
			rect.height = bgloop.height;
			bgloop.copyPixels(bd,rect,point,null,null,true);
			
			res = new Vector.<BitmapData>(6);
			res[0] = lt;
			res[1] = tloop;
			res[2] = mloop;
			res[3] = lb;
			res[4] = bloop;
			res[5] = bgloop;
			
			SanguoGlobal.loadResource2Pool('assets/ui/newui/win_bt_help.png','newui/win_bt_help',step1,D5IVfaceButton.TYPEID);
		}
		
		private function step1():void
		{
			SanguoGlobal.loadResource2Pool('assets/ui/newui/win_bt_close.png','newui/win_bt_close',step2,D5IVfaceButton.TYPEID);
		}
		
		private function step2():void
		{
			SanguoGlobal.loadResource2Pool('assets/ui/newui/Pwind.png','newui/Pwind',drawFace,D5MirrorBox.TYPEID);
			isloaded=true;
		}
		
		/**
		 * 所有资源加载完成后，才会调用本方法
		 * 在本方法执行完成后，会自动通知XWindow进行addChildren(isadd=true)
		 */ 
		protected function drawFace(isAdd:Boolean=true):void
		{
			if(isfirst&&isAdd) return;
			isfirst = true;
			
			graphics.clear();
			
			cacheAsBitmap = false;
			
			if(!_lt)
			{
				_closeBtn  = new D5IVfaceButton(SanguoGlobal.resourcePool.getResource('newui/win_bt_close'),target.onClose);
				_helpBtn = new D5IVfaceButton(SanguoGlobal.resourcePool.getResource('newui/win_bt_help'),target.onHelp);
				
				_title = new D5TLFText('',0xd7e9ef);
				_title.fontBorder = 0x131b1f;
				_title.width = 150;
				_title.height = 20;
				_title.align = D5TLFText.CENTER;
				_title.fontSize = 14;
				
				_lt = new Bitmap(res[0]);
				_rt = new Bitmap(res[0]);
				_rb = new Bitmap(res[3]);
				_lb = new Bitmap(res[3]);
				
				_lloop = new Shape();
				_rloop = new Shape();
				_tloop = new Shape();
				_bloop = new Shape();
				_cloop = new Shape();
				
				_rt.scaleX = -1;
				_rb.scaleX = -1;
				
				addChild(_lt);
				addChild(_rt);
				addChild(_rb);
				addChild(_lb);
				
				addChild(_lloop);
				addChild(_rloop);
				addChild(_tloop);
				addChild(_bloop);
				addChild(_cloop);
				
				addChild(_title);
			}
			
			
			_tloop.graphics.clear();
			_tloop.graphics.beginBitmapFill(res[1]);
			_tloop.graphics.drawRect(0,0,_width-_lt.width*2,_lt.height);
			_tloop.graphics.endFill();

			_bloop.graphics.clear();
			_bloop.graphics.beginBitmapFill(res[4]);
			_bloop.graphics.drawRect(0,0,_width-_lb.width*2,_lb.height);
			_bloop.graphics.endFill();
			
			_lloop.graphics.clear();
			_lloop.graphics.beginBitmapFill(res[2]);
			_lloop.graphics.drawRect(0,0,res[2].width,_height-_lt.height-_lb.height);
			_lloop.graphics.endFill();
			
			_rloop.graphics.clear();
			_rloop.graphics.beginBitmapFill(res[2]);
			_rloop.graphics.drawRect(0,0,res[2].width,_lloop.height);
			_rloop.graphics.endFill();
			_rloop.scaleX = -1;
			
			if(isAdd) buildHole(0,0);
			
			_rt.x = _rb.x = _width;
			_lb.y = _rb.y = _height-_lb.height
			
			_cloop.x = res[2].width;
			_cloop.y = _lt.height;
			
			_tloop.x = _lt.width;
			
			_bloop.x = _lb.width;
			_bloop.y = _lb.y;
			
			_lloop.y = _lt.height;
			
			_rloop.y = _lloop.y;
			_rloop.x = _width;
			
			_title.x = int((_width-_title.width)*.5);
			_title.y = 18;
				
			cacheAsBitmap = true;
			
			_helpBtn.x = _width - 56;
			_closeBtn.x = _helpBtn.width+_helpBtn.x;
			_helpBtn.y = _closeBtn.y = 18;
			
			if(isAdd)
			{
				_closeBtn.callback = target.onClose;
				_helpBtn.callback = target.onHelp;
				
				target.addChildren();
			}
			
		}
	}
}
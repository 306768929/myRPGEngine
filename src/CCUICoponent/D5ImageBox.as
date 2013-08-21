package CCUICoponent
{
	import com.D5Power.display.D5TextField;
	import com.RY.Objects.IShoot;
	import com.utils.debug.Debug;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterType;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	/**
	 * 用于显示图片单元且带数量显示的单元
	 * 例如：背包中的单个物品单元
	 */ 
	public class D5ImageBox extends D5Component
	{
		/**
		 * 可携带的数据
		 */ 
		public var $data:*;
		/**
		 * 宽度
		 */ 
		protected var _w:uint;
		/**
		 * 高度
		 */ 
		protected var _h:uint;
		/**
		 * 点击响应函数
		 */ 
		protected var _onClick:Function;

		/**
		 * 高亮框
		 */ 
		protected var _heightLight:Sprite;
		
		/**
		 * 图像数据
		 */ 	
		protected var bitmapData:BitmapData;
		
		/**
		 * 间距
		 */ 
		protected var _padding:uint=2;
		
		/**
		 * 是否显示数量
		 */ 
		protected var _showNum:Boolean=false;
		
		/**
		 * 数量显示器
		 */ 
		protected var numShower:D5TLFText;
		
		/**
		 * 背景
		 */ 
		protected var _background:D5MirrorBox;
		
		/**
		 * 是否添加滤镜
		 */
		private var _isShowMask:Boolean;
		
		/**
		 * 物品数量
		 */ 
		protected var _itemNum:uint;
		
		protected var _isAlpha:Boolean;
		
		protected var _url:String='';
		protected var _cnt:uint=0;
		
		/**
		 * 测试用URL
		 */ 
		protected var _demourl:String='';
		
		protected var _b:Bitmap;
		/**
		 *这里 callback是点击事件
		 * @param callback
		 * @param width
		 * @param height
		 * @param isAlpha
		 * 
		 */		
		public function D5ImageBox(onClick:Function=null,width:uint = 60,height:uint = 60,isAlpha:Boolean=false)
		{
			_isAlpha=isAlpha;
			_w = width;
			_h = height;
			_onClick = onClick;
			_heightLight = new Sprite();
			_b = new Bitmap();
			
			addChild(_b);
			mouseChildren=false;
		}
		
		public function clearLogo():void
		{
			var b:DisplayObject = getChildByName('npclogo');
			if(b!=null)
			{
				removeChild(b);
			}
		}
		public function set numTxt(str:String):void
		{
			numShower.text=str;
		}
		public function set padding(v:uint):void
		{
			_padding = v;
		}
		
		public function set background(res:Vector.<BitmapData>):void
		{
			_resource = res;
			setup();
		}

		override protected function setup():void
		{
			if(_background!=null && contains(_background)) removeChild(_background);
			
			if(_resource==null) return;
			_background = new D5MirrorBox(_resource,_w,_h)
			addChild(_background);
			
			if(_b!=null)
			{
				setChildIndex(_background,0);
				setChildIndex(_b,1);
			}
		}
		
		/**
		 * 设置物品图像数据
		 */ 
		public function set logoData(b:BitmapData):void
		{
			if(_w==0 || _h==0)
			{
				trace("[D5ImageBox:非法的宽度和高度]",_demourl);
				return;
			}
			if(bitmapData==null)
			{
				bitmapData = new BitmapData(_w-_padding*2,_h-_padding*2,_isAlpha,0);
			}else{
				bitmapData.fillRect(bitmapData.rect,0);
			}
			
			if(b!=null)
			{
				bitmapData.draw(b,new Matrix(bitmapData.width/b.width,0,0,bitmapData.height/b.height),null,null,null,true);
				build();
			}
			
		}
		
		public function get logoData():BitmapData
		{
			return bitmapData;
		}
		
		public function get absWidth():uint
		{
			return _w;
		}
		
		public function get absHeight():uint
		{
			return _h;
		}
		
		override public function get width():Number
		{
			return super.width==0 ? _w : super.width;
		}
		
		override public function get height():Number
		{
			return super.height==0 ? _h : super.height;
		}
		
		public function get selected():Boolean
		{
			return _heightLight.visible;
		}
		public function set selected(b:Boolean):void
		{
			if(this == null) return;
			if(!b)
			{
				_heightLight.graphics.clear();
				_heightLight.visible=false;
				this.filters = new Array();
				
			}else{
				_heightLight.graphics.lineStyle(1,0xd5c1a2,.6);
				_heightLight.graphics.drawRect(0,0,_w,_h);
				_heightLight.visible=true;
				this.filters = new Array(new GlowFilter(0xffff99, 1, 3, 3, 1, 1, false, false));
			}
		}
		public function get Overed():Boolean
		{
			return _heightLight.visible;
		}
		public function set Overed(b:Boolean):void
		{
			if(this == null) return;
			if(!b)
			{
				_heightLight.graphics.clear();
				_heightLight.visible=false;
				this.filters = new Array();
				
			}else{
				_heightLight.graphics.lineStyle(1,0x77ffff);
				_heightLight.graphics.drawRect(0,0,_w,_h);
				_heightLight.visible=true;
				this.filters = new Array(new GlowFilter(0x77ffff, 1, 3, 3, 1, 1, false, false));
			}
		}
		public function set showNum(b:Boolean):void
		{
			_showNum = b;
			if(!_showNum && numShower!=null && contains(numShower))
			{
				removeChild(numShower);
				numShower = null;
			}else if(_showNum && numShower==null){
				buildNumShower();
			}
		}
		
		public function set num(v:uint):void
		{
			_itemNum = v;
			if(numShower!=null) numShower.text = v.toString();
			if(!v) isShowMask = true;
			else isShowMask = false;
			
		}
		
		public function get num():uint
		{
			return _itemNum;	
		}
		
		public	 function set isShowMask(v:Boolean):void
		{
			_isShowMask = v;
			if(v) filters = new Array(new ColorMatrixFilter([
				0.3, 0.59, 0.11, 0, 0, 
				0.3, 0.59, 0.11, 0, 0, 
				0.3, 0.59, 0.11, 0, 0, 
				0, 0, 0, 1, 0
			]));
			else filters = new Array();
		}
		
		public function get isShowMask():Boolean
		{
			return _isShowMask;
		}
		
		/**
		 * 设置物品图片
		 */ 
		public function set logo(url:String):void
		{
			//if(url==_url) return;
			
			if(url=="")
			{
				if(_b!=null) _b.bitmapData=null;
			}else{
				_url = url;
				_demourl = url;
				SanguoGlobal.loadResource2Pool(url,url,onComplate);
			}
		}
		
		override public function unsetup():void
		{
			if(_onClick!=null) removeEventListener(MouseEvent.CLICK,_onClick);
			_onClick=null;
			
			bitmapData.dispose();
			bitmapData = null;
		}
		
		protected function onComplate():void
		{
			if(_url==null || _url=='') return;
			
			//以下三行为陈超添加
			var ob:*=SanguoGlobal.resourcePool.getResource(_url);//trace(_url,ob,'imgbox');
			if(ob==undefined&&_cnt++<20){ logo=_url;return;}
			if(ob!=undefined) logoData=ob;
			else logoData = SanguoGlobal.resourcePool.getResource("demo.png");
			_url = '';
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onError(e:IOErrorEvent):void
		{
			var loader:LoaderInfo = e.target as LoaderInfo;
			loader.removeEventListener(Event.COMPLETE,onComplate);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			loader.loader.unload();
			loader = null;
			
			bitmapData = new BitmapData(_w-_padding*2,_h-_padding*2,false,0);
			build();
		}
		
		protected function build():void
		{
			_b.bitmapData = bitmapData;
			_b.x = _padding;
			_b.y = _padding;

			//if(getChildByName('npclogo')!=null) swapChildren(_b,getChildByName('npclogo'));
//			Debug.trace("buildImageClick");
			if(_showNum) buildNumShower();
			addChild(_heightLight);
			if(_onClick!=null) addEventListener(MouseEvent.CLICK,_onClick);
		}
		protected function buildNumShower():void
		{
			if(numShower==null)
			{
				numShower = new D5TLFText('',0xd4cc75);
				numShower.fontBorder = 0x000000;
				numShower.align = D5TLFText.RIGHT;
				numShower.width = 40;
				numShower.height = 20;
			}
			numShower.x = _w - numShower.width;
			numShower.y = _h - numShower.height+2;
			addChild(numShower);
			
		}
		
		
	}
}
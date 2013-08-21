package CCUICoponent
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * 四状态的按钮
	 * @author D5Power
	 */ 
	public class D5IVfaceButton extends D5Component
	{	
		public static const TYPEID:uint = 1;
		
		public var id:uint;
		
		protected var _lable:D5TLFText;
		
		protected var _body:Bitmap;
		
		protected var _callback:Function;
		
		protected var _lableRes:Vector.<BitmapData>;
		
		private var _resname:String;
		
		private var _shrink_interval:int
		
		private var _unable:Boolean;
		/**
		 * 是否禁止闪烁
		 */
		public var _shrink_lock:Boolean;
		/**
		 * 是窗口是否打开状态
		 */
		public var window_open:Boolean;
		/**
		 * 鼠标停止状态
		 */
		protected static const DEFAULT:uint = 0;
		/**
		 * 鼠标经过状态
		 */ 
		protected static const OVER:uint = 1;
		/**
		 * 鼠标点击状态
		 */ 
		protected static const CLICK:uint = 2;
		/**
		 * 禁止使用状态
		 */ 
		protected static const UNABLE:uint = 3;
		
		private var lableCache:Bitmap;
		
		
		public static function makeResource(b:BitmapData):Vector.<BitmapData>
		{
			var res:Vector.<BitmapData> = new Vector.<BitmapData>;
			
			var w:uint = int(b.width/4);
			for (var _x:uint = 0; _x < 4; _x++)
			{
				var btn:BitmapData = new BitmapData(w, b.height, true, 0x000000);
				btn.copyPixels(b, new Rectangle(w * _x, 0, w, b.height), new Point(), null, null, true);
				res.push(btn);
			}
			return res;
		}
		
		public function D5IVfaceButton(resource:Vector.<BitmapData>,callback:Function,resname:String='')
		{
			super(resource);
			
			_callback = callback;
			_resname = resname;
		}
		
		public function set callback(fun:Function):void
		{
			_callback = fun;
		}
		
		public function unSetup():void
		{
			removeEventListener(MouseEvent.MOUSE_OVER,changeStatus);
			removeEventListener(MouseEvent.MOUSE_OUT,changeStatus);
			removeEventListener(MouseEvent.MOUSE_DOWN,changeStatus);
			removeEventListener(MouseEvent.MOUSE_UP,changeStatus);
		}
		
		public function changeFace(resname:String):void
		{
			if(_resname==resname) return;
			_resname = resname;
			if(SanguoGlobal.resourcePool.getResource(resname)==null)
			{
				SanguoGlobal.loadResource2Pool('assets/ui/'+resname+'.png',resname,changeFaceLoad,TYPEID);
			}else{
				changeFaceLoad()
			}
			
		}
		public function set enabled(b:Boolean):void
		{
			_body.bitmapData = b ? _resource[DEFAULT] : _resource[UNABLE];
			
			mouseEnabled = b;
		}
		
		public function get enabled():Boolean
		{
			return mouseEnabled;
		}
		
		public function set unable(b:Boolean):void
		{
			_unable = b;
			
			if(!b)
			{
				filters = new Array(new ColorMatrixFilter([
						0.3, 0.59, 0.11, 0, 0, 
						0.3, 0.59, 0.11, 0, 0, 
						0.3, 0.59, 0.11, 0, 0, 
						0, 0, 0, 1, 0
					]));
			}else{
				filters = new Array();
			}
		}
		
		public function get unable():Boolean
		{
			return _unable;
		}
		
		public function set lable(lab:String):void
		{
			if(_lable==null)
			{
				_lable = new D5TLFText('',0xffffff);
				_lable.mouseEnabled=false;
				addChild(_lable);
			}
			_lable.text = lab;
			_lable.autoGrow();
			if(_resource==null)
			{
				return;
			}
			if(_resource[DEFAULT]==null) {
			return;
			}
			_lable.x = int((_resource[DEFAULT].width - _lable.width)*0.5);
			_lable.y = int((_resource[DEFAULT].height - _lable.height)*0.5);
		}
		/**
		 *用于Label被赋值后 
		 * @param str:按钮里面字的颜色
		 * @param str_1：字的描边
		 * 
		 */
		public function labelyanse(str:int,str_1:int):void
		{
			if(_lable!=null)
			{
				_lable.textColor=str;
				_lable.fontBorder=str_1;
			}
		}
		public function get lable():String
		{
			return _lable==null ? '' : _lable.text;
		}
		
		public function setLablePos(px:int,py:int):void
		{
			if(_lable==null) return;
			
			_lable.x = px;
			_lable.y = py;
		}
		
		public function setLableFormat(fontname:String,size:uint=18,light:int=-1,lightSize:uint = 5,lightRound:Number = 1.2,inner:Boolean=false):void
		{
			if(_lable==null) return;
			if(fontname!=null && SanguoGlobal.embedFont!=null)
			{
				var tf:TextFormat = new TextFormat(SanguoGlobal.embedFont.fontName,size);
				_lable.autoSize = TextFieldAutoSize.LEFT;
				_lable.embedFonts=true;
				_lable.antiAliasType = AntiAliasType.ADVANCED;
				_lable.setTextFormat(tf);
				_lable.align = D5TLFText.CENTER;
				if(light!=-1) _lable.light(light,lightSize,lightRound,inner);
			}
			
			if(fontname==null)
			{
				_lable.fontSize = size;
				_lable.fontBorder = light;
			}
			lable = _lable.text;
			
		}
		
		public function setLableBorder(u:uint):void
		{
			_lable.fontBorder=u;
		}
		
		/**
		 * 将按钮的lable进行位图缓存
		 * @param	colorList	各状态的字体颜色
		 * @param	lightColor	各状态的字体发光颜色
		 * @param	size		发光大小
		 * @param	round		发光扩散范围
		 */ 
		public function cacheLable(colorList:Array=null,lightColor:Array=null,size:uint=5,round:Number=1.2,inner:Boolean=false):void
		{
			if(_lable==null) return;
			if(colorList.length>3) throw new Error("Not support so much color.");
			
			
			_lableRes = new Vector.<BitmapData>;
			
			if(getChildByName('lableCache')!=null) removeChild(getChildByName('lableCache'));
			
			lableCache = new Bitmap();
			lableCache.name='lableCache';
			lableCache.x = _lable.x;
			lableCache.y = _lable.y;
			
			addChild(lableCache);
			removeChild(_lable);
			
			
			var b:BitmapData = new BitmapData(_lable.width,_lable.height,true,0x00000000);
			b.draw(_lable);
				
			_lableRes.push(b);
			lableCache.bitmapData = b;
				
			if(colorList!=null)
			{
				for(var i:uint=0;i<colorList.length;i++)
				{
					var c:BitmapData = new BitmapData(_lable.width,_lable.height,true,0x00000000);
					_lable.textColor = colorList[i];
					if(lightColor!=null && lightColor[i]!=null) _lable.light(lightColor[i],size,round,inner);
					c.draw(_lable);
					_lableRes.push(c);
				}
				
			}
			
			_lable.text='';
			_lable.filters=[];
			_lable = null;
		}
		
		override protected function setup():void
		{
			_body = new Bitmap(_resource[DEFAULT]);
			addChild(_body);
			
			addEventListener(MouseEvent.MOUSE_OVER,changeStatus);
			addEventListener(MouseEvent.MOUSE_OUT,changeStatus);
			addEventListener(MouseEvent.MOUSE_DOWN,changeStatus);
			addEventListener(MouseEvent.MOUSE_UP,changeStatus);
			super.setup();
		}
		
		protected function changeStatus(e:MouseEvent):void
		{
			if(!mouseEnabled) return;
			//e.stopImmediatePropagation();
			switch(e.type)
			{
				case MouseEvent.MOUSE_OVER:
					_shrink_lock=true;
//					Debug.trace('鼠标停留事件||',_shrink_lock);
					_body.bitmapData = _resource[OVER];
//					Debug.trace('闪烁s',OVER,_lableRes,_body,_resource[OVER]);
					if(_lableRes!=null && _lableRes[OVER]!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[OVER];
					break;
				case MouseEvent.MOUSE_OUT:
					_shrink_lock=false;
					_body.bitmapData = _resource[DEFAULT];
					if(_lableRes!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[DEFAULT];
					break;
				case MouseEvent.MOUSE_DOWN:
					_body.bitmapData = _resource[CLICK];
					if(_lableRes!=null && _lableRes[CLICK]!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[CLICK];
					break;
				case MouseEvent.MOUSE_UP:
					if(_body.bitmapData==_resource[CLICK] && _callback!=null && mouseEnabled)
					{
						_callback(id);
					}
					if(!mouseEnabled) return;
					_body.bitmapData = _resource[DEFAULT];
					if(_lableRes!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[DEFAULT];
					break;
				default:break;
			}
		}
		public function shrink():void
		{
//			Debug.trace('闪烁|',_shrink_lock,_window_open);
			if(_shrink_lock||window_open) return;
			if(!hasEventListener(Event.ENTER_FRAME))
			{
//				Debug.trace('闪烁'+this.toString());
			addEventListener(Event.ENTER_FRAME,update);
			}
		}
	    
		private function update(e:Event):void
		{
			if(_shrink_lock||window_open) return;
//			Debug.trace(_shrink_lock,window_open,this.name);
//			Debug.trace('闪烁ss'+this.toString());
			_shrink_interval++;
			if(_shrink_interval%20==9)
			{
//				_body.bitmapData=_resource[OVER];
				_body.alpha=0.8;
//				if(_lableRes!=null && _lableRes[OVER]!=null) lableCache.bitmapData = _lableRes[OVER];
//				Debug.trace('闪烁s',OVER,_lableRes,_body,_resource[OVER]);
//				Debug.trace(_body.alpha);
			}else if(_shrink_interval%20==19){
				_body.alpha=1;
//				_body.bitmapData=_resource[DEFAULT];
//				if(_lableRes!=null && _lableRes[DEFAULT]!=null) lableCache.bitmapData = _lableRes[DEFAULT];
//				Debug.trace('闪烁ss',DEFAULT,_lableRes,_body,_resource[DEFAULT]);
			}
		}
		public function close_shrink():void
		{
			_body.alpha=1;
		   removeEventListener(Event.ENTER_FRAME,update);	
//		   trace('ENTER_FRAME',hasEventListener(Event.ENTER_FRAME));
		}
		private function changeFaceLoad():void
		{
			if(_resname==null || _resname=='') return;
			_resource=SanguoGlobal.resourcePool.getResource(_resname);
			_body.bitmapData = _resource[DEFAULT];
//			Debug.trace('changeFaceLoad');
		}
	}
}
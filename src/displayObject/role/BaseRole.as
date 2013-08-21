package displayObject.role
{
	import CCUICoponent.D5TLFText;
	
	import displayObject.scences.AreaMap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;


	public class BaseRole extends Sprite
	{
		public var gridNum:Array=[8,9];
		/**
		 * 人物移的速度
		 */
		private var roleSpeed:int=5;
		/**
		 * 人吴的动作类型0~9
		 */
		public var _actionType:int;
		/**
		 * 所有移动的任务的基类
		 */
		public var bit:Bitmap;
		/**
		 *多少帧渲染一次动作
		 */
		public static var actionInterval:int=5;
		
		public var _width:Number;
		
		public var _height:Number;
		
		public var currentCol:int;
		public var _x_:int,_y_:int;
		public var _stop:Boolean=true;
		public var cnt:int=0;
		public var bitd:BitmapData;
		private var _id:int;
		public var _name:String='';
		public var _disIndex:uint;
		public var camp:int=0;
		public var direction:int;
		public function BaseRole(id:int=0,name:String='')
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,onAdd);
			_id=id;
			_name=name;
		}
		private function onAdd(e:Event):void
		{
//			trace('addEvt',e.target,e.target.parent.numChildren);
			var target:Sprite=e.target as Sprite;
		    _disIndex=target.parent.numChildren-1;	
		}
		/**
		 *
		 */
		public function loadAsset():void
		{
		var loader:Loader=new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE,show);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,showIOError);
		loader.load(new URLRequest("assets/0.png"));
		}
		private function showIOError(e:IOErrorEvent):void
		{
		 trace("加载不到");	
		}
		private function show(e:Event):void
		{

			var loader:Loader=(e.target as LoaderInfo).loader;
			loader.removeEventListener(Event.COMPLETE,show);
			bitd=(loader.content as Bitmap).bitmapData;
			_width=bitd.width/gridNum[0];
			_height=bitd.height/gridNum[1];
			var bitdat:BitmapData=new BitmapData(_width,_height);
			bitdat.copyPixels(bitd,new Rectangle(0,0,_width,_height),new Point())
			bit=new Bitmap(bitdat);
			bit.x=-_width*.5;
			bit.y=-_height*.9;
			this.addChild(bit);	
			var nameTxt:D5TLFText=new D5TLFText('');
			nameTxt.htmlText=_name;
			nameTxt.x=-bit.width*.5;
			nameTxt.y=bit.y-20;
			this.addChild(nameTxt);

		}
		private function onClick(e:MouseEvent):void
		{
//			e.stopPropagation();
		}
		/**
		 *设置人物的行进速度
		 */
		public function set speed(v:int):void
		{
		}
		/**
		 *设置人物动作，0为停止,1~8为0~360度的各个方向,9为放技能
		 */
		public function set action(i:int):void
		{
		   _actionType=i;
		   if(!this.hasEventListener(Event.ENTER_FRAME)){
		   this.addEventListener(Event.ENTER_FRAME,updateAction);
		   }
		}
		public function checkSpot(x:int,y:int):Boolean
		{
			return AreaMap.my.checkSpot(x,y);
		}
		public function updateAction(e:Event):void
		{
			var bitw:Number=bitd.width/gridNum[0];
			var bith:Number=bitd.height/gridNum[1];
//			dispatchEvent(new Event('move'));
			if(cnt==actionInterval){
				bit.bitmapData.copyPixels(bitd,new Rectangle(currentCol*bitw,_actionType*bith,bitw,bith),new Point());
				stop=false;
				if(_y_>y&&Math.abs(y-_y_)>step/2){
					if(checkSpot(x,y+step)==false) {
						return;				
					}
					y+=step;
					direction=2;
				}else if(_y_<y&&Math.abs(y-_y_)>step/2){
					if(checkSpot(x,y-step)==false) {
						return;				
					}
					y-=step;
					direction=4;
				}else if(_x_>x&&Math.abs(x-_x_)>step/2){
					if(checkSpot(x+step,y)==false) {
						return;				
					}
					x+=step;
					direction=1;
					
				}else if(_x_<x&&Math.abs(x-_x_)>step/2){
					if(checkSpot(x-step,y)==false) {
						return;				
					}
					x-=step;
					direction=3;
					
				}else{
					stop=true;
					if(this.hasEventListener(Event.ENTER_FRAME))
					{
						this.removeEventListener(Event.ENTER_FRAME,updateAction);
					}
				}
				cnt=0;
				if(!_stop){
				currentCol++;
				}else{
					currentCol=0;
				}
				if(currentCol>=gridNum[0])currentCol=0;
			}                   
			cnt++;
		}
		public function set stop(v:Boolean):void
		{
			_stop=v;
		}
		public function get stop():Boolean
		{
			return _stop;
		}
		public var step:int=12;
		public function moveTo(_x:int,_y:int):void
		{
			if(checkSpot(_x,_y)==false) {
				return;				
			}
			
			if(x<_x) action=3;
			else if(x>_x) action=2;
			_x_=_x;_y_=_y;
			if(_y>y&&Math.abs(y-_y)>step/2){
				y+=step;
				direction=2;
			}else if(_y<y&&Math.abs(y-_y)>step/2){
				y-=step;
				direction=4;
			}else if(_x>x&&Math.abs(x-_x)>step/2){
				x+=step;
				direction=1;
				dispatchEvent(new Event('move'));
			}else if(_x<x&&Math.abs(x-_x)>step/2){
				x-=step;
				direction=3;
				dispatchEvent(new Event('move'));
			}
			if(!this.hasEventListener(Event.ENTER_FRAME)){
				this.addEventListener(Event.ENTER_FRAME,updateAction);
			}
		}
	}	
}
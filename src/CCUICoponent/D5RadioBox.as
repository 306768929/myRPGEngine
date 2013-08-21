package CCUICoponent
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class D5RadioBox extends D5IVfaceButton
	{
		public static const TYPEID:uint = 1;
		
		/**
		 * RadioBox库
		 */ 
		private static var LIB:Dictionary=new Dictionary();
		
		private var _groupName:String;
		
		private var _selected:Boolean=false;
		
		/**
		 * 工作模式 0 为单选可空选 1为单选必选
		 */ 
		private var _workMode:uint = 0;
		
		/**
		 * 清除按钮组
		 */ 
		public static function clearGroup(s:String):void
		{
			if(LIB) delete LIB[s];
		}
		
		public function D5RadioBox(resource:Vector.<BitmapData>, callback:Function,lab:String,selected:Boolean=false,mode:uint = 0)
		{
			super(resource, callback);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemove);
			
			_workMode = mode;
			lable = lab;
			
			if(selected) Selected();
		}
		
		override public function set lable(s:String):void
		{
			super.lable = s;
			_lable.htmlText = s;
			_lable.x = _resource[0].width+5;
		}
		
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set groupName(s:String):void
		{
			if(LIB[s]==null)
			{
				LIB[s] = new Vector.<D5RadioBox>;
			}
			
			var id:int = LIB[s].indexOf(this);
			if(id!=-1) return;
			LIB[s].push(this);
			_groupName = s;
		}
		
		public function get groupName():String
		{
			return _groupName;
		}
		
		internal function unSelected():void
		{
			_selected = false;
			_body.bitmapData = _resource[DEFAULT];
			if(_lableRes!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[DEFAULT];
		}
		
		internal function Selected():void
		{
			if(_groupName!=null && _groupName!='' && LIB[_groupName].length>0)
			{
				for each(var btn:D5RadioBox in LIB[_groupName])
				{
					btn.unSelected();
				}
			}
			_selected=true;
			_body.bitmapData = _resource[CLICK];
			if(_lableRes!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[CLICK];
		}
		
		override protected function changeStatus(e:MouseEvent):void
		{
			if(!mouseEnabled) return;
			e.stopImmediatePropagation();
			if(_workMode==0)
			{
				switch(e.type)
				{
					case MouseEvent.MOUSE_DOWN:
						if(selected==false)
						{
							_body.bitmapData = _resource[CLICK];
							if(_lableRes!=null && _lableRes[CLICK]!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[CLICK];
							_selected=true;
						}
						else
						{
							_body.bitmapData = _resource[DEFAULT];
							if(_lableRes!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[DEFAULT];
							_selected=false;
						}
					default:break;
				}
				
			}
			
			else if(_workMode==1)
			{
				if(_selected && e.type!=MouseEvent.MOUSE_UP) return;
				switch(e.type)
				{
					case MouseEvent.MOUSE_OVER:
						_body.bitmapData = _resource[OVER];
						if(_lableRes!=null && _lableRes[OVER]!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[OVER];
						break;
					case MouseEvent.MOUSE_OUT:
						_body.bitmapData = _resource[DEFAULT];
						if(_lableRes!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[DEFAULT];
						break;
					case MouseEvent.MOUSE_DOWN:
						_body.bitmapData = _resource[CLICK];
						if(_lableRes!=null && _lableRes[CLICK]!=null) (getChildByName('lableCache') as Bitmap).bitmapData = _lableRes[CLICK];
						break;
					case MouseEvent.MOUSE_UP:
						
						//_body.bitmapData = _resource[DEFAULT];
						if(_selected && _workMode==1)
						{
							return;
						}else{
							unSelected();
						}
						if(!_selected) Selected();
						
						
						if(_selected && _callback!=null && mouseEnabled)
						{
							_callback(id);
						}
						break;
					default:break;
				}
			}
		}
		
		private function onRemove(e:Event):void
		{
			
		}
	}
}
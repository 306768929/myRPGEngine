package CCUICoponent
{
	import flash.display.BitmapData;
	import flash.display.Sprite;

	internal class D5Component extends Sprite
	{
		/**
		 * 素材资源
		 */ 
		protected var _resource:Vector.<BitmapData>;
		
		public function D5Component(resource:Vector.<BitmapData>=null)
		{
			_resource = resource;
			if(_resource!=null) setup();
		}
		
		protected function setup():void
		{
			closeMouseEvent();
		}
		
		/**
		 * 循环关闭鼠标响应
		 */ 
		protected function closeMouseEvent():void
		{
			var obj:Sprite;
			for(var i:uint=0;i<numChildren;i++)
			{
				obj = getChildAt(i) as Sprite;
				if(obj==null) continue;
				obj.mouseChildren=false;
				obj.mouseEnabled=false;
			}
		}
		
		public function unsetup():void
		{
			_resource = null;
		}
		
	}
}
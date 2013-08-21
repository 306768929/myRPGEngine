package datastruct
{
	import displayObject.role.BaseRole;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public class QtreeNode
	{
		public var _childList:Vector.<QtreeNode>=new Vector.<QtreeNode>;
		public var _parent:QtreeNode;
		public var objectList:Vector.<BaseRole>=new Vector.<BaseRole>;
		public var x1:Number=0,x2:Number=0;
		public var y1:Number=0,y2:Number=0;
		public var deep:int;
		public function QtreeNode(_p:QtreeNode=null,_x1:Number=0,_x2:Number=0,_y1:Number=0,_y2:Number=0,_deep:int=1)
		{
			_parent=_p;
			x1=_x1;x2=_x2;y1=_y1;y2=_y2;
			deep=_deep;
		}
	}
}
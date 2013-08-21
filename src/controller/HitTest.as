package controller{
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.getTimer;
	public class HitTest {
		//按像素检测
		private static function _hitTest(shape1:DisplayObject,shape2:DisplayObject):Boolean {
			var p1x:Number = shape1.getRect(shape1).x;
			var p1y:Number = shape1.getRect(shape1).y;
			var p2x:Number = shape2.getRect(shape2).x;
			var p2y:Number = shape2.getRect(shape2).y;
			
			var p1w:Number = shape1.width;
			var p1h:Number = shape1.height;
			var p2w:Number = shape2.width;
			var p2h:Number = shape2.height;
			p1w = p1w<1?1:p1w;
			p1h = p1h<1?1:p1h;
			p2w = p2w<1?1:p2w;
			p2h = p2h<1?1:p2h;
			
			var BmpData1:BitmapData = new BitmapData(p1w,p1h,true,0x00000000);
			var BmpData2:BitmapData = new BitmapData(p2w,p2h,true,0x00000000);
			BmpData1.draw(shape1,new Matrix(1,0,0,1,-p1x, -p1y));
			BmpData2.draw(shape2,new Matrix(1,0,0,1,-p2x, -p2y));
			
			var gp1:Point = shape1.localToGlobal(new Point(p1x,p1y));
			var gp2:Point = shape2.localToGlobal(new Point(p2x,p2y));
			var re:Boolean = BmpData1.hitTest(gp1,0x05,BmpData2,gp2,0x05);
			
			BmpData1.dispose();
			BmpData2.dispose();
			return re;
		}
		//按矩形区域检测
		public static function hitTestRect(shape1:DisplayObject,shape2:DisplayObject):Boolean {
			if (shape1.hitTestObject(shape2))
				return true;
			return false;
		}
		//按点和形状检测
		public static function hitTestPoint(point:DisplayObject,shape:DisplayObject):Boolean {
			if (shape.hitTestPoint(point.x,point.y,true)) 
				return true;
			return false;
		}
		//按形状检测
		public static var cnt:int;
		public static function hitTestShape(shape1:DisplayObject,shape2:DisplayObject):Boolean {
//			return false;
			var hit:Boolean = false;
			if(!shape1||!shape2) return false;
			if (shape1.hitTestObject(shape2)) {
				if (shape2.width<20 && shape2.height<20) {
					hit = true;
				} else {
					if (HitTest._hitTest(shape1,shape2)) {
						hit = true;
					}
				}
			}
			//trace("======xxx======",cnt++,shape1,shape2);
			return hit;
		}
	}
}
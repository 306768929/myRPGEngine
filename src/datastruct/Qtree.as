package datastruct
{
	
	import controller.HitTest;
	
	import displayObject.role.BaseRole;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;

	public class Qtree
	{
		public var _root:QtreeNode;
		private var maxDeep:int;
		private static var _my:Qtree;
		public var objectList:Array=new Array();
		public function Qtree()
		{
			var node:QtreeNode=new QtreeNode(null,0,Global.STAGE.stageWidth,0,Global.STAGE.stageHeight);
			create_tree(node);
		}
		public static function get my():Qtree
		{
			if(_my==null) _my=new Qtree();
			return _my;
		}
		public function adjustIndex():void
		{
			objectList.sortOn("y",16);
			var cnt:int;

			var length:int=objectList.length;
			var baserole:DisplayObject;
			for(var i:int=0;i<length;i++)
			{
				baserole=RPGScene.my.ROLE.getChildAt(i);
				if(baserole!=objectList[i])
				{
					RPGScene.my.ROLE.setChildIndex(objectList[i],i);
				}
			}
		}
		public function create_tree(node:QtreeNode):void
		{
		  if(_root==null)
		  {
			  _root=node;
		  }
			  add_qt_node(node);
		}
		public function add_qt_node(_p:QtreeNode):void
		{
			if(_p.deep<=3)
			{
				var _mx:Number=(_p.x1+_p.x2)*.5;
				var _my:Number=(_p.y1+_p.y2)*.5;
				_p._childList[0]=new QtreeNode(_p,_mx,_p.x2,_p.y1,_my,_p.deep+1);
				_p._childList[1]=new QtreeNode(_p,_mx,_p.x2,_my,_p.y2,_p.deep+1);
				_p._childList[2]=new QtreeNode(_p,_p.x1,_mx,_my,_p.y2,_p.deep+1);
				_p._childList[3]=new QtreeNode(_p,_p.x1,_mx,_p.y1,_my,_p.deep+1);

				if(_p.deep==3)
				{
//					var shape:Shape=new Shape();
//					shape.graphics.beginFill(0xff0000,.1);
//					shape.graphics.lineStyle(1,0x0000ff,.3);
//					shape.graphics.drawRect(_p.x1,_p.y1,_p.x2-_p.x1,_p.y2-_p.y1);
//					shape.graphics.endFill();
//				  Global.STAGE.addChild(shape);
				}
				add_qt_node(_p._childList[0]);
				add_qt_node(_p._childList[1]);
				add_qt_node(_p._childList[2]);
				add_qt_node(_p._childList[3]);
			}
		}
		public function insert_check_data(dis:BaseRole):void//检测碰撞
		{
			var tmp:QtreeNode=_root;
			var _disx:Number=dis.bit.x+dis.x;
			var _disy:Number=dis.bit.y+dis.y;
			var disx:Number=_disx+dis._width
			var disy:Number=_disy+dis._height;
		     while(tmp.deep<=3)
			 {
				 

				 var _mx:Number=(tmp.x1+tmp.x2)/2;
				 var _my:Number=(tmp.y1+tmp.y2)/2;
				 var n:int;
				 if(_disx>tmp.x1&&disx<_mx&&_disy>tmp.y1&&disy<_my)//第四象限
				 {
					 check_data(dis,tmp);
					tmp=tmp._childList[3];
					n=4;
				 }else if(_disx>tmp.x1&&disx<_mx&&_disy>_my&&disy<tmp.y2)//第三象限
				 {
					 check_data(dis,tmp);
					tmp=tmp._childList[2]
					n=3;
				 }else if(_disx>_mx&&disx<tmp.x2&&_disy>tmp.y1&&disy<_my)//第一象限
				 {
					 check_data(dis,tmp);
					 tmp=tmp._childList[0];
					 n=1;
				 }else if(_disx>_mx&&disx<tmp.x2&&_disy>_my&&disy<tmp.y2)//第二象限
				 {
					 check_data(dis,tmp);
					 tmp=tmp._childList[1]
					 n=2;
				 }
				 else{
					 check_data(dis,tmp);					 
			 		 check_with_child(dis,tmp);
				 break;
				 } 
			 }
			 tmp.objectList.push(dis);
		}
		private function check_with_child(dis:BaseRole,_tmp:QtreeNode):void
		{
			if(_tmp==null) return;
			var tmp:QtreeNode=_tmp;
			var x1:Number=dis.bit.x
		    var x2:Number=x1+dis._width;
			var y1:Number=dis.bit.y;
			var y2:Number=y1+dis._height;
			for(var i:int=0;i<4;i++)
			{
				if(tmp.deep<3)
				{
			     tmp=_tmp._childList[i];
				 if(x2<tmp.x1||x1>tmp.x2||y2<tmp.y1||y1>tmp.y2)
				 {
					 break;
				 }
			  	 check_hit(dis,tmp);
				 check_with_child(dis,tmp);
				 tmp=_tmp;
				}
			}
		}
		private function check_hit(dis:BaseRole,tmp:QtreeNode):void
		{
			var _disy:Number=dis.bit.y+dis.y;
				for each(var obj:BaseRole in tmp.objectList)
				{
					if(obj==null) break;
					if(obj.stop&&dis.stop&&!Global.fristHittest||dis.camp==obj.camp) break;
					if(HitTest.hitTestShape(obj.bit,dis.bit))
					{

					}
				}
		}
		private function check_data(dis:BaseRole,tmp:QtreeNode):void
		{
			var cnt:int=0;
			var _disy:Number=dis.bit.y+dis.y;

			for each(var obj:BaseRole in tmp.objectList)
			{
				if(obj==null) break;
				if(obj.stop&&dis.stop&&!Global.fristHittest||dis.camp==obj.camp) break;

				if(HitTest.hitTestShape(obj.bit,dis.bit))
				{
				
				}
				cnt++;
			}
		}
		public function clear_data(qt:QtreeNode):void//清除结点的所有数据
		{
			if(qt!=null) qt.objectList=new Vector.<BaseRole>();
			if(qt.deep>3) return;
			for(var i:int;i<4;i++)
			{
				if(qt._childList[i]) clear_data(qt._childList[i]);				
			}
		}
	}
}
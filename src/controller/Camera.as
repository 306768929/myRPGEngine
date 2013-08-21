package controller
{
	import displayObject.role.BaseRole;
	import displayObject.scences.AreaMap;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class Camera
	{
		private var _focus:BaseRole;
		private var _map:AreaMap;
		public static var _my:Camera;
		public function Camera()
		{

		}
		public static function get my():Camera
		{
			if(_my==null) _my=new Camera();
			return _my;
		}
		/**
		 *设置要控制的地图
		 */
		public function set map(v:AreaMap):void
		{
			_map=v;
		}

		/**
		*镜头跟随
		*/
		public function set focus(ply:BaseRole):void
		{
			_focus=ply;
			ply.addEventListener("move",followCamera);
		} 
		public function get focus():BaseRole
		{
			return _focus;
		}
		/**
		 *镜头跟随
		 */
		private function followCamera(e:Event):void
		{
			var step:int=_focus.step;
			var point:Point=_focus.localToGlobal(new Point());
			switch(_focus.direction)
			{
				case 1:
					if(point.x>Global.STAGE_WIDTH*.6){
					_map.scroll(-step);
					RPGScene.my.ROLE.x=_map.x;
					}
					break;
				case 2:
//					Demo.my.ROLE.y+=step;
//					_map.y+=step;
					break;
				case 3:
					if(point.x<Global.STAGE_WIDTH*.4){
					_map.scroll(step);
					RPGScene.my.ROLE.x=_map.x;
					}
					break;
				case 4:
					break;
				default:;
			}
		}
	}
}
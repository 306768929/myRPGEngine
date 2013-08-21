package controller
{
	public class ColorCtrl
	{
		private static var _my:ColorCtrl;
		public function ColorCtrl()
		{
		}
		public static function get my():ColorCtrl
		{
		   if(_my==null) _my=new ColorCtrl();
		   return _my;
		}
	}
}
package
{
	import UI.SmallWindow;
	
	import displayObject.role.BaseRole;
	import displayObject.scences.AreaMap;
	
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Global
	{
		public static var STAGE:Stage;
		public static var areaMap:AreaMap;
		public static var fristHittest:Boolean=true;
		public static var hitTestList:Vector.<BaseRole>;
		public static const STAGE_WIDTH:int=1240;
		public static const STAGE_HEIGHT:int=600;
		public static var smalWin:SmallWindow;
		public function Global()
		{
		}
     
	}
}
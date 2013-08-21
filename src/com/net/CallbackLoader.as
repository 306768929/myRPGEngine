package com.net
{
	import flash.display.Loader;
	
	/**
	 * 携带回叫函数数据的Loader
	 */ 
	public class CallbackLoader extends Loader
	{
		public var callback:Function;
		public var workType:uint;
		//是否后台加载
		public var loadType:Boolean;
		public var url:String;
		
		public function CallbackLoader()
		{
			super();
		}
	}
}
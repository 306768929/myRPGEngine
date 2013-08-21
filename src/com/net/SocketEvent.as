package com.net
{
	import flash.events.Event;
	
	public class SocketEvent extends Event
	{
		private var _data:*;
		
		private var _cmdcode:uint;
		
		public static const COMPLATE:String = 'COMPLATE';
		
		public function SocketEvent(type:String,cmdcode:uint,data:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			_cmdcode = cmdcode;
			super(type, bubbles, cancelable);
		}
		
		public function get data():*
		{
			return _data;
		}
		
		public function get cmdcode():uint
		{
			return _cmdcode
		}
	}
}
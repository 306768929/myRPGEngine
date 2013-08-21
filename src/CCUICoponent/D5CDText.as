package CCUICoponent
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(type='flash.events.Event',name="COMPLATE")]
	/**
	 * 具备倒计时功能的TextField
	 */ 
	public class D5CDText extends D5TLFText
	{
		private var _time:uint;
		private var _timer:Timer;
		/**
		 * 
		 */ 
		public function D5CDText(time:uint, fontcolor:int=-1, bgcolor:int=-1, border:int=-1, size:uint=12)
		{
			_time = time;
			super(parsedTime, fontcolor, bgcolor, border, size);
			timeStart();
		}
		
		public function set time(t:int):void
		{
//			if(t<0) throw new Error("[D5CDText.time] 无法给定负数的CD时间。");
			if(t<0) t=0;
			if(t>0)
			{
				_time = t;
				timeStart();
				visible = true;
			}else{
				_time = 0;
				text = "00:00";
				visible = false;
				_timer.stop();
			}
		}
		
		public function get time():int
		{
			return _time;
		}
		
		
		private function timeStart():void
		{
			if(!_timer)
			{
				_timer = new Timer(1000);
			}
			if(!_timer.hasEventListener(TimerEvent.TIMER))	_timer.addEventListener(TimerEvent.TIMER,run);
			if(!hasEventListener(Event.REMOVED_FROM_STAGE)) addEventListener(Event.REMOVED_FROM_STAGE,unsetup);
			
			if(_time>0)
			{
				text = parsedTime;
				if(!_timer.running) _timer.start();
			}
		}
		
		private function run(e:TimerEvent):void
		{
			_time--;
			text = parsedTime;
			if(_time==0)
			{
				dispatchEvent(new Event(Event.COMPLETE));
				text = "00:00";
				_timer.stop();
			}
		}
		
		private function unsetup(e:Event):void
		{
			if(_timer)
			{
				_timer.removeEventListener(TimerEvent.TIMER,run);
				_timer.stop();
			}
			
			removeEventListener(Event.REMOVED_FROM_STAGE,unsetup);
		}
		
		private function get parsedTime():String
		{
			var sh:String;
			var sm:String;
			var ss:String;
			var h:uint;
			var m:uint;
			var s:uint;
			
			var t:uint = _time;
			
			if(t>3600)
			{
				h = int(t/3600);
				t = t-h*3600;
				m = int(t/60);
				s = t-m*60;
			}else{
				h=0;
				m = int(t/60);
				s = t-m*60;
			}
			
			sh = h>=10 ? h.toString() : '0'+h.toString();
			sm = m>=10 ? m.toString() : '0'+m.toString();
			ss = s>=10 ? s.toString() : '0'+s.toString();
			if(h) return sh+':'+sm+':'+ss;
			else return sm+':'+ss;
		}
	}
}
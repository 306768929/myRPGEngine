package displayObject.role
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	public class Player extends BaseRole
	{
		private var keyDown:Boolean;
		public function Player(id:int=0,camp:int=0,name:String='')
		{
			camp=camp;
			super(id,name);

		}
		public function onKeyUp(e:KeyboardEvent):void
		{
			step=12;
			keyDown=false;
			stop=true;
		}
		override public function updateAction(e:Event):void
		{
			var bitw:Number=bitd.width/gridNum[0];
			var bith:Number=bitd.height/gridNum[1];
//			dispatchEvent(new Event('move'));
			if(cnt==actionInterval){ 
				bit.bitmapData.copyPixels(bitd,new Rectangle(currentCol*bitw,_actionType*bith,bitw,bith),new Point());
				stop=false;
				if(_y_>y&&Math.abs(y-_y_)>step/2){
//					if(checkSpot(x,y+step)==false) {
//						return;				
//					}
					y+=step;
					direction=2;
				}else if(_y_<y&&Math.abs(y-_y_)>step/2){
//					if(checkSpot(x,y-step)==false) {
//						return;				
//					}
					y-=step;
					direction=4;
				}else if(_x_>x&&Math.abs(x-_x_)>step/2){
//					if(checkSpot(x+step,y)==false) {
//						return;				
//					}
					x+=step;
					direction=1;
					dispatchEvent(new Event('move'));
				}else if(_x_<x&&Math.abs(x-_x_)>step/2){
//					if(checkSpot(x-step,y)==false) {
//						return;				
//					}
					x-=step;
					direction=3;
					dispatchEvent(new Event('move'));
				}else{
					if(keyDown==false&&this.hasEventListener(Event.ENTER_FRAME))
					{
						stop=true;
						this.removeEventListener(Event.ENTER_FRAME,updateAction);
					}
					else {
					configDirection(keyCode);
					}
				}
				cnt=0;
				if(!_stop){
					currentCol++;
				}else{
					currentCol=0;
				}
				if(currentCol>=gridNum[0])currentCol=0;
			}                   
			cnt++;
		}
		private var keyCode:uint;
		private var lastKeyDownTime:uint;
		public function onKey(e:KeyboardEvent):void
		{

			if(keyDown) return;
			keyDown=true;
			keyCode=e.keyCode;
			if(getTimer()-lastKeyDownTime<300)
			{
				step=24;
				trace("24");
			}
			else {
				setp=12;
				trace("12");
			}
			configDirection(keyCode);
			lastKeyDownTime=getTimer();
		}
		private function configDirection(keyCode:uint):void
		{
			switch(keyCode)
			{
				case 68://D
					moveTo(x+step,y);
					
					break;
				case 65://A
					moveTo(x-step,y);
					break
				case 87://W
					moveTo(x,y-step);
					
					break;
				case 83://S
					moveTo(x,y+step);
					break;
				default:;
			}
			
		}
		
	}
}
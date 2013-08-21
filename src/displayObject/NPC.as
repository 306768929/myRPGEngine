package displayObject
{
	import UI.SmallWindow;
	
	import displayObject.role.BaseRole;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class NPC extends BaseRole
	{
		public function NPC(id:int=0,camp:int=0,name:String='')
		{
			super(id, name);
			camp=camp;
//			this.addEventListener(Event.ENTER_FRAME,walk);
			this.addEventListener(MouseEvent.CLICK,onClick);
		}
		private function onClick(e:MouseEvent):void
		{
			if(Global.smalWin&&Global.smalWin.parent)
			{
				Global.smalWin.parent.removeChild(Global.smalWin);
			}
			Global.smalWin=new SmallWindow(this.localToGlobal(new Point()).x-170,y-220);
			
			Global.STAGE.addChild(Global.smalWin);
		}
	}
}
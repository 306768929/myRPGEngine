package UI
{
	import CCUICoponent.D5IVfaceButton;
	import CCUICoponent.D5MirrorBox;
	import CCUICoponent.D5TLFText;
	
	import flash.display.Sprite;
	
	public class SmallWindow extends Sprite
	{
		public function SmallWindow(_x:int=0,_y:int=0)
		{
			x=_x;
			y=_y;
			super();
			s1();
		}
		private function s1():void
		{  
			SanguoGlobal.loadResource2Pool('assets/box1.png','box1',s2,D5MirrorBox.TYPEID);	
		}
		private function s2():void
		{
			SanguoGlobal.loadResource2Pool('assets/btn_19.png','btn_19',show,D5IVfaceButton.TYPEID);	
		}
		private function show():void
		{  
			var boxbg:D5MirrorBox = new D5MirrorBox(SanguoGlobal.resourcePool.getResource('box1'),284,140);
			boxbg.x = 17; boxbg.y = 13;
			boxbg.alpha=.5;
			this.addChild(boxbg);
			//text
			var txt:D5TLFText=new D5TLFText("",0xff00cc);
			txt.htmlText="我是NPC";
			txt.x=30;
			txt.y=30;
			this.addChild(txt);
			var bt:D5IVfaceButton=new D5IVfaceButton(SanguoGlobal.resourcePool.getResource("btn_19"),onClick);
			bt.x=boxbg.width-bt.width;
			bt.y=boxbg.height-bt.height;
			bt.lable="OK"
			this.addChild(bt);
		}
		private function onClick(id:int):void
		{
			if(this.parent) this.parent.removeChild(this);
		}
	}
}
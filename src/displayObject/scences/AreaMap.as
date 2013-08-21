package displayObject.scences
{
	import controller.Camera;
	
	import displayObject.role.Player;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	public class AreaMap extends Sprite
	{
		public var _bmd:Bitmap;
		public var Roadbmd:Bitmap;
		public var bmddata:BitmapData;
		public var loader:Loader;
		public var _width:Number=536*5;
		public var _height:Number=650;
		private var tileList:Array=[
									"0_0","0_1","0_2","0_3","0_4",
									"1_0","1_1","1_2","1_3","1_4"
									]
		public function AreaMap()
		{
			super();
			bmddata=new BitmapData(_width,_height,true,0);
			_bmd=new Bitmap(bmddata);
//			_bmd.alpha=.5;
//			this.addEventListener(MouseEvent.CLICK,playerMove);
			loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaded);
			loader.load(new URLRequest("assets/map25.png"));
			
			
		}
		private function playerMove(e:MouseEvent):void
		{
			if(Camera.my.focus==null) return;
			Camera.my.focus.moveTo(this.mouseX,this.mouseY);
		}
		private static var _my:AreaMap;
		public static function get my():AreaMap
		{
			if(_my==null) {
			_my=new AreaMap();				
			}
			return _my;
		}
		private var index:int=-1;
		private function loadMap():void
		{

			loader.load(new URLRequest("assets/map/"+tileList[index]+".jpg"));
//			trace(tileList);
		}
		
		public function scroll(step:int):void
		{
			if(step<0){
				var dist:Number=Global.STAGE_WIDTH-this.localToGlobal(new Point(_width,0)).x;
				if(step<dist)
				{
					this.x+=dist;
				}else {
					this.x+=step;
				}
			}else if(step>0){
				if(this.x+step>0){
					this.x=0;
				}else {
					this.x+=step;
				}
			}
			
		}
		public function checkSpot(_x:int,_y:int):Boolean
		{
			if(this.Roadbmd==null) return false;
			var xx:Number=_x;
			var yy:Number=_y;
//			trace(_x,_y,this.x,this.y);
			var color:uint=this.Roadbmd.bitmapData.getPixel(xx*Roadbmd.width/_width/Roadbmd.scaleX,yy*Roadbmd.height/_height/Roadbmd.scaleY);
//			trace(xx,yy,x/x*Roadbmd.width/_width/Roadbmd.scaleX,yy*Roadbmd.height/_height/Roadbmd.scaleY);
			return color==0xffffff;
//			return true;
		}
		private function onLoaded(e:Event):void
		{
			
			var bmd:Bitmap=(e.target as LoaderInfo).content as Bitmap;
			if(index==-1)
			{
				Roadbmd=bmd;
				Roadbmd.width=536*5;
				Roadbmd.height=650;
//				this.addChild(Roadbmd);
				index=0;
				this.addChild(_bmd);
				loadMap();
				return;
			}
			var arr:Array=(tileList[index] as String).split("_");
			var wid:Number=bmd.bitmapData.width;
			var hei:Number=bmd.bitmapData.height;
//			trace(wid,hei,arr);
			bmddata.copyPixels(bmd.bitmapData,new Rectangle(0,0,wid,hei),new Point(Number(arr[1])*wid,Number(arr[0])*hei));
			index++;
			if(index>=tileList.length) return;
			loadMap();
			
		}
		
	}
}
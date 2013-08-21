package
{
	
	import CCUICoponent.D5IVfaceButton;
	
	import com.net.CallbackLoader;
	
	import controller.Camera;
	
	import datastruct.Qtree;
	
	import displayObject.NPC;
	import displayObject.role.BaseRole;
	import displayObject.role.Player;
	import displayObject.scences.AreaMap;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.flash_proxy;
	import flash.utils.getTimer;
	
	import stuff.ColorChange;
	
//		[SWF(width="1240",height="650",frameRate="60",backgroundColor="#ffccff")]
	public class RPGScene extends MovieClip
	{
		/**
		 * 游戏由低向高分为4层,以下是这四成的容器,共同的父容器为Stage
		 */
		public var MAP:Sprite;
		public var _areaMap:AreaMap;
		public var ROLE:Sprite;
		private var UI:Sprite;
		private var WINDOW:Sprite;
		private static var _my:RPGScene;
		public var _mapid:int;
		private var txt:TextField;
		private var _player:Player;
		private var _callback:Function;
		public function RPGScene(stg:Stage=null,callback:Function=null,mapid:int=1)
		{
//			if(stg==null||stage==null) return;
			_my=this;
			_callback=callback;
			Global.STAGE=stage?stage:stg;
			_mapid=mapid;
			setup(); 
		}
		public static function get my():RPGScene
		{
			return _my;
		}
		private function setup():void
		{
			if(MAP==null) MAP=new Sprite();
			if(Global.STAGE==null) return;
			this.addChild(MAP);
			
			if(ROLE==null) ROLE=new Sprite();
			this.addChild(ROLE);
			
			if(UI==null) UI=new Sprite();
			Global.STAGE.addChild(UI);
			if(WINDOW==null) WINDOW=new Sprite();
			this.addChild(WINDOW);
			
			_areaMap=AreaMap.my;
			Camera.my.map=_areaMap;

			MAP.addChild(AreaMap.my);
			
			//QTree
			
			create_disp_object();
		   
		}
		private function onKeyDown(e:Event):void
		{ 
			_player.onKey(e);
		}
		private function onKeyUp(e:Event):void
		{
			_player.onKeyUp(e);
		}
		private function onClick(e:MouseEvent):void
		{
			_player.moveTo(e.target.mouseX,e.target.mouseY);
		}
		private function update(e:Event):void
		{

			Qtree.my.adjustIndex();
			for each(var obj:BaseRole in Qtree.my.objectList)
			{
				if(obj.bit==null) continue;
				Qtree.my.insert_check_data(obj);
			}

		}
		private function create_disp_object():void
		{
			
			_player=new Player(0,0,'玩玩玩');
			_player.x=400;
			_player.y=400;
			_player.loadAsset();
			Camera.my.focus=_player;
			ROLE.addChild(_player);
			Qtree.my.objectList[0]=_player;
			
			for(var i:int=1;i<10;i++)
			{
			var npc1:NPC=new NPC(2,1,'NPC'+i);
			npc1.x=100+Math.random()*2000;
			npc1.y=350+Math.random()*300;
			npc1.loadAsset();
			ROLE.addChild(npc1);
			Qtree.my.objectList[i]=npc1;
			}
			this.addEventListener(Event.ENTER_FRAME,update);
			Global.STAGE.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			Global.STAGE.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			Global.STAGE.addEventListener(MouseEvent.CLICK,onClick);
			this.addEventListener(Event.REMOVED_FROM_STAGE,onRemoved);
			SanguoGlobal.loadResource2Pool('assets/btn_19.png','btn_19',show,D5IVfaceButton.TYPEID);	
//			trace(Qtree.my.objectList.length);
			
		}
		private function onRemoved(e:Event):void
		{
			Global.STAGE.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			Global.STAGE.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			Global.STAGE.removeEventListener(MouseEvent.CLICK,onClick);
		}
		private function show():void
		{
			var bt:D5IVfaceButton=new D5IVfaceButton(SanguoGlobal.resourcePool.getResource("btn_19"),onClickBt);
			bt.x=1240*2;
			bt.y=600*2;
			bt.lable="进入"
		    this.addChild(bt);
			
		}
		private function onClickBt(id:int=0):void
		{
//		     dispatchEvent(new Event("leaveRPGScene"));
			if(_callback!=null) _callback();
		}
		
	}
}
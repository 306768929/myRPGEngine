package com._486G.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class XWindow extends Sprite
	{
		
		public var _Datahtml:Array;
		
		/**
		 * 当前打开的窗口ID
		 */ 
		protected static var _nowOpen:int = -1;
		
		/**
		 * 缓存打开过的窗口
		 */
		protected static var _reOpenlist:Vector.<String> = new Vector.<String>();
		
		/**
		 * 需要发包获取数据的窗口
		 */
		protected static var _waitList:Array = ['SZ_Wujiang','JG_Zhaomu','JG_Majiu'];
		
		/**
		 * 当前打开的窗口标题
		 */ 
		protected var _title:String;
		
		public var _width:uint;
		
		public var _height:uint;
		
		protected var _content:Sprite;
		internal var _background:XWindowBackground;
		
		protected var CDList:Vector.<int>;
		
		private var testLo:URLLoader;
		private var helpId:int;
		protected var holdposy:uint=30;
		
		/**
		 *当前的CDShow； 
		 */
		protected var cleanCD:Object;
		/**
		 * 窗口父类
		 * 
		 * @param	
		 */ 
		public function XWindow(w:uint,h:uint,title:String)
		{
			super();
			
			if(_reOpenlist.indexOf(this.className)==-1) 
			{
				if(_waitList.indexOf(this.className)!=-1)
				{
					wait();
				}
				
				_reOpenlist.push(this.className);
			}
			
			_title = title;
			_width = w;
			_height = h;
			_content = new Sprite();
			addEventListener(Event.ADDED_TO_STAGE,startUI,false,0,true);
//			Loadlist.my.lock=true;
		}
		
		protected function startUI(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,startUI);
			init(_width,_height);
		}
		
		protected function buildHole(px:uint=0,py:uint=0,w:uint=0,h:uint=0,buildHole:Boolean=false):void
		{
			_background.buildHole(px,py,w,h,buildHole);
		}
		
		protected function set title(s:String):void
		{
			_title = s;
			if(_background)_background.title = s;
		}
		
		public function get className():String
		{
			return 'XWindow';
		}
		
		protected function get background():XWindowBackground
		{
			return _background;
		}
		
		protected function init(w:uint,h:uint):void
		{
			XWindowBackground.getBackground(w,h,this);
		}
		
		protected function setSize(w:uint,h:uint,isAdd:Boolean=false):void
		{
			if(!_background) return;
			_background.setSize(w,h,isAdd);
			
			_background.buildHole(5,holdposy,w-19,h-50-holdposy,true);
		}
		
		public function addChildren():void
		{
			addChild(_background);
			
			addChild(_background._closeBtn);
			addChild(_background._helpBtn);

			_content.x = 23;
			_content.y = 58;
			addChild(_content);
			
			_background.title = _title;
			loaderHelp();
			
			background.visible = true;
			background._closeBtn.visible = true;
			background._helpBtn.visible = false;
			
			//closeWait();
		}
		
		private function wait():void
		{
			RPGScene.my.wait();
		}
		
		public function closeWait():void
		{
			RPGScene.my.closeWait();
		}
		/**
		 *加载帮组配置文件 
		 * 
		 */
		public function loaderHelp():void
		{
			if(SanguoGlobal.Configer.Datahtml.length<1)
			{
				testLo=new URLLoader();
				var testqu:URLRequest=new URLRequest(RPGScene.my.flashvars.cdn+"assets/data/help.d5");
				testLo.load(testqu);
				testLo.addEventListener("complete",tojiexi); 
			}
			
		}
		public function onClose(id:uint=0):void
		{

				if(_background) _background.realse();
				_background = null;	
				WinBox.my.removeChild(this);
				if(this.parent) this.parent.removeChild(this);
				if(SanguoGlobal.Configer.missonId<=163)
				{
					if(this.className=='AddNameWindow') return;
					if(this.className=='HzuanPanel') return;
					if(this.className=='LoginReward') return;
					if(this.className=='PH_W') return;
					if(this.className=='PH_S') return;
					if(this.className=='XiaoFei_Rwd') return;
					if(this.className=='PaiMai') return;
					if(this.className=='ContainerXWindow2') return;
					if(this.className=='ContainerXWindow1') return;
					if(BaseOperation.nowOpen>=1&&BaseOperation.nowOpen<=21) return;
					BaseOperation.__nowOpen=BaseOperation.formalOpen;	
					var i:int=BaseOperation.formalOpen;
					trace('恢复过==',className,i);
					HelpCenter.my.update();
				}

		}
		/**
		 * 设置CD
		 * @param	id		冷却ID
		 * @param	info	冷却提示
		 * @param	obj		冷却控制的按钮
		 * @param	isShowSpeed		是否显示加速按钮
		 * @param	isListener		冷却结束后时候触发事件
		 * @param	callback		冷却结束后时候触发事件的相应方法（必须打开触发事件）
		 * @param	xpos	冷却提示显示的X位置
		 * @param	ypos	冷却提示显示的y位置
		 * @param	parent	添加到的父级
		 * @param	del		冷却完成之后的强弱删除
		 */
		public function setCD(id:int,info:String='',obj:*=null,isShowSpeed:Boolean=true,isListener:Boolean=false,callback:Function=null,xpos:uint=216,ypos:uint=16,parent:*=null,del:Boolean=false):void
		{
			if(CDList==null) CDList = new Vector.<int>;
			var cdshower:CDShower = new CDShower(obj,isListener,callback,isShowSpeed,del);
			cdshower.x = isShowSpeed?(xpos-12):xpos; cdshower.y = ypos;
			//if(obj!=null) cdshower.y = obj.y - 42;
			
			cdshower.CDid = id;
			cdshower.CDInformat = info;
			
			CDCenter.my.getCDInfo(cdshower);
			if(CDCenter.my.getCD(id)>=0) 
			{
				if(parent) parent.addChild(cdshower);
				else _content.addChild(cdshower);
			}
			cleanCD=cdshower;
			CDList.push(id);
			if(isListener && callback!=null) CDCenter.my.addEventListener('CD_OVER'+ id, callback);
		}
		
		public function cleancdshower():void
		{
		
				
		}
		/**
		 *点击帮助文档 
		 * @param id
		 * 
		 */		
		public function onHelp(id:uint=0):void
		{
			
		}
		
		public function get Datahtml():Array
		{
			return _Datahtml;
		}
		public function tojiexi(e:Event):void
		{
			var sysy:String=e.target.data ;
			//放每个开始的位子
			var endArr:Array=new Array();
			var endNum:int=0;
			//放每个结束的位子
			var starArr:Array=new Array();
			var starNum:int=0;
			var ClassArr:Array=new Array();
			var ClassSTar:int=0;
			var IdArr:Array=new Array();
			var title:Array=new Array();
			var titleStar:int=0;
			var titleEnd:int=0;
			//装继续好的一条条帮助
			_Datahtml=new Array();
			//数据解析 取出所有的元素的开始的NUM跟结尾的NUM（第几个）
			for(var i:int=0;i<sysy.length;i++)
			{
				var tt:String=sysy.charAt(i);
				if(sysy.charAt(i)=="<")
				{
					endNum++;
					if(endNum%2==1&&endNum>1)
					{
						endArr.push(i);
					}
					
				}
				if(sysy.charAt(i)==">")
				{
					starNum++
					if(starNum%2==0&&starNum<sysy.length)
					{
						starArr.push(i);
					}
					
				}
				if(sysy.charAt(i)=="'")
				{
					ClassSTar++;
					if(ClassSTar-2>0&&(ClassSTar-3)%6==0)
					{
						ClassArr.push(sysy.charAt(i+1));
					}
					if(ClassSTar>0&&(ClassSTar-1)%6==0)
					{
						if(sysy.charAt(i+2)=="'")
						{
							IdArr.push(int(sysy.charAt(i+1)));
						}
						else IdArr.push(int(sysy.charAt(i+1)+sysy.charAt(i+2)));
					}
					if((ClassSTar-5)%6==0)
					{
						var tileStr:String="";
						for(var len:int=i+1;sysy.charAt(len)!="'";)
						{
							tileStr+=sysy.charAt(len);
							len++;
						}
						title.push(tileStr)	;
						
					}
				}
			}	
			for (i=0;i<starArr.length-1;i++)
			{
				var ee:String="";
				var ob:Object={id:"123",_class:"1",title:"123",string:"aa" };
				for(var num:int=starArr[i]+1;num<endArr[i];num++)
				{
					ee=ee+sysy.charAt(num);
					
				}
				ob={id:IdArr[i],_class:ClassArr[i],tilte:title[i],string:ee };
				SanguoGlobal.Configer.Datahtml.push(ob);
			}
			
		}
		
		
	}
}
package
{
	import CCUICoponent.D5IVfaceButton;
	import CCUICoponent.D5MirrorBox;
	import CCUICoponent.D5MirrorLoop;
	import CCUICoponent.D5Table;
	
	import com.net.CallbackLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import stuff.ResourcePool;
	
	/**
	 * 全局通用
	 */ 
	public class SanguoGlobal
	{
		public static var loadCommandList:Dictionary=new Dictionary();
		public static var resourcePool:ResourcePool=new ResourcePool();
		
		public function SanguoGlobal()
		{
			
		}

		

		
		/**
		 * 自动加载外部图片数据到资源池，并自动回叫对应函数
		 * @param	url			外部图片的URL地址
		 * @param	resname		资源池中的资源名
		 * @param	callback	回叫函数
		 * @param	workType    加载的资源类型
		 * @param	loadType    是否后台加载
		 */
		public static function loadResource2Pool(url:String,resname:String,callback:Function,workType:uint=0,loadtype:Boolean=false):void
		{
			if(loadtype==false) {			
				//			trace("xx",url,loadtype);
			}
			if(SanguoGlobal.resourcePool.getResource(resname)!=null)
			{
				callback();
				return;
			}
			// 检查该资源是否正在加载
			if(loadCommandList[url]!=null)
			{
				(loadCommandList[url] as Vector.<Function>).push(callback);
				//trace("[重复加载资源"+url+"，自动跳过，进入自动呼叫状态]");
				return;
			}
			else loadCommandList[url] = new Vector.<Function>;
			
			var loader:CallbackLoader = new CallbackLoader();
			loader.url = url;
			loader.name = resname;//trace(resname,url,'addtores');
			loader.callback = callback;
			loader.workType = workType;
			loader.loadType=loadtype;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadResource2PoolComplate);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadResourceError);
			loader.load(new URLRequest(url)); 
			
		}
		private static function onLoadResourceError(e:IOErrorEvent):void
		{
			
			var loader:CallbackLoader = (e.target as LoaderInfo).loader as CallbackLoader;
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoadResourceError);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadResource2PoolComplate);
			
			trace("[无法加载文件："+loader.url+"]");

			if(loader.callback!=null) loader.callback();
			
			var com:Vector.<Function> = loadCommandList[loader.url];
			if(com!=null)
			{
				for each(var fun:Function in com)
				{
					if(fun!=null) fun();
				}
				
				delete loadCommandList[loader.url];
			}
			loader = null;
			
		}
		/**
		 * 读取完成后的数据处理
		 */ 
		private static function onLoadResource2PoolComplate(e:Event):void
		{   
			var loader:CallbackLoader = (e.target as LoaderInfo).loader as CallbackLoader;
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoadResourceError);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadResource2PoolComplate);
			//				trace("xxx",loader.url);
			if(loader.workType!=6){
				if((loader.content as Bitmap)==null) throw new Error("外部加载只支持图片资源！当前加载的文件类型是："+loader.contentLoaderInfo.contentType);
				var bitmap:BitmapData = (loader.content as Bitmap).bitmapData.clone();
			}
			//			Debug.trace('加载到了',loader.url,Loadlist.my.lock,loader.loadType);
			switch(loader.workType)
			{
				case 0:
					if(loader.loadType==false||loadCommandList[loader.url].length>0){
						SanguoGlobal.resourcePool.addResource(loader.name,bitmap);
					}
					if(loader.callback!=null) loader.callback();
					break;
				case D5IVfaceButton.TYPEID:
					var res:Vector.<BitmapData> = D5IVfaceButton.makeResource(bitmap);
					if(loader.loadType==false||loadCommandList[loader.url].length>0){
						SanguoGlobal.resourcePool.addResource(loader.name,res);
					}
					if(loader.callback!=null) loader.callback();
					break;
				case D5MirrorBox.TYPEID:
					var sizex:uint = 16;
					var sizey:uint = 16;
					var res0:Vector.<BitmapData> = D5MirrorBox.makeResource(
						bitmap,
						new Rectangle(0,0,sizex,sizey),
						new Rectangle(sizex,0,bitmap.width-sizex,sizey),
						new Rectangle(0,sizey,sizex,bitmap.height-sizey),
						new Rectangle(sizex,sizey,bitmap.width-sizex,bitmap.height-sizey));
					if(loader.loadType==false||loadCommandList[loader.url].length>0){
						SanguoGlobal.resourcePool.addResource(loader.name,res0);
					}
					if(loader.callback!=null) loader.callback();
					break;
				case D5Table.TYPEID:
					var res1:Vector.<BitmapData> = D5Table.makeResource(bitmap,10,40);
					if(loader.loadType==false||loadCommandList[loader.url].length>0){
						SanguoGlobal.resourcePool.addResource(loader.name,res1);
					}
					if(loader.callback!=null) loader.callback();
					break;
				case D5MirrorLoop.TYPEID:
					var res2:Vector.<BitmapData> = D5MirrorLoop.makeResource(bitmap,14,D5MirrorLoop.YLOOP);
					if(loader.loadType==false||loadCommandList[loader.url].length>0){
						SanguoGlobal.resourcePool.addResource(loader.name,res2);
					}
					if(loader.callback!=null) loader.callback();
					break;
				case D5MirrorLoop.TYPEIDX:
					var res3:Vector.<BitmapData> = D5MirrorLoop.makeResource(bitmap,14,D5MirrorLoop.XLOOP);
					if(loader.loadType==false||loadCommandList[loader.url].length>0){
						SanguoGlobal.resourcePool.addResource(loader.name,res3);
					}
					if(loader.callback!=null) loader.callback();
					break;
				case 6:
					//	                Debug.trace("成功加载了swf",loader.url);
					if(loader.callback!=null) loader.callback();
					break;
				default:
					throw new Error("未知的资源处理类型！"+loader.workType);
					break;
			}
			//			Debug.trace('加载到了',loader.url,loader.loadType,Loadlist.my.lock,Loadlist.my.allLock);
			var com:Vector.<Function> = loadCommandList[loader.url];
			if(com!=null)
			{
				for each(var fun:Function in com)
				{
					if(fun!=null) fun();
				}
				
				delete loadCommandList[loader.url];
			}
			loader.unload();
			loader.callback=null;
			if(loader.loadType==false){
				//			Debug.trace("前台加载到了资源",loader.url,Loadlist.my.lock,Loadlist.my.allLock);
			}
			loader=null;
			
		}
		
		/**
		 * 秒数解析为标准时间格式
		 */
		public static function formatTime(t:uint):String
		{
			var sh:String;
			var sm:String;
			var ss:String;
			var h:uint;
			var m:uint;
			var s:uint;
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
		//列出下级的所有树级显示目录
		private static var arr:Array=new Array();
		public static function tree(dis:DisplayObjectContainer,parent:DisplayObjectContainer=null,layer:int=0,num:int=0):void
		{   
			if(arr==null) arr=new Array();
			var str:String="";
			var addStr:String="";
			for(var _num:int=0;_num<layer;_num++)
			{
				if(arr[_num]==false){
					addStr="        ";
				}else {
					addStr="      ||";							
				}
				if(_num==layer-1) addStr="      ||";
				str+=addStr;
			}
			if(layer>0){
				if(num>=dis.parent.numChildren-1){
					arr[layer-1]=false;
				}else{
					arr[layer-1]=true;
				}
			}
//			Debug.trace(str+"==>"+"【"+dis.toString().substring(8,dis.toString().length-1)+"】"+dis.name,dis.mouseEnabled,dis.mouseChildren,layer);
			for(var i:int=0;i<dis.numChildren;i++){
				var child:DisplayObject=dis.getChildAt(i);
				if((child as DisplayObjectContainer)!=null){
					tree(child,dis,layer+1,i);
				}
			}
			if(layer==0) arr=null;
		}
	}
}
package com.net
{
	import com.D5Power.encoder.D5Decoder;
	import com.D5Power.encoder.D5Encoder;
	import com.D5Power.net.D5Socket;
	import com.D5Power.net.D5SocketData;
	import com.D5Power.utils.D5ByteArray;
	import com._486G.utils.ErrorCenter;
	import com.utils.debug.Debug;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class YYSocket extends D5Socket
	{
		public static var delayDir:Object;
		public static var params:Object=new Object();
		private var timer:Timer;
		
		//是否加密
		public static var isEncode:Boolean;
		
		public function YYSocket()
		{
			D5Decoder.headLength=11;
			super();
			
			if(!delayDir) delayDir = new Object();
			if(!timer)
			{
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER, checkDelay);
				timer.start();
			}
		}
		
		private function checkDelay(e:TimerEvent):void
		{
			for(var i:String in delayDir)
			{
				if(int(delayDir[i])<0) continue;
				else delayDir[i] = (int(delayDir[i])+1).toString();
				
//				trace(i,delayDir[i]);
				
				//发送数据超时
				if(int(delayDir[i])>30)
				{
					ErrorCenter.my.addError('#202_'+i);
					if(i!="5"){
					ErrorCenter.my.addErrorLog('error202 '+i+params[i]);
					}
					Debug.error('数据包超时 '+ i);
					
					delayDir[i] = -1;
				}
			}
		}
		
		override protected function init():void
		{
			bottomHandle = new YYSocketBottomHandle(this);
		}
		
		/**
		 * 重新实现Call方法
		 * @param	cmd 	命令
		 * @param	server	服务器标识 3-中心服务器 1-用户服务器 2-战斗服务器 4-测试服务器
		 * 
		 */ 
		public function RYcall(cmd:uint,server:uint=1,...args):void
		{
			if(!this.connected)
			{
				RPGScene.my.msg2('已与服务器断开连接，无法通讯。',okFun,'',1);
				RPGScene.my.msgLab('重连','取消');
				RPGScene.my.msgFun(okFun);
				return;
			}
			
			//运营商接入需求
//			comcode(server);
			
			if(cmd>D5SocketData.COMMAND_LEN)
			{
				trace("无效的命令");
				return;
			}
			
			if(_encoder==null)
			{
				trace('尚未指定编码器');
				return;
			}
			
			// 写入SocketID
			writeInt(0);
			
			var data:D5ByteArray = new D5ByteArray();
			
			/* ------ 服务器段编码开始 ------ */
			data.writeShort(cmd);
			
			/* ------ 生成标志位 ------ */
			var flag:D5ByteArray = new D5ByteArray();
			
			if(server==1) isEncode = false;
			else isEncode = false;
			
			// 是否压缩
			flag.writeBitAt(0,false);
			flag.writeBitAt(1,isEncode);
			
			
			// 服务器ID
			switch(server)
			{
				case 3:
					flag.writeBitAt(2,false);
					flag.writeBitAt(3,true);
					flag.writeBitAt(4,true);
					break;
				case 2:
					flag.writeBitAt(2,false);
					flag.writeBitAt(3,true);
					flag.writeBitAt(4,false);
					break;
				case 1:
					flag.writeBitAt(2,false);
					flag.writeBitAt(3,false);
					flag.writeBitAt(4,true);
					break;
				case 4:
					flag.writeBitAt(2,true);
					flag.writeBitAt(3,false);
					flag.writeBitAt(4,false);
					break;
				case 5:
					flag.writeBitAt(2,true);
					flag.writeBitAt(3,false);
					flag.writeBitAt(4,true);
					break;
			}
			
			
			// 本地ID（000）
			flag.writeBitAt(5,false);
			flag.writeBitAt(6,false);
			flag.writeBitAt(7,false);
			

			/* ------ 参数段编码开始 ------ */
			
			var body:D5ByteArray = new D5ByteArray();
			var keyleng:uint;
			if(args.length>0)
			{
				// 有数据发送
				_encoder['_'+cmd.toString(16)](body,args);
				
				keyleng = data.length;
				//加key
				if(cmd!=0x6&&cmd!=0xc&&cmd!=0xd&&cmd!=0xe){
					body.writeUTFBytes(SanguoGlobal.Configer._key);
				}
				data.writeUnsignedInt(body.length+11); // 协议头11字节
			}else{
				data.writeUnsignedInt(11);
			}
			
			data.writeBytes(flag);

			if(isEncode)
			{
				//数据部分加密
				body = XXTEA.Encode(body);
			}
			if(args.length>0) data.writeBytes(body);

			/* ------ 编码结束，发送并清空临时数据 ------ */
			//trace('发送数据包ID = '+cmd.toString(16));
			
			//添加操作记录
			ErrorCenter.my.addError('#100_'+cmd.toString(16),1);
			Debug.trace('发送数据包ID = '+cmd.toString(16)+'服务器ID==>>'+server+'参数==>>',args,SanguoGlobal.Configer._key);
			
			var $str:String=CmdToZhCN.id2name[cmd.toString(16)];
			if($str!=null) Debug.log($str);
			
			writeBytes(data);
			flush();
			data.clear();
			
			delayDir[cmd.toString(16)] = 0;
			params[cmd.toString(16)]="";
			for each(var ob:Object in args)
			{
				params[cmd.toString(16)]+=" "+ob.toString();
			}
		}
		
		private static var _isfirst:int;
		
		/**
		 * test
		 */
		public function testCall(str:String):void
		{
			var data:D5ByteArray = new D5ByteArray();
			data.writeMultiByte(str,"GBK");
			
			writeBytes(data);
			flush();
			data.clear();
		}
		
		/**
		 * 运营商接入需求
		 */
		public function comcode(server:int):void
		{
			switch(SanguoGlobal.Configer.config.comcode.toString().toLowerCase())
			{
				case 'qq':
					QQcomcode(server);
					break;
				default:break;
			}
		}
		
		private function QQcomcode(server:int):void
		{
			//QQ开放平台
			if(server==SanguoGlobal.SERVER_LOGIN) testCall("tgw_l7_forward\r\nHost: "+SanguoGlobal.Configer.config.server+":"+SanguoGlobal.Configer.config.loginport+"\r\n\r\n");
			else if(server==SanguoGlobal.SERVER_USER&&!_isfirst) 
			{
				_isfirst = -1;
				testCall("tgw_l7_forward\r\nHost: "+SanguoGlobal.Configer.config.server+":"+SanguoGlobal.Configer.config.userport+"\r\n\r\n");
				
			}
		}
		private function okFun(data:*):void
		{
			navigateToURL(new URLRequest("javascript:window.location.reload(false)"),"_self");
		}
	}
}
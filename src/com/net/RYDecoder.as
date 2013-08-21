package com.net
{
	import com.D5Power.encoder.D5Decoder;
	import com.D5Power.mission.MissionChecker;
	import com.D5Power.utils.D5ByteArray;
	import com._486G.Scene.*;
	import com._486G.Scene.Operations.*;
	import com._486G.Window.*;
	import com._486G.ns.NSArea;
	import com._486G.ns.NSNet;
	import com._486G.stuff.CDShower;
	import com._486G.stuff.GenOperationXX;
	import com._486G.stuff.GenOperationZJ;
	import com._486G.stuff.JJCRwdBlock;
	import com._486G.stuff.Loadlist;
	import com._486G.stuff.NPCDailog;
	import com._486G.stuff.NocticeMovie;
	import com._486G.stuff.SearchName;
	import com._486G.stuff.ShowMsg;
	import com._486G.stuff.SoundButton;
	import com._486G.stuff.SpecilNotice;
	import com._486G.ui.FollowUI;
	import com._486G.ui.WinBox;
	import com._486G.ui.XWindow;
	import com._486G.ui.content.wujiang.ZhuangBei;
	import com._486G.ui.content.wujiang.Zuanyan;
	import com._486G.utils.*;
	import com.utils.debug.Debug;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.controls.List;

	use namespace NSNet;
	use namespace NSArea;
	//use namespace NSoperation;
	
	public class RYDecoder extends D5Decoder implements IEventDispatcher
	{
		private var _scene:BaseScene;
		private var nextStep:Function
		private var _newWIN:XWindow;
		private var cwin:ShowMsg;
	
		private var dispatcher:EventDispatcher;
		public function RYDecoder()
		{
			dispatcher = new EventDispatcher(this);
			super();
		}
		
		public function set scene(s:BaseScene):void
		{
			if(_scene!=null && s!=null) throw new Error("目前的scene正在使用中，请确认断开引用后再定义新的scene");
			_scene = s;
		}
		
		public function _5(buffer:D5ByteArray):void
		{
			if(SanguoGlobal.socket==null) return;
			SanguoGlobal.socket.RYcall(0x0005,SanguoGlobal.SERVER_CENTER);
		}
		
		/**
		 * 登录
		 */
		public function _6(buffer:D5ByteArray):void
		{
			Debug.trace('06包已接收！');
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,1);
			var uid:int = buffer.readUnsignedInt();
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,2);
			if(uid==0)
			{
				RPGScene.my.msg('服务器验证失败！返回错误代码：'+uid);
				return;
			}
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,3);
			var fcm:uint = buffer.readUnsignedByte();
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,5);
			var country:uint = buffer.readUnsignedByte();
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,6);
			var center:uint = buffer.readUnsignedShort();
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,7);
			var citypos:uint = buffer.readUnsignedInt();
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,8);
			var city:uint = buffer.readUnsignedInt(); // 城池ID，与用户ID相同，暂时不使用
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,9);
			var loginTime:uint = buffer.readUnsignedInt();
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,10);
			var canChat:uint = buffer.readUnsignedInt();
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,11);
			SanguoGlobal.Configer._key=buffer.readUTFBytes(32);
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,12);
			trace('key==',SanguoGlobal.Configer._key);
			SanguoGlobal.Configer._key=SanguoGlobal.Configer._key.substr(0,8);
			// 确认是登录界面
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,4);
			if(!_scene is LoginScene) return;
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,13);
			if(loginTime>0 && uid==-1)
			{
				RPGScene.my.msg2("您的账户被管理员锁定，解锁时间还有"+loginTime+"秒",null,'账户锁定');
				return;
			}
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,14);
			if(uid<0)
			{
				RPGScene.my.msg2("服务器人数已满!",null,'停止注册')
				return;
			}
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_LOGIN,15);
			SanguoGlobal.userdata = new UserData(uid);
			SanguoGlobal.comdata = new ComData();
			SanguoGlobal.userdata._citypos = citypos;
			SanguoGlobal.userdata._country = country;
			SanguoGlobal.userdata._province = center;
			SanguoGlobal.userdata._fcm = fcm;
			SanguoGlobal.userdata._canChat = canChat;
			
//			Debug.trace('===',uid,fcm,country,center,citypos,city,loginTime,canChat);
			
			if(int(SanguoGlobal.Configer.config.allowbuild)==-254)
			{
				(_scene as LoginScene).gotoCreatePlayer();
				return;
			}
			
			if(country==0)
			{
				RPGScene.my.loadComplete = 0;
				// 未创建账户
				(_scene as LoginScene).gotoCreatePlayer();
			}else if(WorldCityScene.ctrydie[country]==1){
				//灭国
				RPGScene.my.loadComplete = 0;
				RPGScene.my.wait_enter_scene = RPGScene.SCENE_ESTAB;
				RPGScene.my.enterGame();
			}else{
				(_scene as LoginScene).gotoEnterGame();
			}
			SanguoGlobal.LoginInuse=false;
		}
		
		public function _7(buffer:D5ByteArray):void
		{ 
			RPGScene.my.closeWait();
			
			var uid:int = buffer.readInt();
			if(uid < 0)
			{
				if(uid != -11) RPGScene.my.msg(Mather._0(uid));
				else RPGScene.my.msg('创建失败'); 
				return;
			}
			var country:uint = buffer.readUnsignedByte();
			var prov:uint = buffer.readUnsignedShort();
			var citypos:int = buffer.readInt();
			var city:uint = buffer.readUnsignedInt();
			
			
			if(!_scene is EstablishScene) return;
			
			SanguoGlobal.userdata._citypos = citypos;
			SanguoGlobal.userdata._country = country;
			SanguoGlobal.userdata._province = prov;
			
			(_scene as EstablishScene).enterGame();
		}
		
		/**
		 * 用户详细信息 登录序列包（初次运行）
		 * 8 >> 15 >> a002 >> a000 >> d050 >> c002 >> ce02 >> cf02 >> ff00 >> e000 >> b003 >> b004 >> b01d >> b620 >> b500 >> d021(并列6001)
		 */ 
		public function _8(buffer:D5ByteArray):void
		{
			trace('08包已接收！');
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_USER,19);
			SanguoGlobal.userdata._gold = buffer.readUnsignedInt();
			SanguoGlobal.userdata._food = buffer.readUnsignedInt();
//			if(Sanguo.my.UI.checkComcode('qq')) var _rmb:int = buffer.readUnsignedInt();
//			else SanguoGlobal.userdata._rmb = buffer.readUnsignedInt();
			SanguoGlobal.userdata._rmb = buffer.readUnsignedInt();
			SanguoGlobal.userdata._exp = buffer.readUnsignedInt();
			SanguoGlobal.userdata._inTime = buffer.readUnsignedInt();
			SanguoGlobal.userdata._proTime = buffer.readUnsignedInt();
			SanguoGlobal.userdata._fightPoint = buffer.readUnsignedInt();
			SanguoGlobal.userdata._farmExp = buffer.readUnsignedInt();
			SanguoGlobal.userdata._scienExp = buffer.readUnsignedInt();
			SanguoGlobal.userdata._bussExp = buffer.readUnsignedInt();
			SanguoGlobal.userdata._wallExp = buffer.readUnsignedInt();
			SanguoGlobal.userdata._peop = buffer.readUnsignedInt();
			SanguoGlobal.userdata._solid = buffer.readUnsignedInt();
			SanguoGlobal.userdata._createTime = buffer.readUnsignedInt();
			SanguoGlobal.userdata._killPoint = buffer.readUnsignedInt();
			SanguoGlobal.userdata._cityLv = buffer.readByte();
			SanguoGlobal.userdata._peopLike = buffer.readUnsignedShort();
			SanguoGlobal.userdata._accountType = buffer.readUnsignedShort();
			SanguoGlobal.userdata._genid = buffer.readUnsignedShort();
			var office:int=buffer.readUnsignedShort();
//			SanguoGlobal.userdata._office = buffer.readUnsignedShort();
			SanguoGlobal.userdata._headid = buffer.readUnsignedInt();
			SanguoGlobal.userdata._identity = buffer.readUnsignedByte();
			SanguoGlobal.userdata._vip = buffer.readUnsignedByte();
			SanguoGlobal.userdata._Recharge= buffer.readUnsignedInt();
			SanguoGlobal.userdata._packageUnlock = buffer.readUnsignedByte();
			SanguoGlobal.userdata._nickName = buffer.readUTFBytes(30);
//			SanguoGlobal.socket.RYcall(0x1111,SanguoGlobal.SERVER_USER,20);
			trace(SanguoGlobal.userdata.rmb,SanguoGlobal.userdata.gold,SanguoGlobal.userdata.food,SanguoGlobal.userdata.exp,SanguoGlobal.userdata.peop);
			
			if(SanguoGlobal.userdata.cityLv<1) SanguoGlobal.userdata._cityLv = 1;
			if(SanguoGlobal.userdata.cityLv>8) SanguoGlobal.userdata._cityLv = 8;
            if(LoginScene.socket!=null&&SanguoGlobal.LoginInuse==false) //清除登录的socket
			{
				LoginScene.socket.close();
				LoginScene.socket=null;
			}
			SanguoGlobal.userdata._gen_limit=Mather._15(SanguoGlobal.userdata.vip);
			
			if(RPGScene.firstRun==-1 || RPGScene.firstRun!=SanguoGlobal.userdata.cityLv)
			{
				
				if(RPGScene.firstRun==-1)
				{

					//SanguoGlobal.socket.RYcall(0xa002,SanguoGlobal.SERVER_USER);
					SanguoGlobal.socket.RYcall(0x0015,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);

					return;
				}
				
				updateCity();
				return;
			}else{ 
				//if((_scene as MyCityScene)!=null) (_scene as MyCityScene).startBuild();

				//Sanguo.my.UI.timelist();
				
//				//更新开仓
//				if(_scene as MyCityScene != null || (_scene as MyCityScene).Operation as MJOperation != null)
//				{
//					((_scene as MyCityScene).Operation as MJOperation).reKaicang();
//				}
			}
			//获取爵位
			SanguoGlobal.socket.RYcall(0x6300,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			RPGScene.my.updateGenList();
			//更新左上角用户基本信息
			_scene.sanguo.UI.updateUserinfo();
			_scene.sanguo.UI.updateCityinfo();
			makeEvent(0x0008);
			//SanguoGlobal.socket.RYcall(0xd006,SanguoGlobal.SERVER_USER,10);
			//trace('返回数据：',SanguoGlobal.userdata.uid,gold,food,money,exp,inTime,proTime,fightPoint,farmExp,scienExp,bussExp,wallExp,peop,solid,createTime,killPoint,cityLv,peopLike,accountType,genid,office);
        
		}
		private var firstGetSysTime:Boolean=true;
		/**
		 * 获取服务器时间
		 */
		public function _b(buff:D5ByteArray):void
		{
			var time:uint = buff.readUnsignedInt();

			CDCenter.my.$systemTime = time;
//			var day:int=new Date(time*1000).getDay();
			if(firstGetSysTime)
			{
				firstGetSysTime=false;
				RPGScene.my.UI.refrashTopIcon();
			}
		}
		
		/**
		 * 广播聊天
		 */
		public function _c(buff:D5ByteArray):void
		{
			var uid:int = buff.readInt();
			//地区=1
			var chanle:uint = buff.readByte();
			var name:String = buff.readUTFBytes(30);
			var chat:String = buff.readUTFBytes(buff.bytesAvailable);
			Debug.trace('chat==||',name,'||',chat);
			var msg:String = SanguoGlobal.textFilter.Replacer(chat,false,0);
			msg=msg.replace("COLOR=\"#000000\"","COLOR=\"#FFCC33\"");
			if(SanguoGlobal.GMLIST==null||RPGScene.my.UI==null||RPGScene.my.UI.uiChatbox==null) return;
			if(SanguoGlobal.GMLIST.indexOf(uid.toString()) != -1)
			{
				RPGScene.my.UI.uiChatbox.addMsg("<font color='#e91313'>ＧＭ&gt;</font><a href='event:"+ name +"'><font color='#CC66FF'>"+ name +"</font></a>:"+chat,-1);
				return;
			}
			if(chanle == 1) 
			{
				if(!RPGScene.my.UI.uiChatbox.unlock[1]) RPGScene.my.UI.uiChatbox.addMsg("<font color='#01ff84'>地区&gt;</font><font color='#bdfd57'><a href='event:"+ name +"'>"+ name +"</a>:</font><font color='#defeac'>"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg)+"</font>",RPGScene.my.UI.uiChatbox.nameToid('地区'));
				if(!RPGScene.my.UI.uiChatbox.unlock[0]) RPGScene.my.UI.uiChatbox.addMsg("<font color='#01ff84'>地区&gt;</font><font color='#bdfd57'><a href='event:"+ name +"'>"+ name +"</a>:</font><font color='#defeac'>"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg)+"</font>",RPGScene.my.UI.uiChatbox.nameToid('国家'));
				if(!RPGScene.my.UI.uiChatbox.unlock[3]) RPGScene.my.UI.uiChatbox.addMsg("<font color='#01ff84'>地区&gt;</font><font color='#bdfd57'><a href='event:"+ name +"'>"+ name +"</a>:</font><font color='#defeac'>"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg)+"</font>",RPGScene.my.UI.uiChatbox.nameToid('世界'));
				
			}else{
				if(!RPGScene.my.UI.uiChatbox.unlock[0]) RPGScene.my.UI.uiChatbox.addMsg("<font color='#01c0ff'>国家&gt;</font><font color='#3583f8'><a href='event:"+ name +"'>"+ name +"</a>:</font><font color='#b9d5ff'>"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg)+"</font>",RPGScene.my.UI.uiChatbox.nameToid('国家'));
				if(!RPGScene.my.UI.uiChatbox.unlock[3]) RPGScene.my.UI.uiChatbox.addMsg("<font color='#01c0ff'>国家&gt;</font><font color='#3583f8'><a href='event:"+ name +"'>"+ name +"</a>:</font><font color='#b9d5ff'>"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg)+"</font>",RPGScene.my.UI.uiChatbox.nameToid('世界'));
			}
			
		}
		
		/**
		 * 私聊
		 */
		public function _d(buff:D5ByteArray):void
		{
			var uid:uint = buff.readUnsignedInt();
			var name:String = buff.readUTFBytes(30);
			var uname:String = buff.readUTFBytes(30);
			var chat:String = buff.readUTFBytes(buff.bytesAvailable);
			
			var msg:String = SanguoGlobal.textFilter.Replacer(chat,false,0);
			
			//if(!Sanguo.my.UI.uiChatbox.unlock[2]) Sanguo.my.UI.uiChatbox.addMsg("<font color='#FF33FF'>密&gt;<a href='event:"+ uname +"'><font color='#CC66FF'>"+ uname +"</font></a>:"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg) +"</font>",-1);
			if(!RPGScene.my.UI.uiChatbox.unlock[2]) RPGScene.my.UI.uiChatbox.addMsg("<font color='#d0b1fe'><a href='event:"+ uname +"'><font color='#9752fd'>"+ uname +"</font></a>&gt;密:"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg) +"</font>\n",-1);
		}
		
		/**
		 * 全屏喊话
		 */
		public function _e(buff:D5ByteArray):void
		{
			var uid:uint = buff.readUnsignedInt();
			var name:String = buff.readUTFBytes(30);
			var chat:String = buff.readUTFBytes(buff.bytesAvailable);
			Debug.trace('chat==|||',name,'||',chat);
			var msg:String = SanguoGlobal.textFilter.Replacer(chat,false,0);
			msg=msg.replace("COLOR=\"#000000\"","COLOR=\"#FFCC33\"");
			try
			{
				if(SanguoGlobal.GMLIST.indexOf(uid.toString()) != -1)
				{
					RPGScene.my.UI.uiChatbox.addMsg("<font color='#e91313'>ＧＭ&gt;</font><a href='event:"+ name +"'><font color='#CC66FF'>"+ name +"</font></a>:"+chat,-1);
					return;
				}
				
				if(!RPGScene.my.UI.uiChatbox.unlock[3]) RPGScene.my.UI.uiChatbox.addMsg("<font color='#fd5118'>世界&gt;</font><font color='#fda240'><a href='event:"+ name +"'>"+ name +"</a>:</font><font color='#fdd4a9'>"+ (SanguoGlobal.Configer.checkshow(chat)?chat:msg)+"</font>",RPGScene.my.UI.uiChatbox.nameToid('世界'));
			}catch(e:Error){}
		}
		
		private function checkbar(s:String):String
		{
			if(s.substr(s.length-2,2)!='\n') return s+'\n';
			
			return s;
		}
		
		/**
		 * 人口统计
		 */
		public function _f(buff:D5ByteArray):void
		{
			var wei:uint = buff.readUnsignedInt();
			var shu:uint = buff.readUnsignedInt();
			var wu:uint = buff.readUnsignedInt();
			var _wei:int=buff.readUnsignedInt();
			var _shu:int=buff.readUnsignedInt();
			var _wu:int=buff.readUnsignedInt();
			var arr:Array = [0,0,0];
			trace("peopleNum===",wei,shu,wu,_wei,_shu,_wu);
			(_scene as EstablishScene).Commend([wei,shu,wu],[_wei,_shu,_wu]);

			
//			if((_scene as EstablishScene) == null) return;
//			(_scene as EstablishScene).Commend(arr,[_wei,_shu,_wu]);
		}
		/**
		 * 用户检索
		 */ 
		public function _10(buff:D5ByteArray):void
		{
			//4字节 记录总数
			var  reNum:uint=buff.readUnsignedInt();
			//1字节 最大记录数字
			var max:uint=buff.readByte();
			if(reNum<max)
			{
			 //1字节 当前页码
			 var nowPage:uint=buff.readByte();
			 //2字节 本次返回记录总数
			 var nowNum:uint=buff.readShort();
				for(var i:uint=0;i<nowNum;i++)
				{
				//4字节 用户ID
					var uid:uint=buff.readUnsignedInt();
				//30字节 用户昵称
					var uname:String=buff.readUTFBytes(30);
				//4字节 用户等级
					var ulv:uint=buff.readInt();
				//4字节 用户威望
					var uwei:uint=buff.readInt();
				}
				
				
			}else
			{
				return;
			}
			
		}
		/**
		 * 特殊事件公告
		 */
		public function _11(buff:D5ByteArray):void
		{
			var id:int = buff.readByte();
			var infoA:String = buff.readUTFBytes(30);
			var infoB:String = buff.readUTFBytes(30);
			var infoC:uint = buff.readUnsignedInt();
			var infoD:uint = buff.readUnsignedInt();
			var infoE:uint = buff.readUnsignedInt();
			var infoF:uint = buff.readUnsignedInt();
			
			var _infoC:String;
			var _infoD:String;
			var _infoE:String;
			var _infoF:String;

			switch(id)
			{
				case 1:
					_infoC = infoC.toString();
					_infoD = infoD.toString();
					_infoE = infoE.toString();
					_infoF = infoF.toString();
					break;
				case 4:
					_infoC = Mather._7(infoC);
					break;
				case 6:
					_infoC = Mather._1(infoC);
					if(infoB=='') infoB = Mather._13(infoC);
					break;
				case 8:
					_infoC = Mather._7(infoC);
					if(infoB=='') Mather.getTaishou(infoC);
					break;
				case 9:
					_infoC = Mather._1(infoC);
					_infoD = Mather._1(infoD);
					_infoE = Mather._7(infoE);
					break;
				case 11:
					_infoC = Mather._1(infoC);
					_infoD = Mather._1(infoD);
					_infoE = Mather._7(infoE);
					break;
				case 12:
					_infoC = Mather._1(infoC);
					_infoD = Mather._1(infoD);
					_infoE = Mather._7(infoE);
					break;
				case 14:
					_infoC = Mather._7(infoC);
					_infoD = Mather._1(infoD);
					_infoE = Mather._7(infoE);
					break;
				case 15:
					_infoC = Mather._7(infoC);
					_infoD = Mather._1(infoD);
					_infoE = Mather._7(infoE);
					break;
				case 23:
					_infoC = Mather._1(infoC);
					_infoD = Mather._1(infoD);
					_infoE = Mather._7(infoE);
					_infoF = infoF.toString();
					break;
				case 24:
					_infoC = Mather._1(infoC);
					_infoD = Mather._7(infoD); 
					_infoE = Mather._1(infoE);
					_infoF = Mather._7(infoF);
					break;
				case 27:
					_infoC = infoC.toString();
					break;
				case 28:
					//武将ID  infoC
					if(infoC>=SanguoGlobal.Configer.genConfig.length) return;
					var obj:Object = SanguoGlobal.Configer.genConfig[infoC];
					_infoC = obj.general_name;
					_infoD = Mather._10(int(obj.rare_info));
					break;
				case 29:
					_infoC = infoC.toString();//升级
					break;
				case 30:
					_infoC = Mather._7(infoC);
					break;
				case 31:
					//皇帝巡视(C城池ID)
					_infoC = Mather._7(infoC);
					if(infoC==SanguoGlobal.userdata.province) SanguoGlobal.socket.RYcall(0xb620,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					break;
				case 32:
					//太守巡视(C用户ID)
					if(infoC==SanguoGlobal.userdata.uid) SanguoGlobal.socket.RYcall(0xb620,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					break;
				case 33:
					var item:ItemData = SanguoGlobal.userdata.newItem(infoC);
					_infoC = item.name;
					_infoD = Mather._10(item.lv);
					break;
				case 34://拍卖中有人出价
					//infoA,出价人昵称
					//infoB,道具id
					//infoC,道具在数据库中的索引id
					//infoD,所出价格
					//infoE,出价时距离现在的秒数
					//infoF,状态，3 拍卖已经结束 1 有人新出价 2 3分钟倒计时已经到了  4.表示竞拍活动开始
					makeEvent(0x11,[infoA,infoB,infoC,infoD,infoE,infoF]);//
					trace('拍卖广播||',infoA,infoB,infoC,infoD,infoE,infoF);
					return;
					break;
				default:break;
			}
//			var arr:Array = [1,6,8,26];
//			if(arr.indexOf(id)>=0) SanguoGlobal.Configer.nowFightNotice = [id,[infoA,infoB,_infoC,_infoD,_infoE,_infoF]];
//			else NocticeMovie.my.play(id,[infoA,infoB,_infoC,_infoD,_infoE,_infoF]);
			if(id==1){
			ErrorCenter.my.addErrorLog("error105"+infoA+infoB+_infoC+_infoD+_infoE+_infoF);
			trace('特殊公告奖励','A:'+infoA,'B:'+infoB,'C:'+_infoC,'D:'+_infoD,'E:'+_infoE,'F:'+_infoF);
			}
			NocticeMovie.my.play(id,[infoA,infoB,_infoC,_infoD,_infoE,_infoF]);
			
			//国战结束
			if(id==11)
			{
				//发送8号包
				SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				
				return;
				
				if(infoE==SanguoGlobal.userdata.province)
				{
					SanguoGlobal.socket.close();
					
					RPGScene.my.closemsg();
					
					RPGScene.my.msg('都城已被攻破,即将被流放!',okFun);
					RPGScene.my.msgFun(okFun,okFun);
				}
			}
		}
		/**
		*有新战报(广播）
		*/
		public function _30(buff:D5ByteArray):void
		{
			var _a_id:int=buff.readInt();//攻击方uid
			var _d_id:int=buff.readInt();//被攻击放uid
			if(ComcodeSceneQQ.my.zhanbao!=null) {
				if(_d_id==SanguoGlobal.userdata.uid)
				{
					var timer:Timer=new Timer(3000);
					if(ComcodeSceneQQ.my.zhanbao!=null){
					SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					timer.addEventListener(TimerEvent.TIMER,refreash1);
					timer.start();
					}
				}
			}
		}
		private function refreash1(e:TimerEvent):void
		{
		  e.target.stop();
		  e.target.removeEventListener(TimerEvent.TIMER,refreash1);
		  ComcodeSceneQQ.my.zhanbao.shrink();
		}
		/**
		 *有新邮件(广播）
		 */
		public function _31(buff:D5ByteArray):void
		{
			var _uid:int=buff.readInt();//邮件
	        if(ComcodeSceneQQ.my.youjian!=null&&_uid==SanguoGlobal.userdata.uid) {
//			Debug.trace('新邮件提醒',email.read);
			    var timer:Timer=new Timer(3000);
				timer.addEventListener(TimerEvent.TIMER,refreash2);
				timer.start();
			}
		}
		private function refreash2(e:TimerEvent):void
		{
			e.target.stop();
			e.target.removeEventListener(TimerEvent.TIMER,refreash2);
			ComcodeSceneQQ.my.youjian.shrink();	
		}
		/**
		 * 定时领奖
		 */
		public function _12(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}else if(result==0){
				//Sanguo.my.msg('领取失败!');
				return;
			}
			
			var totle:uint = buff.readShort();
			
			var arr:Vector.<ItemData> = new Vector.<ItemData>();
			for(var i:uint=0;i<totle;i++)
			{
				var type:int = buff.readUnsignedByte();
				var uid:int = buff.readInt();
				var num:uint = buff.readUnsignedInt();
				var data:ItemData = new ItemData();
				//data._slv = type;
				data._id = uid;
				data._num = num;
				//data._name = SanguoGlobal.Configer.itemConfig[uid].equ_prop_name;
				arr.push(data);
			}
			
			SanguoGlobal.userdata.updatapackage();
			
			RPGScene.my.UI.getPrize(arr,result);
		}
		
		/**
		 * 获取领奖剩余时间
		 */
		public function _13(buff:D5ByteArray):void
		{
			var time:int = buff.readUnsignedInt();
			trace('回包13:'+time,'=================');
			time = time>0?time:0;
			
			RPGScene.my.UI.updataPrize(time);
		}
		
		public function _14(buff:D5ByteArray):void
		{
			RPGScene.my.msgLab('重连','取消');
			RPGScene.my.msg2("您的帐号在其他地方登录！连接断开！",okFun,'',1);
			RPGScene.my.msgFun(okFun,null);
			SanguoGlobal.socket.close();
		}
		
		public function okFun(data:*):void
		{
			navigateToURL(new URLRequest("javascript:window.location.reload(false)"),"_self");
		}
		
		public function _15(buff:D5ByteArray):void
		{
			trace('15包已接收！');
			var time:uint = buff.readByte();
			
			trace("SOCKET REG,Now socket id is",time);
			
			if(time==1)
			{
				SanguoGlobal.socket.RYcall(0xa002,SanguoGlobal.SERVER_USER);
			}
		}
		public function _16(buff:D5ByteArray):void
		{
			var result:int=buff.readByte();
			if(result==1) {
				RPGScene.my.msg('已领到奖励！');
				SanguoGlobal.userdata.updatapackage();
//				ComcodeSceneQQ.my.newGiftBox.gotoAndStop(41);//已打开状态
			}
			else if(result==0){
				RPGScene.my.msg('奖励已领取');
			}
			else if(result==-1)
			{
				RPGScene.my.msg('背包已满,请查收邮件！');
			}
			makeEvent(0x0016,result);
		}
		public function _17(buff:D5ByteArray):void
		{
		    var _type:int=buff.readByte();
//			Sanguo.my.msg('操作类型:'+_type);
			if(_type==1)
			{
			   var _log_day:int=buff.readInt();
			   var _num:int=buff.readByte();
			   var arr:Array=new Array();
			   for(var i:uint=0;i<_num;i++)
			   {
				   var _id:int=buff.readInt();
				   var _num_:int=buff.readInt();
				   arr.push([_id,_num_]);
//				   Sanguo.my.msg('id:',_id,'数量:',_num_);
			   }
			   makeEvent(0x0017,[_log_day,arr]);
			}
			else if(_type==2||_type==4)
			{
				var _result:int=buff.readByte();
				if(_result==1)
				{
					RPGScene.my.msg('领取成功！');
					SanguoGlobal.userdata.updatapackage(); 
				}
				else if(_result==-1){
					RPGScene.my.msg('已经领取过！');
				}
				else if(_result==-2){
				    RPGScene.my.msg('条件不足！');
				}
					var ob:*=WinBox.my.getWindow(LoginReward);
					
					if(ob==null) return;
				    if(_type==2){
						LoginReward.hasgotReward=true;
						ob.bt.enabled=false;
					}else {
						ob.drBt.enabled=false;
						LoginReward.hasgotSpecReward=true;
					}
//				Sanguo.my.msg('操作结果',_result);
			}
			
		}
		/**
		 * 修改个人简介
		 */
		public function _18(buff:D5ByteArray):void
		{
			
		}
		 /**
		 * 查询个人简介
		 */
		public function _19(buff:D5ByteArray):void
		{
			
		}
		public function _1a(buff:D5ByteArray):void
		{
			var _status:int=buff.readByte();//1为开始
//			_status=1;
			trace('开始====',_status);
			Auction.startFlag=(_status==1);
			var num:int=buff.readByte();
			var arr:Array=new Array();
			for(var i:int=0;i<num;i++)
			{
				var idx:int=buff.readInt();
				var dbidx:int=buff.readInt();
				var id:int=buff.readInt();
				var price:int=buff.readInt();
				var _num:int=buff.readInt();
				var uid:int=buff.readInt();
				var status:int=buff.readInt();
				var _leftTime:uint=buff.readInt();
				var _uname:String=buff.readUTFBytes(32);
				arr.push([idx,dbidx,id,price,_num,uid,status,_leftTime,_uname]);
//				trace('idx||',idx,'dbidx',dbidx,'id||',id,'price||',price,'uid||',uid,'_num||',_num,uid,'status||',status,'_leftTime||',_leftTime);
			}
			makeEvent(0x1a,arr);
		}
		
		public function _1b(buff:D5ByteArray):void
		{
			var res:int=buff.readByte();
		    if(res<0)
			{
				RPGScene.my.msg(Mather._0(res));
			}else {
				RPGScene.my.msg('出价成功!');
				UIScene.reset8=true;
				RPGScene.my.UI.updateUserinfo();
			}
		}
		private var jwCnt:int=0;
		/**
		 *取得自己的爵位
		 */
		public function _6300(buff:D5ByteArray):void
		{
			SanguoGlobal.userdata._office = buff.readByte();	
				if(SanguoGlobal.OnPromotJuewei==true){
					if(SanguoGlobal.userdata.office==1&&jwCnt<3)
					{
						SanguoGlobal.socket.RYcall(0x6304,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
						jwCnt++;
					}
					else {
						RPGScene.my.msg("爵位成功提升！");
						SanguoGlobal.OnPromotJuewei=false;
					}
				    
				}
			trace('爵位||',SanguoGlobal.userdata.office,RPGScene.my.loadComplete);
			if(SanguoGlobal.userdata.identity==1&&SanguoGlobal.userdata.office<23)
			{
				SanguoGlobal.userdata._office=23;
			}
			else if(SanguoGlobal.userdata.identity==2&&SanguoGlobal.userdata.office<24)
			{
				SanguoGlobal.userdata._office=24;
			}
			MissionChecker.setKEY('_8',true);
//			if(SanguoGlobal.userdata.identity=0&&SanguoGlobal.userdata.office==0)
//			{
//				SanguoGlobal.userdata._office=1;
//			}
			if(isfirstloadduty)
			{
				SanguoGlobal.socket.RYcall(0x6307,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}
			//更新UI用户信息
			RPGScene.my.UI.uiUserinfo.Duty(SanguoGlobal.userdata.office,isfirstloadduty);
			isfirstloadduty = false;
			//查询妻妾列表
			if(WinBox.my.getWindow(JueweiPromote)==null)
			{
				SanguoGlobal.socket.RYcall(0x6101,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}
			if(Mather._28(SanguoGlobal.userdata.office+1)<=SanguoGlobal.userdata.exp&&SanguoGlobal.userdata.office<20)
			{
				RPGScene.my.UI.uiUserinfo.dutyBg.play();
			}
			else RPGScene.my.UI.uiUserinfo.dutyBg.gotoAndStop(2);
			
			makeEvent(0x6300);
		}
		private var isfirstloadduty:Boolean=true;
		
		/**
		 *皇帝封的爵位列表
		 */
		public function _6301(buff:D5ByteArray):void
		{
			var len:int = buff.readByte();

			var arr:Array;
			
			var dataArr:Array = new Array();
			for(var i:uint=0;i<len;i++)
			{
				arr=new Array();
				arr.push(buff.readUnsignedInt());
				arr.push(buff.readUTFBytes(30));
				arr.push(buff.readByte());
				arr.push(buff.readUnsignedInt());
				arr.push(buff.readUnsignedInt());
				trace("office:======",arr);
				dataArr.push(arr);
//				Sanguo.my.UI.changeTest(0x6301,''+arr[0].toString()+":"+arr[1]+":"+arr[2]+":"+arr[3]+":"+arr[4]);
			}
			
			makeEvent(0x6301,dataArr);
//			(WinBox.my.getWindow(Juewei) as Juewei).handleData(dataArr);
			trace("0x6301 received");

			//(WinBox.my.getWindow(Juewei) as Juewei).handleData(dataArr);

		}
		/**
		 *皇帝封爵
		 */
		public function _6302(buff:D5ByteArray):void
		{
			
			var result:int = buff.readByte();
//			Sanguo.my.UI.changeTest(0x6302,result.toString());
			if(result==1)
			{
				RPGScene.my.msg('该爵位已被撤销');
				makeEvent(0x6302);
				return;
			}
			if(result==11)
			{
//				if(Juewei.flag) Sanguo.my.msg("封爵成功！");
//				else Sanguo.my.msg("已撤销！");
                RPGScene.my.msg('第一次封爵成功');
				makeEvent(0x6302);
				return;
			}
			else if(result==12)
			{
				RPGScene.my.msg("第二次封爵成功");
				makeEvent(0x6302);
			}
			if(result==-2) {
				RPGScene.my.msg("封爵次数已满");
				return;
			}
			if(result==0)
			{
				throw new Error("皇帝封爵时发生未知错误");
			}
			
		}
		/**
		 *领工资
		 */
		public function _6303(buff:D5ByteArray):void
		{
			var flag:int = buff.readByte();
				makeEvent(0x6303,flag);
		}
		/**
		 *手动升爵位
		 */
		public function _6304(buff:D5ByteArray):void
		{
			var flag:int = buff.readByte();
			if(flag!=0&&flag!=-1){
			makeEvent(0x6304);
			}
			else if(flag==-1) RPGScene.my.msg('不满足升爵条件！');
			else if(flag==0) RPGScene.my.msg('升爵失败！');
		}
		/**
		 *得到最高威望非太守本国用户
		 */
		public function _6305(buff:D5ByteArray):void
		{
			var len:int = buff.readInt();
			SanguoGlobal.Configer.jueweiNum=len;
			var arr:Array;
			var dataArr:Array=new Array();
			for(var i:uint=0;i<(buff.bitLength/8-4)/43;i++)
			{
				arr=new Array();
				arr.push(buff.readInt());
				arr.push(buff.readUTFBytes(30));
				arr.push(buff.readByte());
				arr.push(buff.readInt());
				arr.push(buff.readInt());
				dataArr.push(arr);
//				Sanguo.my.UI.changeTest(0x6305,arr[0]+":"+arr[1]+":"+arr[2]+":"+arr[3]+":"+arr[4]);
				trace("arrxx+++===",arr);
//				trace('xxx',arr[0].toString()+'_'+arr[1].toString()+'_'+arr[2].toString()+'_'+arr[3].toString()+'_'+arr[4].toString());
//				Sanguo.my.msg(arr[0].toString()+'_'+arr[1].toString()+'_'+arr[2].toString()+'_'+arr[3].toString()+'_'+arr[4].toString());
			}
//			makeEvent(0x6305,dataArr);


//			if(WinBox.my.getWindow(JueweiSelect)!=null)
//			{
//				(WinBox.my.getWindow(JueweiSelect) as JueweiSelect).show();
//			}
//			makeEvent(0x6305,obj);
			
			makeEvent(0x6305,dataArr);

			
		}
		//喜好品兑换
		public function _6306(buff:D5ByteArray):void
		{
			var result:int=buff.readByte();
			var num:int=buff.readByte(); 
			var arr:Array=new Array();
			if(result<0) return;
			for(var i:uint=0;i<num;i++)
			{
				arr.push(buff.readUnsignedInt());
				arr.push(buff.readUnsignedInt());
			}
			makeEvent(0x6306,arr);
		}
		/**
		 *得到每日目标列表
		 */
		public function _6320(buff:D5ByteArray):void
		{
			var result:int=buff.readByte();
			var sum:uint=buff.readByte();
			var dataArr:Array=new Array();
			dataArr.push(result);
			if(sum==0)
			{
				RPGScene.my.msg('没有需要完成的目标');
			}
			for(var i:uint=0;i<sum;i++)
			{
				var arr:Array=new Array();
		        arr.push(buff.readUnsignedInt());
				arr.push(buff.readUnsignedInt());
				arr.push(buff.readUnsignedInt());
				dataArr.push(arr);
			}
			makeEvent(0x6320,dataArr);
			
		}
		/**
		 * 领取奖励
		 */
		public function _6321(buff:D5ByteArray):void
		{
			var sum:int=buff.readByte();
			var dataArr:Array=new Array();
			dataArr.push(sum);
			if(sum==0)
			{
				RPGScene.my.msg('没有领到奖励');
				return;
			}
			for(var i:uint=0;i<sum;i++)
			{
				var arr:Array=new Array();
				arr.push(buff.readUnsignedInt());
				arr.push(buff.readUnsignedInt());
				dataArr.push(arr);
			}
			makeEvent(0x6321,dataArr);
		}
		/**
		 * 刷新奖励
		 */
		public function _6322(buff:D5ByteArray):void
		{
			var result:int=buff.readByte();
			makeEvent(0x6322,result);
		}
		public function _9000(buff:D5ByteArray):void
		{
			var res:int=buff.readByte();
			if(res<0) 
			{
			RPGScene.my.msg(Mather._0(res));
			return;
			}
			makeEvent(0x9000);
		}
		public function _9001(buff:D5ByteArray):void
		{
			var num:int=buff.readUnsignedByte();
			var arr:Array=[];
			for(var i:int;i<num;i++)
			{
			  var ser_id:int=buff.readUnsignedInt();
			  var u_id:int=buff.readUnsignedInt();
			  var order:int=buff.readUnsignedInt();
			  var user_name:String=buff.readUTFBytes(30);
			  var lv:int=buff.readUnsignedByte();
			  var country:int=buff.readUnsignedByte();
			  arr.push([ser_id,u_id,order,user_name,lv,country]);
			  trace("===9001==="+i,ser_id,u_id,order,user_name,lv,country);
			}
			arr.sort(compare);
			makeEvent(0x9001,arr);
			
		}
		private function compare(arr1:Array,arr2:Array):int
		{
			if(arr1[2]<arr2[2])return -1;
			if(arr1[2]>arr2[2]) return 1;
			return 0;
		}
		public function _9002(buff:D5ByteArray):void
		{
			var res:int=buff.readUnsignedByte();
			if(res==-4) RPGScene.my.msg("挑战冷却中...");
			else if(res==-3) RPGScene.my.msg("次数已经用完");
			else if(res==1) {
				var url:String=buff.readUTFBytes(30);
				var rewardnum:int=buff.readUnsignedByte();
				trace("9002====",rewardnum,url);
				var arr:Array=[];
				for(var i:int=0;i<rewardnum;i++)
				{
					var type:int=buff.readUnsignedShort();
					var id:int=buff.readUnsignedInt();
					var num:int=buff.readShort();
					arr.push([type,id,num]);
				}
				FightScene.isWholePK=true;
				RPGScene.my.changeScene(RPGScene.SCENE_FIGHT,[Mather._6(url),arr]);
				makeEvent(0x9002);
			}
		}
		public function _9004(buff:D5ByteArray):void
		{
			var myorder:int=buff.readUnsignedInt();
			var times:int=buff.readShort();
			var cd:int=buff.readUnsignedInt();
			Debug.trace("9004",myorder,times,cd);
			makeEvent(0x9004,[myorder,times,cd]);
		}
		public function _9006(buff:D5ByteArray):void
		{
			var num:int=buff.readUnsignedInt();
			makeEvent(0x9006,num);
		}
		public function _9008(buff:D5ByteArray):void
		{
			var num:int=buff.readShort();
			var arr:Array=new Array();
			var data:WarReport;
			var list:Vector.<WarReport>=new Vector.<WarReport>();
			for(var i:int=0;i<num;i++)
			{
			data=new WarReport();
		    data._gid=buff.readInt();
		    data._g_svr_id=buff.readInt();
			data._fid=buff.readInt();
		    data._f_svr_id=buff.readInt();
			data._gname=buff.readUTFBytes(30);
			data._fname=buff.readUTFBytes(30);
			data._winer=buff.readInt();
			data._date=buff.readUnsignedInt();
			data._url=buff.readUTFBytes(30);
			list.push(data);
			trace("data===",data.gid,data._g_svr_id,data.fid,data.f_svr_id,data.gname,data.fname,data.date,data.url);
			}
			makeEvent(0x9008,list);
		}
		public function _900a(buff:D5ByteArray):void
		{
			var myorder:int=buff.readUnsignedInt();
			var num:int=buff.readUnsignedInt();
			JJ_all._crossPMnum=num;
			var list:Vector.<JingjiData>=new Vector.<JingjiData>();
			var sum:int=int(buff.bytesAvailable/48);
			for(var i:int;i<sum;i++)
			{
				var data:JingjiData=new JingjiData();
				data.ser_id=buff.readUnsignedInt();
			    data.rank=buff.readUnsignedInt();
			    data.lv=buff.readUnsignedByte();
				data.name=buff.readUTFBytes(30);
				data.country=buff.readUnsignedByte();
				data.shengli=buff.readUnsignedInt();
			    data.total=buff.readUnsignedInt();
				list.push(data);
				trace(i,data.ser_id,data.rank,data.lv,data.name,data.country,data.shengli,data.total);
			}
			makeEvent(0x900a,list);
		}
		public function _900b(buff:D5ByteArray):void
		{
			var num:int=buff.readUnsignedShort();
			var list:Dictionary=new Dictionary();
		    for(var i:int;i<num;i++)
			{
			    var ser_id:int=buff.readUnsignedInt();
				var f_ser_id:int=buff.readUnsignedInt();
				var f_name:String=buff.readUTFBytes(32);
				list[ser_id+"fid"]=f_ser_id;
				list[ser_id+"name"]=f_name;
				trace("900b",ser_id,f_ser_id,f_name);
				
			}
			SanguoGlobal.Configer.ser_list=list;
//			trace("_900b====>",list);
			_900bEnable=false;
			makeEvent(0x900b,list);
		
		}
		/**
		 *本次刷一格奖需要多少元宝
		 */
		public function _6323(buff:D5ByteArray):void
		{
			var num:uint=buff.readUnsignedInt();
			makeEvent(0x6323,num);
		}
		/**
		 * 国家势力占据情况
		 */
		public function _a000(buff:D5ByteArray):void
		{
			var citynum:uint = buff.readUnsignedByte();
			var prov:int;
			var own:uint;
			var owner:uint;
			var peop:uint;

			for(var i:uint = 0;i<citynum;i++)
			{
				prov = buff.readByte();
				own = buff.readUnsignedByte();
				owner = buff.readUnsignedInt();
				peop = buff.readUnsignedInt();
//				trace("<a000>",prov,own,owner,peop);
				if(prov<0||prov >= WorldCityScene.CityList.length || WorldCityScene.CityList[prov]==null) continue;
				
				var data:CityData = new CityData();
				data.id = prov;
				data.owner = owner;
				data.players = peop;
				
				WorldCityScene.CityList[prov].country = own;
				WorldCityScene.CityList[prov].owner=owner;
				WorldCityScene.CityList[prov].players=peop;
			}
			
			if(_scene as WorldCityScene!=null)
			{
				(_scene as WorldCityScene).configCity();
			}else if(_scene as EstablishScene!=null){
				if(!EstablishScene.closeSever) {
					(_scene as EstablishScene).start(WorldCityScene.ctrydie[SanguoGlobal.userdata.country]);//WorldCityScene.ctrydie[SanguoGlobal.userdata.country]
					if(EstablishScene.establisFlag==false&&EstablishScene.moveCountyFlag==false) return;
				}
//				if(WorldCityScene.ctrydie[SanguoGlobal.userdata.country]==1) return;
				if(EstablishScene.closeSever) return;
			}
			
			if(RPGScene.firstRun==-1) SanguoGlobal.socket.RYcall(0xd050,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		
		/**
		 * 三国皇城情况
		 */ 
		public function _a002(buff:D5ByteArray):void
		{
			//每2字节表示一个皇城的名城ID（1-50）
			var cityid:uint;
			var country:uint;
			for(var i:uint = 0;i<3;i++)
			{
				country=buff.readUnsignedByte();
				cityid = buff.readUnsignedByte();
				CityData.HOST[i+1] = cityid;
				trace("host==",CityData.HOST);
			}
			if(RPGScene.firstRun==-1) SanguoGlobal.socket.RYcall(0xa000,SanguoGlobal.SERVER_USER);
		}
		
		
		
		/**
		 * 区域地图城池情况
		 */ 
		public function _aa00(buff:D5ByteArray):void
		{
			//2字节 当前区域的城池个数
			var city_count:uint = buff.readUnsignedShort();
			
			//4字节 当前名城下属总区域个数
			var area_count:uint = buff.readUnsignedInt();
			
			// 当前国家
			var country:uint = buff.readUnsignedByte();
			
			//4字节 城池ID
			var u_id:uint;
			
			var city_pos_id:uint;
			
			//30字节 城池名称
			var city_name:String;
			
			//1字节 城池等级
			var city_level:uint;
			
			var areascene:AreaScene = _scene as AreaScene;
			
			if(areascene) areascene.maxArea = area_count;
			var arr:Array=new Array();
			for(var i:uint = 0;i<city_count;i++)
			{
				u_id = buff.readUnsignedInt();
				city_pos_id = buff.readUnsignedInt();
				city_name = buff.readUTFBytes(30);
				city_level = buff.readUnsignedByte();
                arr.push([u_id,city_pos_id,city_name,city_level]);
			}
			if(areascene!=null)
			{
				areascene.addCity(arr,country);
			}
			
		}
		
		/**
		 * 进入某城池
		 */
		public function _aa01(buff:D5ByteArray):void
		{
			//4字节 城池ID
			var city_uid:int = buff.readInt();
			if(city_uid == -1) return;//进入失败
			
			//1字节 城池等级
			var city_level:uint = buff.readUnsignedByte();
		}
		
		/**
		 * 威望排行榜
		 */
		public function _a004(buff:D5ByteArray):void
		{
			var kind:uint = buff.readUnsignedByte();
			var max:uint = buff.readUnsignedByte()
			var num:uint = buff.readUnsignedByte();
			var mynum:uint = buff.readUnsignedInt();
			SanguoGlobal.Configer.mynum = mynum;
			
			var tab:Array = new Array();
			for(var i:uint=0;i<num;i++)
			{
				var data:Array = new Array();
				
				var uname:String = buff.readUTFBytes(30);
				var lv:uint = buff.readUnsignedInt();
				var ctry:uint = buff.readUnsignedInt();
				var prov:uint = buff.readUnsignedInt();
				var num_wj:uint = buff.readUnsignedInt();
				var num_qq:uint = buff.readUnsignedInt();
				var id_jw:uint = buff.readUnsignedInt();
				var ww:uint = buff.readUnsignedInt();
				
				data.push(uname);
				data.push(lv);
				if(kind!=2) data.push(Mather._7(prov));
				else data.push(Mather._1(ctry));
				data.push(num_wj);
				data.push(num_qq);
				data.push(id_jw);
				data.push(ww);
				tab.push(data);
				
			}
			
			if(WinBox.my.getWindow(PH_all)!=null) 
			{
				var _max:uint = Math.ceil(max/12);
				if(_max == 0) _max = 1;
				((_newWIN=WinBox.my.getWindow(PH_all))as PH_all).reshowTD(tab,kind,_max);
			} 
			makeEvent(0xa004,[tab,max]);
//			if(Sanguo.my.UI.Operation as BottomOperation)
//			{
//				var _max:uint = Math.ceil(max/12);
//				if(_max == 0) _max = 1;
//				(Sanguo.my.UI.Operation as BottomOperation).reshowPH(tab,kind,_max);
//			}
			
		}
		
		/**
		 * 武将排行榜
		 */
		public function _a005(buff:D5ByteArray):void
		{
			if(_scene as MyCityScene == null) return;
			
			
			
			var kind:uint = buff.readUnsignedByte();
			var max:uint = buff.readUnsignedByte()
			var num:uint = buff.readUnsignedByte();
			var mynum:uint = buff.readUnsignedInt();
			SanguoGlobal.Configer.mynum = mynum;
			
			var tab:Array = new Array();
			for(var i:uint=0;i<num;i++)
			{
				var data:Array = new Array();
				
				var name_wj:uint = buff.readUnsignedInt();
				var lv:uint = buff.readUnsignedInt();
				var uname:String = buff.readUTFBytes(30);
				var ctry:uint = buff.readUnsignedInt();
				var prov:uint = buff.readUnsignedInt();
				var yw:uint = buff.readUnsignedInt();
				var zm:uint = buff.readUnsignedInt();
				var ts:uint = buff.readUnsignedInt();
				
				if(name_wj<1000) data.push(SanguoGlobal.Configer.genConfig[name_wj].general_name);
				else data.push(uname);
				data.push(lv);
//				data.push(uname);
				if(kind!=2) data.push(Mather._7(prov));
				else data.push(Mather._1(ctry));
				data.push(yw);
				data.push(zm);
				data.push(ts);
				tab.push(data);
			}
			if(WinBox.my.getWindow(PH_all)!=null) 
			{
				var _max:uint = Math.ceil(max/12);
				if(_max == 0) _max = 1;
				((_newWIN=WinBox.my.getWindow(PH_all))as PH_all).reshowTD(tab,kind,_max);
			}
		}
		
		/**
		 * 城池排行榜
		 */
		public function _a006(buff:D5ByteArray):void
		{
			var kind:uint = buff.readUnsignedByte();
			var max:uint = buff.readUnsignedByte()
			var num:uint = buff.readUnsignedByte();
			var mynum:uint = buff.readUnsignedInt();
			SanguoGlobal.Configer.mynum = mynum;
			
			var tab:Array = new Array();
			for(var i:uint=0;i<num;i++)
			{
				var data:Array = new Array();
				
				var uname:String = buff.readUTFBytes(30);
				var lv:uint = buff.readUnsignedInt();
				var ctry:uint = buff.readUnsignedInt();
				var prov:uint = buff.readUnsignedInt();
				var pro:uint = buff.readUnsignedInt();
				var bus:uint = buff.readUnsignedInt();
				var tec:uint = buff.readUnsignedInt();
				var def:uint = buff.readUnsignedInt();
				
				data.push(uname);
				data.push(lv)
				if(kind!=2) data.push(Mather._7(prov));
				else data.push(Mather._1(ctry));
				data.push(pro);
				data.push(bus);
				data.push(tec);
				data.push(def);
//				data.push(pro+bus+tec+def);
				
				tab.push(data);
			}
			if(WinBox.my.getWindow(PH_all)!=null) 
			{
				var _max:uint = Math.ceil(max/12);
				if(_max == 0) _max = 1;
				((_newWIN=WinBox.my.getWindow(PH_all))as PH_all).reshowTD(tab,kind,_max);
			}
			makeEvent(0xa006,[tab,max]);
//			if(Sanguo.my.UI.Operation as BottomOperation)
//			{
//				var _max:uint = Math.ceil(max/12);
//				if(_max == 0) _max = 1;
//				(Sanguo.my.UI.Operation as BottomOperation).reshowPH(tab,kind,_max);
//			}
		}
		
		/**
		 * 获取当前可处理的常务列表
		 * 4字节 剩余时间
		 * 1字节 剩余常务处理名额
		 * 以下循环
		 * 4字节 常务ID
		 */
		public function _b001(buff:D5ByteArray):void
		{
			var time:int = buff.readInt();
			var num:uint = buff.readUnsignedByte();
			var m:uint = num>0?1:0;
//			trace(time,m,arr,'常务');
			CDCenter.my._cdList[18]=1800-time;
			var arr:Array = new Array();
			for(var i:uint=0;i<m;i++)
			{
				var id:uint = buff.readUnsignedInt();
				arr.push(id);
			}
			SanguoGlobal.Configer.nowChangwuNum = num;
			RPGScene.my.UI.cdBoxPath[RPGScene.my.UI.cdBoxPath.length-1].showNum(num);
			
			makeEvent(0xb001,arr);
			
		}
		
		/**
		 * 处理常务任务
		 */
		public function _b002(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result == 0)
			{
				RPGScene.my.msg('处理失败');
				return;
			}
			var num:uint = buff.readUnsignedByte();//trace('result'+result,'num'+num'============');
			var str:String='';
			for(var i:uint=0;i<num;i++)
			{
				var type:int = buff.readByte();
				var itemid:uint = buff.readUnsignedInt();
				var itemnum:uint = buff.readUnsignedInt();
				var packageid:uint = buff.readUnsignedInt();
//				trace('num'+num,'type'+type,'itemid'+itemid,'itemnum'+itemnum,'packageid'+packageid,'============');
				switch(type)
				{
					case 0:
						//道具
						str += SanguoGlobal.Configer.itemConfig(itemid).equ_prop_name + 'x1' +'\n';
						if(SanguoGlobal.userdata.packageUnown>=SanguoGlobal.userdata.packageUnlock)
						{
							//Sanguo.my.msg('背包已满！请注意查收邮件!');
						}else{
							var newitem:ItemData = SanguoGlobal.userdata.newItem(itemid);
//							newitem._packageid = packageid;
							SanguoGlobal.userdata.addItem(newitem);
						}
						
						break;
					case 1:
						//威望
						SanguoGlobal.userdata._exp = SanguoGlobal.userdata.exp + itemnum;
						str += '威望 +'+ itemnum +'\n';
						MissionChecker.setKEY('_11',true);
						break;
					case 2:
						//战功
						SanguoGlobal.userdata._fightPoint = SanguoGlobal.userdata.fightPoint + itemnum;
						str += '战功 +'+ itemnum +'\n';
						break;
					case 3:
						//民忠
						if(SanguoGlobal.userdata.peopLike + itemnum>100) 
						{
							itemnum = 100 - SanguoGlobal.userdata.peopLike;
						}
						SanguoGlobal.userdata._peopLike = SanguoGlobal.userdata.peopLike + itemnum;
						str += '民忠 +'+ itemnum +'\n';
						break;
					case 4:
						//粮草
						if(SanguoGlobal.userdata.food + itemnum>SanguoGlobal.userdata.food_limit) 
						{
							itemnum = SanguoGlobal.userdata.food_limit - SanguoGlobal.userdata.food;
						}
						SanguoGlobal.userdata._food = SanguoGlobal.userdata.food + itemnum;
						str += '粮食 +'+ itemnum +'\n';
						if(!itemnum) str += '粮食已达上限\n';
						break;
					case 5:
						//银两
						if(SanguoGlobal.userdata.gold + itemnum>SanguoGlobal.userdata.gold_limit) 
						{
							itemnum = SanguoGlobal.userdata.gold_limit - SanguoGlobal.userdata.gold;
						}
						SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold + itemnum;
						str += '银两 +'+ itemnum +'\n';
						if(!itemnum) str += '银两已达上限\n';
						break;
					case 6:
						//经验
						str += '经验 +'+ itemnum +'\n';
						break;
					case 7:
						//行动力
						str += '行动力 +'+ itemnum +'\n';
					default:break;
				}
			}
			MissionChecker.setKEY('_67',true);
			RPGScene.my.msg(str);
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			//Sanguo.my.UI.cdBoxPath[Sanguo.my.UI.cdBoxArr.indexOf(18)].showNum(SanguoGlobal.Configer.nowChangwuNum-1);
			SanguoGlobal.socket.RYcall(0xb001,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		
		/**
		 * 获取我的武将列表
		 */
		public function _b003(buff:D5ByteArray):void
		{
			var num:uint = buff.readUnsignedShort();
			
			var uid:uint;
			var name:String;
			var level:uint;
			var color:uint;

			if(SanguoGlobal.userdata.genList==null) SanguoGlobal.userdata._genList = new Vector.<GenData>;
			
			while(SanguoGlobal.userdata.genList.length)
			{
				SanguoGlobal.userdata.genList.splice(0,1);
			}
			
			for(var i:uint = 0;i<num;i++)
			{
				var data:GenData = new GenData();
				data.gen_id = buff.readUnsignedInt();
				data.gen_name = buff.readUTFBytes(12);
				data.gen_lv = buff.readUnsignedShort();
				data.gen_color = buff.readUnsignedByte();
				data.gen_header = new BitmapData(GenData.HEADER_W,GenData.HEADER_H);
				data.gen_tongyu = buff.readUnsignedInt();
				data.gen_wuli = buff.readUnsignedInt();
				data.gen_zhili = buff.readUnsignedInt();
				data.gen_tongyu_add=buff.readUnsignedInt();
				data.gen_wuli_add=buff.readUnsignedInt();
				data.gen_zhili_add=buff.readUnsignedInt();
				data.gen_job = buff.readUnsignedInt();
				data.gen_exp = buff.readInt();
				data.gen_zhanli = buff.readUnsignedInt();
				data.gen_qianli = buff.readUnsignedInt()/100;
				trace(data.lv,data.name);
				if(data.name=='')
				{
					data.gen_name = SanguoGlobal.userdata.nickName;
				}
				
//				var find:GenData=null;
//				for(var j:uint=0,k:uint = SanguoGlobal.userdata.genList.length;j<k;j++)
//				{
//					if(SanguoGlobal.userdata.genList[j].id==data.id)
//					{
//						find = SanguoGlobal.userdata.genList[j];
//					}
//				}
//				
//				if(find==null)
//				{
//					SanguoGlobal.userdata.genList.push(data);
//					find = data;
//				}else{
//					find.gen_lv = data.lv;
//					find.gen_color = data.color;
//					find.gen_tongyu = data.tongyu;
//					find.gen_wuli = data.wuli;
//					find.gen_zhili = data.zhili;
//					find.gen_tongyu_add=data.tongyu_add
//					find.gen_wuli_add=data.wuli_add;
//					find.gen_zhili_add=data.zhili_add;
//					find.gen_job = data.job;
//					find.gen_exp = data.exp;
//				}
				
				if(data.id>1000){
				data.getDetail();
				} 
				
				SanguoGlobal.userdata.genList.push(data);
			}
			
			if(nextStep!=null)
			{
				nextStep();
				
				nextStep = null;
			}
			
			if(RPGScene.firstRun==-1)
			{
				SanguoGlobal.userdata.updatagenlist();
			}else{
				RPGScene.my.UI.updateUserinfo();
				RPGScene.my.UI.updateCityinfo();
			}
			
			makeEvent(0xb003);
			
			NPCDailog.my.onComplate();
			
			if(_scene as MyCityScene != null)
			{
				if((_scene as MyCityScene).Operation as JGOperation != null) 
				{
					
					((_scene as MyCityScene).Operation as JGOperation).uplist();
				}
			}
			
			for each(var _data:GenData in SanguoGlobal.userdata.genList)
			{
				if(_data.id == SanguoGlobal.Configer.nowGenid)
				{
					if(SanguoGlobal.Configer.nowGenOperation as GenOperationXX == null) return;
					(SanguoGlobal.Configer.nowGenOperation as GenOperationXX).setupGen();
					(SanguoGlobal.Configer.nowGenOperation as GenOperationXX).genD(_data);
				}
			}
			
			//SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);

		}
		
		/**
		 * 获取我的武将的详细信息
		 */
		public function _b004(buff:D5ByteArray):void
		{
			var id:uint = buff.readUnsignedInt();
			//trace("id:"+id);
			//4字节 统率值
			var value_tongyu:uint = buff.readUnsignedInt();
			
			//4字节 武力值
			var value_wuli:uint = buff.readUnsignedInt();
			
			//4字节 智力值
			var value_zhili:uint = buff.readUnsignedInt();
			
			// 装备加成
			var value_tongyu_equ:uint = buff.readUnsignedInt();
			// 武力加成
			var value_wuli_equ:uint = buff.readUnsignedInt();
			// 智力加成
			var value_zhili_equ:uint = buff.readUnsignedInt();

			//4字节 统率加成
			var value_tongyu_add:uint = buff.readUnsignedInt();
			//4字节 武力加成
			var value_wuli_add:uint = buff.readUnsignedInt();
			//4字节 智力加成
			var value_zhili_add:uint = buff.readUnsignedInt();
			//4字节 统率临时值
			var value_tongyu_temp:uint=buff.readUnsignedInt();
			//4字节  武力临时值
			var value_wuli_temp:uint=buff.readUnsignedInt();
			//4字节  智谋临时值
			var value_zhili_temp:uint=buff.readUnsignedInt();
			

			//4字节 攻击
			var value_gongji:uint=buff.readUnsignedInt();
			
			//4字节 防御
			var value_fangyu:uint=buff.readUnsignedInt();
			//1字节 状态
			var value:uint = buff.readUnsignedByte();
			
			//1字节 可带兵种
			var soldier_kind:uint = buff.readUnsignedByte();
			
			//4字节 可带兵数
			var soldier_count:uint = buff.readUnsignedInt();
			
			//1字节 可修习的技能总数
			var total:uint = buff.readUnsignedByte();

			//道具个数
			var auranum:uint = buff.readUnsignedByte();
			
			//1字节 习得技能数量
			var num:uint = buff.readUnsignedByte();
			
			var auraList:Vector.<AuraData> = new Vector.<AuraData>;
			for(var v:uint=0;v<auranum;v++)
			{
				var auradata:AuraData = new AuraData();
				auradata.id = buff.readUnsignedInt();
				auradata.time = buff.readUnsignedInt();
				auradata.targetid = id;
				auraList.push(auradata);
				
			}
			
			var temp_time:int;
			var skillList:Vector.<SkillData> = new Vector.<SkillData>;
			var _skillList:Vector.<Object> = SanguoGlobal.Configer.genSkillConfig;
			for(var i:uint; i<num; i++)
			{
				//2字节 技能ID
				var skill_id:uint = buff.readUnsignedShort();
				//2字节 技能等级
				var skill_level:uint = buff.readUnsignedShort();
				//4字节 冷却时间
				var skill_time:int=buff.readInt();
				var skill:SkillData = new SkillData();
				skill._id = skill_id;
				skill._lv = skill_level;
//				trace('skill========>',skill.id,skill.lv);
				for each(var _data:Object in _skillList)
				{
					if(!_data) continue;
					if(skill.id==int(_data.skill_id))
					{
//						trace('skilltype========>',skill.id,skill.lv,skill.type);
						skill.type = int(_data.skill_type);
						break;
					}
				}
				
//				if(skill_time>0)
//				{
//				skill._zjtime=skill_time;
//				temp_time=skill_time;
//				}else{
//				  skill_time=0;
//				}
				skillList.push(skill);
				
			}
			
			// 更新武将技能列表
//			for each(var gen:GenData in SanguoGlobal.userdata.genList)
//			{
//				if(gen.id==id)
//				{
//					gen.gen_skill = skillList;
//					break;
//				}
//			}
			
			//N字节 武将简介
			var introduce:String = buff.readUTFBytes(buff.bytesAvailable);
			
			for each(var gendata:GenData in SanguoGlobal.userdata.genList)
			{
				if(gendata.id==id)
				{
					gendata.gen_id=id;
					gendata.gen_tongyu=value_tongyu;
					gendata.gen_wuli=value_wuli;
					gendata.gen_zhili=value_zhili;
					gendata.gen_tongyu_equ = value_tongyu_equ;
					gendata.gen_wuli_equ = value_wuli_equ;
					gendata.gen_zhili_equ = value_zhili_equ;
					gendata.gen_tongyu_add=value_tongyu_add;
					gendata.gen_wuli_add=value_wuli_add;
					gendata.gen_zhili_add=value_zhili_add;
					gendata.gen_tongyu_temp=value_tongyu_temp;
					gendata.gen_wuli_temp=value_wuli_temp;
					gendata.gen_zhili_temp=value_zhili_temp;
					gendata.gen_gongji=value_gongji;
					gendata.gen_fangyu=value_fangyu;
					gendata.gen_status=value;
					gendata.gen_bingtype = soldier_kind;
					gendata.gen_bingnum = soldier_count;
					gendata.gen_time=temp_time;
					gendata.gen_skillTotal=total;
					gendata.gen_skill=skillList;
					gendata.gen_auraList=auraList;
					for each(var ski:SkillData in gendata.skillList){
//						trace('genskill====>>>>',ski.id,ski.lv);
					}
					gendata.getComplate();
					break;
				}
				
			}
			
			if(SanguoGlobal.userdata.genindex<SanguoGlobal.userdata.genList.length-1)
			{
				SanguoGlobal.userdata.updatagenlist();
				return;
			}
			
			if(RPGScene.firstRun==-1&&SanguoGlobal.userdata.genindex>=SanguoGlobal.userdata.genList.length-1)
			{
				// 获取副本进度
//				SanguoGlobal.socket.RYcall(0xe000,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				RPGScene.my.UI.timelist();
			}
			
			makeEvent(0xb004);
			//if(SanguoGlobal.Configer.nowGenOperation as GenOperationXX != null) (SanguoGlobal.Configer.nowGenOperation as GenOperationXX).genD(gendata);
			//if(SanguoGlobal.Configer.nowGenOperation as GenOperationPY != null) (SanguoGlobal.Configer.nowGenOperation as GenOperationPY).genD(gendata);
			//else if(SanguoGlobal.Configer.nowGenOperation as GenOperationZJ != null) (SanguoGlobal.Configer.nowGenOperation as GenOperationZJ).genD(gendata);
			//else if(SanguoGlobal.Configer.nowGenOperation as GenOperationZB != null) (SanguoGlobal.Configer.nowGenOperation as GenOperationZB).genD(gendata);
			
		}
		
		/**
		 * 武将修习列表
		 */
		public function _b005(buff:D5ByteArray):void
		{
			
			//1字节 最大允许的修习武将个数
			SanguoGlobal.userdata._maxLearn = buff.readUnsignedByte();
			
			//1字节 正在修习中的武将个数
			var train:uint = buff.readUnsignedByte();
			//4字节 正在修习的武将ID
//			var arr:Array = new Array();
//			
//			for each(var gdat:GenData in SanguoGlobal.userdata.genList)
//			{
//				gdat.gen_status = GenData.FREE;
//			}
//			
			for(var i:uint; i<train; i++)
			{
				var gid:uint = buff.readUnsignedInt();
				var skill:uint = buff.readUnsignedShort();
				var time:uint = buff.readUnsignedInt();
				var exp:uint = buff.readUnsignedInt();
				
//				var status:uint;
//				if(skill==0)
//				{
//					status=1;
//				}else{
//					status=2;
//					
//				}
				
				SanguoGlobal.userdata.addLearn(gid,skill,time+CDCenter.my.systemTime,exp);
//				for each(var gdata:GenData in SanguoGlobal.userdata.genList)
//				{
//					if(gdata.id==int(data.genid)) 
//					{
//						
//						gdata.gen_status=int(data.status);
//						gdata.gen_time=int(data.time);
//					}
//				}
			}
			
			var win:SZ_Wujiang = WinBox.my.getWindow(SZ_Wujiang) as SZ_Wujiang;
			if(win==null)
			{
				trace("[Decoder] 当前没有打开武将界面");
				return;
			}
			
			win.startUI();
			//4字节 
			
//			if(_scene as MyCityScene==null) return;
//			if((_scene as MyCityScene).Operation as SZOperation==null) return;
//			//((_scene as MyCityScene).Operation as SZOperation).reXiuxi();
//			((_scene as MyCityScene).Operation as SZOperation).genWorking(max,train,arr);
//			for each(var _data:GenData in SanguoGlobal.userdata.genList)
//			{
//				if(_data.id == SanguoGlobal.Configer.nowGenid)
//				{
//					((_scene as MyCityScene).Operation as SZOperation).tempdata(_data);
//					break;
//				}
//				
//			}
			
			//(SanguoGlobal.Configer.nowGenOperation as GenOperationXX).genD(SanguoGlobal.userdata.genList[SanguoGlobal.Configer.nowGenid]);
		}
		
		/**
		 * 武将修习
		 */
		public function _b006(buff:D5ByteArray):void
		{
			//1字节 修习结果
			var train_result:int = buff.readByte();
			var time:uint=buff.readUnsignedInt();
			makeEvent(0xb006,[train_result,time]);
			if(train_result < 0) 
			{
				RPGScene.my.msg(Mather._0(train_result));
				return;
			}
			
			_scene.showMsg('武将进入修习！');
			MissionChecker.setKEY('_58',true);
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - SanguoGlobal.Configer.deprmb;
			
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			
//			if(_scene as MyCityScene==null) return;
//			if((_scene as MyCityScene).Operation as SZOperation==null) return;
//			//切换按钮状态
//			if(SanguoGlobal.Configer.nowGenOperation==null) return;
//			if(SanguoGlobal.Configer.nowGenOperation as GenOperationXX==null) return;
//			SanguoGlobal.Configer.nowGendata.gen_status = 1;
//			(SanguoGlobal.Configer.nowGenOperation as GenOperationXX).checkwork(0);
			
			//SanguoGlobal.socket.RYcall(0xb005,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
			return;
			
			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
		}
		
		/**
		 * 武将培养
		 */
		public function _b007(buff:D5ByteArray):void
		{
		     //1字节 标志位
			var sign:int=buff.readByte();
			
			//2字节 武将统率
			var tongyu:int=buff.readUnsignedShort();
			//2字节 武将勇武
			var yongwu:int=buff.readUnsignedShort();
			//2字节 武将智力
			var zhili:int=buff.readUnsignedShort();
			
			makeEvent(0xb007,[sign,tongyu,yongwu,zhili]);
			
			if(sign < 0)
			{
				RPGScene.my.msg(Mather._0(sign));
				return;
			}

			
			SanguoGlobal.userdata._fightPoint = SanguoGlobal.userdata.fightPoint - SanguoGlobal.Configer.depfight;
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - SanguoGlobal.Configer.deprmb;
			
			SanguoGlobal.Configer.depfight = 0;
			SanguoGlobal.Configer.deprmb = 0;
			
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			MissionChecker.setKEY('_50',true);
		
//			if(_scene as MyCityScene==null) return;
//			if((_scene as MyCityScene).Operation as SZOperation==null) return;
//			((_scene as MyCityScene).Operation as SZOperation).redata(data);
			return;
		} 
		
		/**
		 * 武将钻研
		 */
		public function _b008(buff:D5ByteArray):void
		{
			//1字节 修习结果
			var train_result:int = buff.readByte();
			var time:uint=buff.readUnsignedInt();
			MissionChecker.setKEY('_56',true);
			makeEvent(0xb008,[train_result,time]);
			if(train_result < 0) 
			{
				Zuanyan.isb008=false;
				RPGScene.my.msg(Mather._0(train_result));
				return;
			}
			SanguoGlobal.userdata._fightPoint = SanguoGlobal.userdata.fightPoint - SanguoGlobal.Configer.depfight;
//			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - SanguoGlobal.Configer.deprmb;
			
			RPGScene.my.UI.updateUserinfo();
			Zuanyan.isb008=false; 
			RPGScene.my.UI.updateCityinfo();
			
			//成功
			_scene.showMsg('武将技能成功升级！');
			SanguoGlobal.userdata.updatapackage();
			if(_scene as MyCityScene==null) return;
			if((_scene as MyCityScene).Operation as SZOperation==null) return;
			
			//切换按钮状态
			if(SanguoGlobal.Configer.nowGenOperation==null) return;
			if(SanguoGlobal.Configer.nowGenOperation as GenOperationZJ==null) return;
			SanguoGlobal.Configer.nowGendata.gen_status = 2;
			SanguoGlobal.Configer.nowGendata.gen_time = time;
			(SanguoGlobal.Configer.nowGenOperation as GenOperationZJ).checkwork(0);
			
			//SanguoGlobal.socket.RYcall(0xb005,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			((_scene as MyCityScene).Operation as SZOperation).retime(time);
			return;
		
		}
		
		/**
		 * 巡查
		 */
		public function _b009(buff:D5ByteArray):void
		{
			//1字节 巡查结果
			var result:int = buff.readByte();
			if(result < 0)
			{
				//失败
				RPGScene.my.msg(Mather._0(result));
				return;
				
			}
			
			//成功
			//4字节 提升的民忠
			var loyalty_add:uint = buff.readUnsignedInt();
			//_scene.notice('巡访成功'+'\n'+'民忠提升：'+ loyalty_add);
			_scene.sanguo.sNotice(SpecilNotice.MINZHONG,loyalty_add);
			SanguoGlobal.userdata._peopLike = SanguoGlobal.userdata.peopLike + loyalty_add;
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._food = SanguoGlobal.userdata.food - SanguoGlobal.Configer.depfood;
			MissionChecker.setKEY('_71',true);
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			RPGScene.my.UI.timelist();
			
			//冷却时间
			var cd:uint = buff.readUnsignedByte();
			
			//1字节 是否触发随机事件
			var matter:uint = buff.readUnsignedByte();
			if(WinBox.my.getWindow(MJ_Xuncha)==null) return ;
			((_newWIN=WinBox.my.getWindow(MJ_Xuncha))as MJ_Xuncha).NewXUNcha();
			if(matter == 0)
			{
				//否
				return;
				
			}else if(matter == 1)
			{
				//是
				
				//4字节 任务ID
				var id:uint = buff.readUnsignedInt();
				
				//30字节 任务标题
				var tie:String = buff.readUTFBytes(30);
				
				//60字节 处理方式，以空格分割
				var style:String = buff.readUTFBytes(60);
			}
		}
		
		/**
		 * 巡查随机事件处理
		 */
		public function _b00a(buff:D5ByteArray):void
		{
			//1字节 给予奖励类型
			var prize:uint = buff.readUnsignedByte();
			if(prize == 0)
			{
				//无奖励
				return;
				
			}else if(prize == 1)
			{
				//经验
				return;
				
			}else if(prize == 2)
			{
				//资源
				return;
			}
			
			//N字节 处理结果
			var result:String = buff.readUTFBytes(buff.bytesAvailable);
		}
		
		/**
		 * 开仓
		 */
		public function _b00b(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
		    MissionChecker.setKEY('_63',true);
			if(result<0)
			{
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//2字节 增长民忠
			var loyalty_add:uint = buff.readUnsignedInt();
			
			//4字节 增长人口
			var prople_count:uint = buff.readUnsignedInt();
			//4字节 冷却时间
			var cd:uint = buff.readUnsignedInt();
			
			//_scene.notice("开仓成功！民忠提升"+loyalty_add+"，人口提升"+prople_count);
			_scene.sanguo.sNotice(SpecilNotice.MINZHONG,loyalty_add);
			_scene.sanguo.sNotice(SpecilNotice.RENKOU,prople_count);
			SanguoGlobal.userdata._peopLike = SanguoGlobal.userdata.peopLike+loyalty_add;
			SanguoGlobal.userdata._peop = SanguoGlobal.userdata.peop+prople_count;
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._food = SanguoGlobal.userdata.food - SanguoGlobal.Configer.depfood;
			_scene.sanguo.UI.updateUserinfo();
			_scene.sanguo.UI.updateCityinfo();
			RPGScene.my.UI.closeAllCwin();
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.tl();
			if(WinBox.my.getWindow(MJ_Kaicang)==null) return ;
			
			((_newWIN=WinBox.my.getWindow(MJ_Kaicang))as MJ_Kaicang).Newkaichang();
			//SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
		}
		
		/**
		 * 耕作
		 */
		public function _b00c(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			MissionChecker.setKEY('_61',true);
			RPGScene.my.UI.timelist();
			if(result<0)
			{
				if(WinBox.my.getWindow(Housekeeper)!=null)
				{
					(WinBox.my.getWindow(Housekeeper)as Housekeeper).closeTimer4();
				}else
				{
					if(SanguoGlobal.Configer.time4!=null)
					{
						SanguoGlobal.Configer.time4.stop();
						SanguoGlobal.Configer.time4=null;
					}
					SanguoGlobal.Configer.freeNum4=0;
					SanguoGlobal.Configer.FreeNowNum4=0;
					SanguoGlobal.Configer.freeState4=0;
				}
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//4字节 农业值提升数
			var agriculture_add:uint = buff.readUnsignedInt();
			Debug.trace('农业值提升了=====',agriculture_add);
			//4字节 最新农业值
			var agriculture:uint = buff.readUnsignedInt();
			
			//trace("耕作成功！农业值提升"+agriculture_add+"，当前农业值为"+agriculture);
			_scene.sanguo.sNotice(SpecilNotice.NONGYE,agriculture_add);
			
			
			SanguoGlobal.userdata._farmExp = agriculture;
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._food = SanguoGlobal.userdata.food - SanguoGlobal.Configer.depfood;
			
			_scene.sanguo.UI.updateUserinfo();
			_scene.sanguo.UI.updateCityinfo();
			NPCDailog.my.onComplate();
			
			if(_scene==null ) return;
			RPGScene.my.UI.closeAllCwin();
			RPGScene.my.UI.showFocus(0);
			RPGScene.my.UI.tl();
			if(SanguoGlobal.Configer.freeState4==1)
			{
				SanguoGlobal.Configer.FreeNowNum4++;
			}
			if(WinBox.my.getWindow(Housekeeper)!=null)
			{
			
				(WinBox.my.getWindow(Housekeeper) as Housekeeper)._show();
			}
			if(WinBox.my.getWindow(NT_Gengzuo)==null) return ;
			((_newWIN=WinBox.my.getWindow(NT_Gengzuo))as NT_Gengzuo).Newgenzuo();
			
		}
		
		/**
		 * 征收粮食
		 */
		public function _b00d(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result<0)
			{
				if(WinBox.my.getWindow(Housekeeper)!=null)
				{
					(WinBox.my.getWindow(Housekeeper)as Housekeeper).closeTimer1();
				}
				else
				{
					if(SanguoGlobal.Configer.time1!=null)
					{
						SanguoGlobal.Configer.time1.stop();
						SanguoGlobal.Configer.time1=null;
					}
					SanguoGlobal.Configer.freeNum1=0;
					SanguoGlobal.Configer.FreeNowNum1=0;
					SanguoGlobal.Configer.freeState1=0;
				}
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			if(SanguoGlobal.Configer.freeState1==1)
			{
				SanguoGlobal.Configer.FreeNowNum1++;
			}
			if(WinBox.my.getWindow(Housekeeper)!=null)
			{
				
				(WinBox.my.getWindow(Housekeeper) as Housekeeper)._show();
			}
			//4字节 征收粮食数
			var provisions_levy:uint = buff.readUnsignedInt();
			
			//4字节 当前粮食总数
			var provisions:uint = buff.readUnsignedInt();
			
			_scene.notice("收粮完成！共征收粮食"+provisions_levy+"，当前粮食库存为"+provisions);
			SanguoGlobal.userdata._food = provisions;
			_scene.sanguo.UI.updateCityinfo();
			_scene.sanguo.UI.updateUserinfo();
			
			NPCDailog.my.onComplate();
			
			RPGScene.my.UI.closeAllCwin();
			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.showFocus(1);
			RPGScene.my.UI.tl();
			MissionChecker.setKEY('_48',true);
			
			if(WinBox.my.getWindow(GD_zhengshou)==null) return ;
			((_newWIN=WinBox.my.getWindow(GD_zhengshou))as GD_zhengshou).newzhengshou();
		}
		
		/**
		 * 强征粮食
		 */
		public function _b00e(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result<0)
			{
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//4字节 征收粮食数
			var provisions_levy:uint = buff.readUnsignedInt();
			
			//4字节 当前粮食总数
			var provisions:uint = buff.readUnsignedInt();
			
			//2字节 民心损失
			var loyalty_sub:uint = buff.readUnsignedShort();
			
			//2字节 当前民心
			var loyalty:uint = buff.readUnsignedShort();
			
			_scene.notice("收粮完成！共征收粮食"+provisions_levy+"，当前粮食库存为"+provisions+"。损失民忠"+loyalty_sub+'，当前民忠为'+loyalty+'。');
			SanguoGlobal.userdata._food = provisions;
			SanguoGlobal.userdata._peopLike = loyalty;
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb-Mather._1120(SanguoGlobal.userdata.numTax);
			SanguoGlobal.userdata._numTax=SanguoGlobal.userdata.numTax+1;
			var win:GD_zhengshou=WinBox.my.getWindow(GD_zhengshou) as GD_zhengshou;
			if(win!=null&&win._text!=null&&win._text1!=null) 
			{
				win._text.htmlText="强征需要<font color='#b78d0c'><b>"+Mather._1120(SanguoGlobal.userdata.numTax)+'</b></font>'+SanguoGlobal.Configer.wordkey(100);
			}
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			MissionChecker.setKEY('_48',true);
			RPGScene.my.UI.closeAllCwin();
			
			NPCDailog.my.onComplate();
			//SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.cityid);
			//if(!_scene is MyCityScene || !(_scene as MyCityScene).Operation is NTOperation) return;
//			((_scene as MyCityScene).Operation as NTOperation).reopenShouliang();
			if(WinBox.my.getWindow(GD_zhengshou)==null) return ;
			
			((_newWIN=WinBox.my.getWindow(GD_zhengshou))as GD_zhengshou).newzhengshou();
			
			
		}
		
		/**
		 * 提升商业值
		 */
		public function _b00f(buff:D5ByteArray):void
		{
			RPGScene.my.UI.timelist();
			//1字节 操作结果
			var result:int = buff.readByte();
			MissionChecker.setKEY('_62',true);
			if(result<0)
			{
				if(WinBox.my.getWindow(Housekeeper)!=null)
				{
					(WinBox.my.getWindow(Housekeeper)as Housekeeper).closeTimer4();
				}
				else
				{
					if(SanguoGlobal.Configer.time4!=null)
					{
						SanguoGlobal.Configer.time4.stop();
						SanguoGlobal.Configer.time4=null;
					}
					SanguoGlobal.Configer.freeNum4=0;
					SanguoGlobal.Configer.FreeNowNum4=0;
					SanguoGlobal.Configer.freeState4=0;
				}

				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//4字节 商业值提升数
			var business_add:uint = buff.readUnsignedInt();
			
			//4字节 最新商业值
			var business:uint = buff.readUnsignedInt();
			
			//_scene.notice("拓展成功！商业值提升"+business_add+"，当前商业值为"+business);
			_scene.sanguo.sNotice(SpecilNotice.SHANGYE,business_add);
			
			SanguoGlobal.userdata._bussExp = business;
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._food = SanguoGlobal.userdata.food - SanguoGlobal.Configer.depfood;
			
			_scene.sanguo.UI.updateCityinfo();
			_scene.sanguo.UI.updateUserinfo();
			NPCDailog.my.onComplate();
//			if(!_scene is MyCityScene && !(_scene as MyCityScene).Operation is SCOperation) return;
//			((_scene as MyCityScene).Operation as SCOperation).reopenTuozhan();
			
			RPGScene.my.UI.closeAllCwin();
			if(_scene==null ) return;
			if(SanguoGlobal.Configer.freeState4==1)
			{
				SanguoGlobal.Configer.FreeNowNum4++;
			}
			if(WinBox.my.getWindow(Housekeeper)!=null)
			{
			
				(WinBox.my.getWindow(Housekeeper) as Housekeeper)._show();
			}
			if(WinBox.my.getWindow(SC_Tuozhan)==null) return ;
			((_newWIN=WinBox.my.getWindow(SC_Tuozhan))as SC_Tuozhan).Newtuozhan();
		}
		
		/**
		 * 收税
		 */
		public function _b010(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			//if(Sanguo.my.masker)Sanguo.my.masker.nextFrame();
			//NPCDailog.my.onComplate();
			if(result<0)
			{
				if(WinBox.my.getWindow(Housekeeper)!=null)
				{
					(WinBox.my.getWindow(Housekeeper)as Housekeeper).closeTimer1();
				}
				else
				{
					if(SanguoGlobal.Configer.time1!=null)
					{
						SanguoGlobal.Configer.time1.stop();
						SanguoGlobal.Configer.time1=null;
					}
					SanguoGlobal.Configer.freeNum1=0;
					SanguoGlobal.Configer.FreeNowNum1=0;
					SanguoGlobal.Configer.freeState1=0;
				}
				if(result==-20) SanguoGlobal.Configer.shouliangNum=15;
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			else
			{
				SanguoGlobal.Configer.shouliangNum++;
				
				//4字节 征收银两数
				var money_add:uint = buff.readUnsignedInt();
				
				//4字节 当前银两总数
				var money:uint = buff.readUnsignedInt();
				
				var tax:int=buff.readUnsignedInt();
				
				var food_add:int=buff.readUnsignedInt();
				
				var food:int=buff.readUnsignedInt();
				
				var add_heart:int=buff.readShort();
				
				var heart:int=buff.readShort();
				
				_scene.notice("成功征收银两"+money_add+"两");
				_scene.notice("成功征收粮食"+food_add+"");
				if(add_heart!=0)_scene.notice("民忠损失"+Math.abs(add_heart)+"点");
				SanguoGlobal.userdata._numTax2=SanguoGlobal.userdata.numTax2+1;
				
				SanguoGlobal.userdata._gold =money;
				SanguoGlobal.userdata._food=food;
				SanguoGlobal.userdata._peopLike=SanguoGlobal.userdata.peopLike+add_heart;
//				trace("heart",heart);
				var win:GD_zhengshou=WinBox.my.getWindow(GD_zhengshou) as GD_zhengshou;
				if(win!=null&&win._text!=null&&win._text1!=null) 
				{
					win._text1.htmlText="今天已征收<font color='#02bf01'><b>"+SanguoGlobal.userdata.numTax2+' / '+SanguoGlobal.Configer.paramConfig.timeslimit.tax+'</b></font>次';
				}
				_scene.sanguo.UI.updateCityinfo();
				_scene.sanguo.UI.updateUserinfo();
				NPCDailog.my.onComplate();
				//				if(!_scene is MyCityScene || !(_scene as MyCityScene).Operation is SCOperation) return;
				//				((_scene as MyCityScene).Operation as SCOperation).reopenShuishou();
				
				if(_scene==null ) return;
				RPGScene.my.UI.closeAllCwin();
				RPGScene.my.UI.timelist();
				RPGScene.my.UI.showFocus(2);
				RPGScene.my.UI.tl();

				MissionChecker.setKEY('_48',true);
				//				SanguoGlobal.socket.RYcall(0xb00d,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.province);
				
			}
		}
		
		/**
		 * 强行收税
		 */
		public function _b011(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result<0)
			{
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//4字节 征收银两数
			var provisions_levy:uint = buff.readUnsignedInt();
			
			//4字节 当前银两总数
			var provisions:uint = buff.readUnsignedInt();
			
			var tax:int=buff.readInt();
			
			var delta_food:int=buff.readInt();
			
			var food:int=buff.readInt();
			
			//2字节 民心损失
			var loyalty_sub:uint = buff.readUnsignedShort();
			
			//2字节 当前民心
			var loyalty:uint = buff.readUnsignedShort();
			
			_scene.notice("强征银两"+provisions_levy+"两,粮食"+delta_food+"两，损失民忠"+loyalty_sub+'点');		
			SanguoGlobal.userdata._food = food;
			SanguoGlobal.userdata._peopLike = loyalty;
			SanguoGlobal.userdata._gold=provisions;
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb-Mather._1120(SanguoGlobal.userdata.numTax);
			SanguoGlobal.userdata._numTax=SanguoGlobal.userdata.numTax+1;
			var win:GD_zhengshou=WinBox.my.getWindow(GD_zhengshou) as GD_zhengshou;
			if(win!=null&&win._text!=null&&win._text1!=null) 
			{
				win._text.htmlText="强征需要<font color='#b78d0c'><b>"+Mather._1120(SanguoGlobal.userdata.numTax)+'</b></font>'+SanguoGlobal.Configer.wordkey(100);
				win.newzhengshou();
			}
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			MissionChecker.setKEY('_48',true);
			RPGScene.my.UI.closeAllCwin();
			NPCDailog.my.onComplate();
			
		}
		
		/**
		 * 提升技术值
		 */
		public function _b012(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
		    MissionChecker.setKEY('_72',true);
			if(result<0)
			{
				if(WinBox.my.getWindow(Housekeeper)!=null)
				{
					(WinBox.my.getWindow(Housekeeper)as Housekeeper).closeTimer4();
				}
				else
				{
					if(SanguoGlobal.Configer.time4!=null)
					{
						SanguoGlobal.Configer.time4.stop();
						SanguoGlobal.Configer.time4=null;
					}
					SanguoGlobal.Configer.freeNum4=0;
					SanguoGlobal.Configer.FreeNowNum4=0;
					SanguoGlobal.Configer.freeState4=0;
				}

				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//4字节 技术值提升数
			var technology_add:uint = buff.readUnsignedInt();
			
			//4字节 最新技术值
			var technology:uint = buff.readUnsignedInt();
			
			//_scene.notice("研究成功！技术值提升"+technology_add+"，当前技术值为"+technology);
			_scene.sanguo.sNotice(SpecilNotice.KEJI,technology_add);
			SanguoGlobal.userdata._scienExp = technology;
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._food = SanguoGlobal.userdata.food - SanguoGlobal.Configer.depfood;
			_scene.sanguo.UI.updateCityinfo();
			_scene.sanguo.UI.updateUserinfo();
			NPCDailog.my.onComplate();
//			if(!_scene is MyCityScene || !((_scene as MyCityScene).Operation is GFOperation)) return;
//			((_scene as MyCityScene).Operation as GFOperation).reopenYanjiu();
			
			RPGScene.my.UI.closeAllCwin();
			
			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
			if(SanguoGlobal.Configer.freeState4==1)
			{
				SanguoGlobal.Configer.FreeNowNum4++;
			}
			if(WinBox.my.getWindow(Housekeeper)!=null)
			{
			
				var CC:Object=WinBox.my.getWindow(Housekeeper);
				(WinBox.my.getWindow(Housekeeper) as Housekeeper)._show();
			}
			if(WinBox.my.getWindow(GF_Yanjiu)==null) return ;
			((_newWIN=WinBox.my.getWindow(GF_Yanjiu))as GF_Yanjiu).NewYanjiu();
			
			
		}
		
		/**
		 * 武器改良
		 */
		public function _b013(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result == -1)
			{
				//冷却中
				return;
				
			}else if(result == 0)
			{
				//失败
				return;
				
			}else if(result == 1)
			{
				//成功
				return;
			}
			
			//4字节 武器值提升数
			var weapon_add:uint = buff.readUnsignedInt();
			
			//4字节 最新武器值
			var weapon:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 防具改良
		 */
		public function _b014(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result == -1)
			{
				//冷却中
				return;
				
			}else if(result == 0)
			{
				//失败
				return;
				
			}else if(result == 1)
			{
				//成功
				return;
			}
			
			//4字节 防具值提升数
			var defense_add:uint = buff.readUnsignedInt();
			
			//4字节 最新防具值
			var defense:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 征兵
		 */
		public function _b016(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result<0)
			{
				if(WinBox.my.getWindow(Housekeeper)!=null)
				{
					(WinBox.my.getWindow(Housekeeper)as Housekeeper).closeTimer2();
				}
				else
				{
					if(SanguoGlobal.Configer.time2!=null)
					{
						SanguoGlobal.Configer.time2.stop();
						SanguoGlobal.Configer.time2=null;
					}
					SanguoGlobal.Configer.freeNum2=0;
					SanguoGlobal.Configer.FreeNowNum2=0;
					SanguoGlobal.Configer.freeState2=0;
				}
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			if(SanguoGlobal.Configer.freeState2==1)
			{
				SanguoGlobal.Configer.FreeNowNum2++;
			}
			//4字节 征兵数
			var arms_add:uint = buff.readUnsignedInt();
			
			//4字节 当前总兵数
			var arms:uint = buff.readUnsignedInt();
			
			SanguoGlobal.userdata._solid = arms;
			SanguoGlobal.userdata._food=SanguoGlobal.userdata.food-SanguoGlobal.Configer.depfood;
			SanguoGlobal.userdata._peop=SanguoGlobal.userdata.peop-arms_add;
			MissionChecker.setKEY('_69',true);
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			
			RPGScene.my.UI.closeAllCwin();
			_scene.notice('成功征兵'+arms_add+'人');
			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
			if(WinBox.my.getWindow(Housekeeper)!=null)
			{
				(WinBox.my.getWindow(Housekeeper) as Housekeeper)._show();
			}
			MissionChecker.setKEY('_22',true);
			NPCDailog.my.onComplate();
		}
		
		/**
		 * 强行征兵
		 */
		public function _b017(buff:D5ByteArray):void
		{
			
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			//4字节 征兵数
			var arms_add:uint = buff.readUnsignedInt();
			
			//4字节 当前总兵数
			var arms:uint = buff.readUnsignedInt();
			
			//2字节 民心损失
			var loyalty_sub:uint = buff.readUnsignedShort();
			
			//2字节 当前民心
			var loyalty:uint = buff.readUnsignedShort();
			
//			SanguoGlobal.userdata._food=SanguoGlobal.userdata.food-SanguoGlobal.Configer.depfood;
//			SanguoGlobal.userdata._solid = arms;
//			SanguoGlobal.userdata._peopLike = SanguoGlobal.userdata.peopLike - loyalty_sub;
//			Sanguo.my.UI.updateUserinfo();
//			Sanguo.my.UI.updateCityinfo();
			
			SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			RPGScene.my.UI.closeAllCwin();
			_scene.notice('强征士兵'+arms_add+'名,民忠损失'+loyalty_sub+'点');
			var win:BY_Zhaomu=WinBox.my.getWindow(BY_Zhaomu) as BY_Zhaomu;
			SanguoGlobal.userdata._numSol=SanguoGlobal.userdata.numSol+1;
			if(win!=null&&win._text!=null)
			{
				win._text.htmlText="强征需要<font color='#b78d0c'><b>"+Mather._1120(SanguoGlobal.userdata.numSol)+'</b></font>'+SanguoGlobal.Configer.wordkey(100);
			}
			NPCDailog.my.onComplate();
		
		}
		
		/**
		 * 修筑城墙
		 */
		public function _b018(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			MissionChecker.setKEY('_73',true);
			if(result<0)
			{
				if(WinBox.my.getWindow(Housekeeper)!=null)
				{
					(WinBox.my.getWindow(Housekeeper)as Housekeeper).closeTimer4();
				}
				else
				{
					if(SanguoGlobal.Configer.time4!=null)
					{
						SanguoGlobal.Configer.time4.stop();
						SanguoGlobal.Configer.time4=null;
					}
					SanguoGlobal.Configer.freeNum4=0;
					SanguoGlobal.Configer.FreeNowNum4=0;
					SanguoGlobal.Configer.freeState4=0;
				}
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//4字节 技术值提升数
			var defense_add:uint = buff.readUnsignedInt();
			
			//4字节 最新技术值
			var defense:uint = buff.readUnsignedInt();
			

			SanguoGlobal.socket.RYcall(0xb021,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.cityid);
			
			//_scene.notice("修筑成功！城防值提升"+defense_add+"，当前城防值为"+defense);
			
			_scene.sanguo.sNotice(SpecilNotice.CHENGFANG,defense_add);
			
			SanguoGlobal.userdata._wallExp = defense;
			SanguoGlobal.userdata._food = SanguoGlobal.userdata.food - SanguoGlobal.Configer.depfood;
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			RPGScene.my.UI.closeAllCwin();
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			
			NPCDailog.my.onComplate();
			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
			if(SanguoGlobal.Configer.freeState4==1)
			{
				SanguoGlobal.Configer.FreeNowNum4++;
			}
			if(WinBox.my.getWindow(Housekeeper)!=null)
			{
				
				(WinBox.my.getWindow(Housekeeper) as Housekeeper)._show();
			}
			if(WinBox.my.getWindow(CQ_Chengmen)==null) return ;
			((_newWIN=WinBox.my.getWindow(CQ_Chengmen))as CQ_Chengmen).NewChengMen();
			
		}
		
		/**
		 * 抢修城墙
		 */
		public function _b019(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result<0)
			{
				if(_scene) _scene.showMsg(Mather._0(result));
				return;
			}
			
			//4字节 技术值提升数
			var defense_add:uint = buff.readUnsignedInt();
			
			//4字节 最新技术值
			var defense:uint = buff.readUnsignedInt();
			RPGScene.my.UI.closeAllCwin();
			//_scene.notice("抢修成功！城防值提升"+defense_add+"，当前城防值为"+defense);
			_scene.sanguo.sNotice(SpecilNotice.CHENGFANG,defense_add);
			SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb-(2+SanguoGlobal.userdata.numXiou*2);
			SanguoGlobal.userdata._wallExp = defense;
			SanguoGlobal.userdata._peopLike = SanguoGlobal.userdata.peopLike - 1;
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			SanguoGlobal.userdata._numXiou=SanguoGlobal.userdata.numXiou+1;
			var win:CQ_Chengmen=WinBox.my.getWindow(CQ_Chengmen) as CQ_Chengmen;
			if(win!=null&&win._text!=null)
			{
				win._text.htmlText="强征需要<font color='#b78d0c'><b>"+(2+SanguoGlobal.userdata.numXiou*2)+'</b></font>'+SanguoGlobal.Configer.wordkey(100);
			}
			NPCDailog.my.onComplate();
			if(WinBox.my.getWindow(CQ_Chengmen)==null) return ;
			((_newWIN=WinBox.my.getWindow(CQ_Chengmen))as CQ_Chengmen).NewChengMen();
			 /* 
			if(_scene==null ) return;
			Sanguo.my.UI.timelist();
			*/
		}
		
		/**
		 * 取消修习
		 */ 
		public function _b020(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int=buff.readByte();
			var exp:int=buff.readUnsignedInt();
			
			makeEvent(0xb020,[result,exp]);
			if(result < 0) 
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			//4字节 获得的经验
			
			
			//trace(result+"//"+exp);
//			if(_scene) _scene.notice("成功获得"+exp+"点经验");
//			//切换按钮状态
//			if(SanguoGlobal.Configer.nowGenOperation==null) return;
//			if(SanguoGlobal.Configer.nowGenOperation as GenOperationXX==null) return;
//			SanguoGlobal.Configer.nowGendata.gen_status = 0;
//			CDCenter.my._cdList[23]=0;
//			if(_scene as MyCityScene == null) return;
//			if((_scene as MyCityScene).Operation as SZOperation == null) return;
//			//((_scene as MyCityScene).Operation as SZOperation).checkwork(1);
//			(SanguoGlobal.Configer.nowGenOperation as GenOperationXX).checkwork(1);
//			Sanguo.my.updateGenList();
//			//SanguoGlobal.socket.RYcall(0xb005,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//			return;
			
		}
		
		/**
		 * 行动数据包
		 */  
		public function _b021(buff:D5ByteArray):void 
		{ 
			  //2字节  当前的行动值
			  var action:uint=buff.readUnsignedShort();
			  // 4字节  行动值冷却的CD
			  var action_cd:uint=buff.readUnsignedInt();
			  // 4字节   行动值回复的剩余时间
			  var action_time:uint=buff.readUnsignedInt();
			  //2字节 使用次数
			  //var count:uint = buff.readUnsignedShort();
			  
			  SanguoGlobal.userdata._action=action;
			  SanguoGlobal.userdata._actionCD=action_cd;
			  SanguoGlobal.userdata._actionTime= action_cd - action_time;
			 // trace(action,action_cd,action_time,'=+=');
			  if(_scene==null ) return;
			  RPGScene.my.UI.updataAction();
		}
		
		/**
		 * 取消钻研
		 */ 
		public function _b022(buff:D5ByteArray):void
		{
			//1字节 返回结果 0为失败武将没有处于钻研状态
			var result:int=buff.readByte();
			//4字节 增长的经验
			var exp:int=buff.readUnsignedInt();
			
			makeEvent(0xb022,[result,exp]);
			
			if(result < 0) 
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			return;
			
			if(_scene) _scene.notice("成功获得"+exp+"点经验");
			
			//切换按钮状态
			if(SanguoGlobal.Configer.nowGenOperation==null) return;
			if(SanguoGlobal.Configer.nowGenOperation as GenOperationZJ==null) return;
			SanguoGlobal.Configer.nowGendata.gen_status = 0;
			(SanguoGlobal.Configer.nowGenOperation as GenOperationZJ).checkwork(1);
			
			//Sanguo.my.updateGenList();
			CDCenter.my._cdList[24]=0;
			//SanguoGlobal.socket.RYcall(0xb005,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			return;
		}
		/**
		 * 元宝取消CD时间
		 */ 
		public function _b023(buff:D5ByteArray):void
		{
		 	//1字节  返回结果 1为成功  0为失败
			var result:int=buff.readByte();
			if(result<0)
			{
				if(_scene) _scene.showMsg("操作失败!");
				return;
			}
			
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - SanguoGlobal.Configer.unCDrmb;
			RPGScene.my.UI.updateUserinfo();
			
			
			if(_scene) _scene.showMsg("成功减少时间");
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.tl();
			
		}
		
		/**
		 * 道具取消CD时间
		 */
		public function _b032(buff:D5ByteArray):void
		{
			//1字节  返回结果 1为成功  0为失败
			var result:int=buff.readByte();
			if(result<0)
			{
				if(_scene) _scene.showMsg("操作失败!");
				return;
			}
			
			if(SanguoGlobal.Configer.depType==WorkID.COOLDOWN)
			{
				SanguoGlobal.userdata.useItemByID(WorkID.ITEM_COOLDOWN,SanguoGlobal.Configer.depNum);
				SanguoGlobal.Configer.depType = 0;
				SanguoGlobal.Configer.depNum = 0;
			}else{
				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - SanguoGlobal.Configer.unCDrmb;
				RPGScene.my.UI.updateUserinfo();
			}
			
			if(_scene) _scene.showMsg("成功减少时间");
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.tl();
		}
		
		/**
		 * 获取取消CD时间所要消耗的元宝数
		 */ 
		private var cdrmb:uint=0;
		public function _b024(buff:D5ByteArray):void
		{
			//2字节 返回元宝消耗值 
			var yuanbao:int=buff.readUnsignedInt();
			cdrmb = yuanbao;
			if(_scene)
			{
				//var str:String="减少冷却时间需要消耗"+yuanbao+SanguoGlobal.Configer.wordkey(100)+"（"+SanguoGlobal.Configer.itemConfig(WorkID.ITEM_COOLDOWN).equ_prop_name+"）,请选择";
				var str:String="减少冷却时间需要消耗"+yuanbao+SanguoGlobal.Configer.wordkey(100)+"!";
				
				RPGScene.my.msg2(str,callback,'提示',1);
				//Sanguo.my.msgFun(callback,cancelfun);
				//Sanguo.my.msgLab('元宝','道具');
			}
		}
		public function callback(v:uint):void
		{
			if(RPGScene.my.UI.checkRmb(cdrmb,WorkID.COOLDOWN,buyCooldown)==1)
			{
				//锁定
				//WorkID.my.lock(WorkID.COOLDOWN,false);
				buyCooldown();
			}
		}
		public function cancelfun(v:uint):void
		{
			RPGScene.my.UI.checkRmb(cdrmb,WorkID.COOLDOWN,buyCooldown,$buyCooldown);
		}
		
		private function buyCooldown():void
		{
			SanguoGlobal.Configer.unCDrmb = cdrmb;
			SanguoGlobal.socket.RYcall(0xb023,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,CDShower.nowSpeedID);
		}
		
		private function $buyCooldown():void
		{
			SanguoGlobal.socket.RYcall(0xb032,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,CDShower.nowSpeedID);
		}
		
		public function _b025(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			var nowaction:uint = buff.readUnsignedShort();
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 20;
			SanguoGlobal.userdata._action= nowaction;
			SanguoGlobal.userdata._numXdl=SanguoGlobal.userdata.numXdl+1;
			RPGScene.my.UI.updateUserinfo();
			
			RPGScene.my.msg('行动力增加');
		}
		
		/**
		 * 道具检查
		 */
		public function _b026(buff:D5ByteArray):void
		{
			var result:uint = buff.readByte();
			//if(result) SanguoGlobal.socket.RYcall(0xb027,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.nowGenid,SanguoGlobal.Configer.nowGenSkillID);
			//else Sanguo.my.msg('缺少技能书');
		}
		
		/**
		 * 武将技能槽解锁
		 */
		public function _b027(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			makeEvent(0xb027,result);
			
			if(result==0)
			{
				RPGScene.my.msg('解锁失败!');
				return;
			}else if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - SanguoGlobal.Configer.deprmb;
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			
			
			
			//SanguoGlobal.socket.RYcall(0xb004,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.nowGenid);
			RPGScene.my.msg('解锁成功');
		}
		
		/**
		 * 武将技能遗忘
		 */
		public function _b028(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			makeEvent(0xb028,result);
			if(result==0)
			{
				RPGScene.my.msg('遗忘失败!');
				return;
			}else if(result<0){
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			//SanguoGlobal.socket.RYcall(0xb004,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.nowGenid);
			RPGScene.my.msg('遗忘成功!');
		}
		
		public function _b029(buff:D5ByteArray):void
		{
			var lv:int = buff.readShort();
			var exp:int = buff.readInt();
			
			trace("技能信息",lv,exp);
		}
		
		private var useTFRmb:int;
		/**
		 * 突飞猛进的次数
		 */
		public function _b02a(buff:D5ByteArray):void
		{
			//突飞的次数
			var num:uint = buff.readUnsignedShort();
			//元宝消耗
			var deprmb:uint = buff.readUnsignedInt();
			
			useTFRmb = deprmb;
			
			var str:String = '本次突飞需要消耗<font color="#ff6600">'+deprmb+'</font>'+SanguoGlobal.Configer.wordkey(100)+'，请选择';
			
			RPGScene.my.msg2(str,DepTufei,'提示',1);
//			Sanguo.my.msgLab('元宝','道具');
//			Sanguo.my.msgFun(DepTufei,$DepTufei);
			
			//makeEvent(0xb02a,[num,deprmb]);
		}
		
		private function DepTufei(id:int):void
		{
			if(RPGScene.my.UI.checkRmb(useTFRmb,WorkID.TFCOOLDOWN,depTufei)==1)
			{
				depTufei();
			}
		}
		
		private function $DepTufei(id:int):void
		{
			RPGScene.my.UI.checkRmb(useTFRmb,WorkID.TFCOOLDOWN,depTufei,$depTufei);
		}
		
		private function depTufei():void
		{
			SanguoGlobal.socket.RYcall(0xb01f,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		private function $depTufei():void
		{
			SanguoGlobal.socket.RYcall(0xb0f1,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
		}
		
		/**
		 * 城池扩建
		 */
		public function _b01a(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			
			
			//4字节 城池升级的冷却时间
			var time:uint = buff.readUnsignedInt();
			
			//trace(result+"//"+time);
			
			SanguoGlobal.userdata._cityLv=result;
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._food = SanguoGlobal.userdata.food - SanguoGlobal.Configer.depfood;
			RPGScene.my.UI.updateCityinfo();
			RPGScene.my.UI.updateUserinfo();
			
			MissionChecker.setKEY('_23',true);
			
			if(_scene) 
			{
				_scene.notice("城池升级为"+result+'级！');
				RPGScene.my.UI.addChild(new Msg_tip(2));
				
			}
			if(_scene as MyCityScene==null) return;
			(_scene as MyCityScene).RYclearOperation();
			(_scene as MyCityScene).startBuild(true);

			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
			if(WinBox.my.getWindow(CQ_Kuojian)==null) return ;
			((_newWIN=WinBox.my.getWindow(CQ_Kuojian))as CQ_Kuojian).NewKuojian();
		}

		
		/**
		 * 武将身上装备信息包
		 */
		public function _b01b(buff:D5ByteArray):void
		{
		   //1字节 身上道具的数量
			var len:int=buff.readByte();
			//trace("*******"+len);
			var list:Vector.<ItemData> = new Vector.<ItemData>;
			for(var i:int=0;i<len;i++)
			{
				
			  //4字节  道具的ID
			   var id:uint=buff.readUnsignedInt();
			   var packid:uint = buff.readUnsignedInt();
			   //1字节 装备的位置  0 武器 1 防具 2 马
			   var loc:int=buff.readByte();
			   // 装备精炼等级
			   var lv:uint = buff.readByte();
			   //2字节 特殊功能编号
			   var funID:uint=buff.readShort();
			   var max:int=3;
			   //trace("+"+id+"-"+loc+"*"+funID);
			   
			  	var obj:Object=new Object();
				
				obj.id=id;
				obj.loc=loc;
				obj.funID=funID;		
				
				var itemdata:ItemData = new ItemData();
				itemdata._id = id;
				itemdata._name = SanguoGlobal.Configer.itemConfig(id).equ_prop_name;
				itemdata._packageid = packid;
				itemdata._slv = lv;
				itemdata._type = SanguoGlobal.Configer.itemConfig(id).equ_prop_type;

				obj.data = itemdata;
				
			   for(var j:uint=0;j<max;j++)
			   {
				   var arr:Array=new Array();
			   		//2字节 影响的属性
				   var att:String=buff.readUTFBytes(2);
				   //4字节  属性值
				   var att_value:uint=buff.readUnsignedInt();
				   //4字节  追加的属性值
				   var att_value_add:uint=buff.readUnsignedInt();
				   //trace("/"+att+"<"+att_value+">"+att_value_add);
			   }
			   
			   list.push(itemdata);
			}
			
			makeEvent(0xb01b,list);
//			if(!(_scene is MyCityScene) || !(_scene as MyCityScene).Operation is SZOperation) return;
//			((_scene as MyCityScene).Operation as SZOperation).reitem(item);
			
		}
		/**
		 * 武将更换装备
		 */ 
		public function _b01c(buff:D5ByteArray):void
		{
			
			//1字节  返回的结果 0无法装备  1为装备成功
			var result:int=buff.readByte();
			makeEvent(0xb01c,result);
			if(result<0)
			{
				SanguoGlobal.Configer.lastUseItem = 0;
				RPGScene.my.msg(Mather._0(result));
				return;

			}else if(result==1){
				if(SanguoGlobal.Configer.lastUseType==1)
				{
					// 上次动作是穿上某装备
//					var obj:*=SanguoGlobal.Configer.missionConfig.NSD5Power::getMission(SanguoGlobal.Configer.missonId).need;
//					if(SanguoGlobal.Configer.itemConfig(SanguoGlobal.Configer.lastUseItem).equ_prop_type==obj[obj.length-1].value)
//					{
						MissionChecker.setKEY('_52',true);
//					}
				}
			}
			SanguoGlobal.Configer.lastUseItem = 0;
			
			//if(_scene) _scene.showMsg("物品已装备");
//			if(_scene is MyCityScene && (_scene as MyCityScene).Operation is SZOperation)
//			{
//				((_scene as MyCityScene).Operation as SZOperation).refresh();
//				//SanguoGlobal.socket.RYcall(0xb004,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.nowChangeItemGenID);
//			}
		}
		
		
		/**
		 * 获取冷却时间集中包
		 */

		public function _b01d(buff:D5ByteArray):void
		{
			//2字节  冷却的总数
			var len:uint = buff.readUnsignedByte();
			
			for(var i:uint=0;i<len;i++)
			{
				//4字节  冷却的ID
			   var  id_sub:uint=buff.readUnsignedInt();
			   //4字节  冷却的时间
			   var time_sub:int=buff.readInt();
			   if(time_sub<0) time_sub = 0;
			   
			   //战斗CD 临时调整
//			   if(id_sub==26) id_sub += 6;
			   
			   CDCenter.my.update(id_sub,time_sub);
			   trace('b01d',id_sub,time_sub);
			   continue;
			   
			   if(time_sub<0){
				   time_sub=0;
			   }

			   for each(var cddata:CDData in SanguoGlobal.CDList)
			   { 
				   if(cddata.id==id_sub)
				   {   
					   cddata._time=time_sub;
					   cddata._name=Mather._4(id_sub);
					   cddata._type=1;
				   }
				  // trace('冷却的类别'+ cddata.id+'   冷却的时间'+cddata.time+'     冷却的名称'+cddata.name);
			   }
			   //SanguoGlobal.CDList.push(cddata);
			}
			
			if(RPGScene.firstRun==-1)
			{
				//获取太守/皇帝巡查时间
				SanguoGlobal.socket.RYcall(0xb620,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				return;
			}
			
			RPGScene.my.UI.tl();
//			return;
			if(_scene==null || _scene as MyCityScene==null) return;
			if((_scene as MyCityScene).Operation as ICDupdate==null) return;
			((_scene as MyCityScene).Operation as ICDupdate).updateCD();
			
		}
		/**
		 * 使用突飞猛进技能
		 */
		public function _b01e(buff:D5ByteArray):void
		{
		   //4字节  获取的经验
			var exp_sub:uint=buff.readUnsignedInt();
		    //4字节 冷却时间
			var time_sub:uint=buff.readUnsignedInt();
			
			makeEvent(0xb01e,[exp_sub,time_sub]);
			
			if(exp_sub==0)
			{
				if(_scene) _scene.showMsg("战功不足! ");
				return;
			}else if(exp_sub==-1)
			{
				if(_scene) _scene.showMsg("武将没有进行修习！");
				return;
			}
			MissionChecker.setKEY('_59',true);
			SanguoGlobal.userdata._fightPoint = SanguoGlobal.userdata.fightPoint - SanguoGlobal.Configer.depfight;
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.tl();
//			else
//			{
//				
//				//if(_scene) _scene.notice("成功获得"+exp_sub+"点经验");
//				if(_scene) _scene.showMsg("成功获得"+exp_sub+"点经验\n减少突飞猛进冷却时间最多消耗4元宝");
//				SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//				
//			}
//			if(!_scene is MyCityScene || !(_scene as MyCityScene).Operation is SZOperation) return;
//			//((_scene as MyCityScene).Operation as SZOperation).updataCD(time_sub);
//			if(_scene==null ) return;
//			Sanguo.my.UI.timelist();
		}
		
		/**
		 * 元宝减少突飞猛进技能CD
		 */
		public function _b01f(buff:D5ByteArray):void
		{
		  //1字节  操作结果
		  var result:int=buff.readByte();
		  
		  //4字节  减少的冷却时间
		  var time:int=buff.readUnsignedInt();
		  
		  CDCenter.my._cdList[20] = time;
		  makeEvent(0xb01f,[result,time]);
		  if(result < 0)
		  {
			  RPGScene.my.msg(Mather._0(result));
			  return;
		  }
		  
		  SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - useTFRmb;
		  RPGScene.my.UI.updateUserinfo();
		  
		  RPGScene.my.UI.timelist();
		  RPGScene.my.UI.tl();
		  if(_scene) _scene.showMsg("操作成功，可继续使用突飞猛进！！");
		  
		}
	
		/**
		 * 道具减少突飞猛进技能CD
		 */
		public function _b0f1(buff:D5ByteArray):void
		{
			//1字节  操作结果
			var result:int=buff.readByte();
			
			//4字节  减少的冷却时间
			var time:int=buff.readUnsignedInt();
			
			CDCenter.my._cdList[20] = time;
			makeEvent(0xb01f,[result,time]);
			if(result < 0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			if(SanguoGlobal.Configer.depType==WorkID.TFCOOLDOWN)
			{
				SanguoGlobal.userdata.useItemByID(WorkID.ITEM_TFCOOLDOWN,SanguoGlobal.Configer.depNum);
				SanguoGlobal.Configer.depType = 0;
				SanguoGlobal.Configer.depNum = 0;
			}
			
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.tl();
			if(_scene) _scene.showMsg("操作成功，可继续使用突飞猛进！！");
		}
			
		/**
		 * 获取巡查所要消耗的资源
		 */
		public function _b100(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取开仓所要消耗的资源
		 */
		public function _b101(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取提升农业值所要消耗的资源
		 */
		public function _b102(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取提升商业值所要消耗的资源
		 */
		public function _b103(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取提升技术值所要消耗的资源
		 */
		public function _b104(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取改良武器所要消耗的资源
		 */
		public function _b105(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
			
			//4字节 当前攻击值
			var attack:uint = buff.readUnsignedInt();
			
			//4字节 提升后的攻击值
			var attack_now:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取改良防具所要消耗的资源
		 */
		public function _b106(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
			
			//4字节 当前防御值
			var defens:uint = buff.readUnsignedInt();
			
			//4字节 提升后的防御值
			var defens_now:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取征兵所要消耗的资源
		 */
		public function _b107(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取强行征兵所要消耗的资源
		 */
		public function _b108(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要元宝
			var rmb_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取修筑城墙所要消耗的资源
		 */
		public function _b109(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
//			SanguoGlobal.socket.RYcall(0xb10a,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.cityid);
		}
		
		/**
		 * 获取抢修城墙所要消耗的资源
		 */
		public function _b10a(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要元宝
			var rmb_sub:uint = buff.readUnsignedInt();
		}
		/**
		 * 获取征收 强征 抢修的次数
		 */
		public function _6307(buff:D5ByteArray):void
		{
			SanguoGlobal.userdata._numTax=buff.readInt();
			SanguoGlobal.userdata._numSol=buff.readInt();
			SanguoGlobal.userdata._numXiou=buff.readInt();
			SanguoGlobal.userdata._numTax2=SanguoGlobal.Configer.paramConfig.timeslimit.tax-buff.readInt();
			SanguoGlobal.userdata._numXdl=buff.readInt();
		}
		/**
		 * 获取自己已经发布的个人任务
		 */
		public function _6308(buff:D5ByteArray):void
		{  
			var arr:Array=new Array();
			var type:int=buff.readByte();
			arr.push(type);
			var cid:int=buff.readUnsignedInt();
			arr.push(cid);
			var num:int=buff.readUnsignedInt();
			arr.push(num);
			makeEvent(0x6307,arr);
		}
		/**
		 * 获取升级城池所要消耗的资源
		 */
		public function _b10b(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
		}
		/**
		 * 获取强征粮食消耗的资源
		 */
		public function _b10c(buff:D5ByteArray):void
		{
			//4字节 需要银两
			var money_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要元宝
			var rmb_sub:uint = buff.readUnsignedInt();
			
		}
		/**
		 * 获取强征银两所要消耗的资源
		 */
		public function _b10d(buff:D5ByteArray):void
		{
			//4字节 需要粮食
			var provisions_sub:uint = buff.readUnsignedInt();
			
			//4字节 需要元宝
			var rmb_sub:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 获取当前最新的资源信息
		 */
		public function _b10e(buff:D5ByteArray):void
		{
			//4字节 需要元宝
			var rmb:uint = buff.readUnsignedInt();
			
			//4字节 需要银两
			var money:uint = buff.readUnsignedInt();
			
			//4字节 需要粮食
			var provisions:uint = buff.readUnsignedInt();
		}
		
		/**
		 * 根据用户昵称获取用户ID
		 */
		public function _b10f(buff:D5ByteArray):void
		{
			//4字节 用户ID
			var uid:uint = buff.readUnsignedInt();
			
			if(uid == 0) _scene.showMsg('未找到此玩家');
			else {
				if(CDCenter.my.getTolimit(CDCenter.FIGHT))
				{
					RPGScene.my.msg('战斗冷却中!');
				}else SanguoGlobal.socket.RYcall(0xd007,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,uid);
			}
		}
		
		/**
		 * 根据用户ID获取用户昵称
		 */
		public function _b110(buff:D5ByteArray):void
		{
			//30字节 用户昵称
			var name:String = buff.readUTFBytes(30);
			trace("<b110>",name);
			if(RPGScene.my.UI.operation==null)return;
			if((RPGScene.my.UI.operation.win2 as SearchName)==null) return;
			(RPGScene.my.UI.operation.win2 as SearchName).showName(name);
		}
		
		/**
		 * 获取当前用户的全部上限数据
		 */
		public function _b111(buff:D5ByteArray):void
		{
			var farm:uint = buff.readUnsignedInt();
			var buss:uint = buff.readUnsignedInt();
			var tech:uint = buff.readUnsignedInt();
			var defe:uint = buff.readUnsignedInt();
			var peop:uint = buff.readUnsignedInt();
			var soil:uint = buff.readUnsignedInt();
			var gold:uint = buff.readUnsignedInt();
			var food:uint = buff.readUnsignedInt();
			
			SanguoGlobal.userdata._farm_limit = farm;
			SanguoGlobal.userdata._buss_limit = buss;
			SanguoGlobal.userdata._scien_limit = tech;
			SanguoGlobal.userdata._wall_limit = defe;
			SanguoGlobal.userdata._peop_limit = peop;
			SanguoGlobal.userdata._solid_limit = soil;
			SanguoGlobal.userdata._gold_limit = gold;
			SanguoGlobal.userdata._food_limit = food;
			SanguoGlobal.userdata._peoplike_limit = 100;
			
			//判断当前资源是否超过上限
			SanguoGlobal.userdata._farmExp = Math.min(SanguoGlobal.userdata.farmExp,SanguoGlobal.userdata.farm_limit);
			SanguoGlobal.userdata._bussExp = Math.min(SanguoGlobal.userdata.bussExp,SanguoGlobal.userdata.buss_limit);
			SanguoGlobal.userdata._scienExp = Math.min(SanguoGlobal.userdata.scienExp,SanguoGlobal.userdata.scien_limit);
			SanguoGlobal.userdata._wallExp = Math.min(SanguoGlobal.userdata.wallExp,SanguoGlobal.userdata.wall_limit);
			SanguoGlobal.userdata._peop = Math.min(SanguoGlobal.userdata.peop,SanguoGlobal.userdata.peop_limit);
			SanguoGlobal.userdata._solid = Math.min(SanguoGlobal.userdata.solid,SanguoGlobal.userdata.solid_limit);
			SanguoGlobal.userdata._gold = Math.min(SanguoGlobal.userdata.gold,SanguoGlobal.userdata.gold_limit);
			SanguoGlobal.userdata._food = Math.min(SanguoGlobal.userdata.food,SanguoGlobal.userdata.food_limit);
			SanguoGlobal.userdata._peopLike = Math.min(SanguoGlobal.userdata.peopLike,SanguoGlobal.userdata.peoplike_limit);
			
			RPGScene.my.UI.uiCityinfo.peopLike(SanguoGlobal.userdata.peopLike,100,isfirstload);
			RPGScene.my.UI.uiCityinfo.peop(SanguoGlobal.userdata.peop,peop,isfirstload);
			RPGScene.my.UI.uiCityinfo.solid(SanguoGlobal.userdata.solid,soil,isfirstload);
			RPGScene.my.UI.uiCityinfo.agriculture(SanguoGlobal.userdata.farmExp,farm,isfirstload);
			RPGScene.my.UI.uiCityinfo.business(SanguoGlobal.userdata.bussExp,buss,isfirstload);
			RPGScene.my.UI.uiCityinfo.technology(SanguoGlobal.userdata.scienExp,tech,isfirstload);
			RPGScene.my.UI.uiCityinfo.cityDefense(SanguoGlobal.userdata.wallExp,defe,isfirstload);
			
			if(RPGScene.my.UI.uiUserinfo != null) 
			{
				RPGScene.my.UI.uiUserinfo.Food(SanguoGlobal.userdata.food,food);
				RPGScene.my.UI.uiUserinfo.Money(SanguoGlobal.userdata.gold,gold);
			}
			
			isfirstload = false;
			
			RPGScene.my.UI.warning();
			if(_900bEnable)
			{
				SanguoGlobal.socket.RYcall(0x900b,SanguoGlobal.SERVER_CLUSETER,0,SanguoGlobal.userdata.uid);
			}

		}
		private var _900bEnable:Boolean=true;
		private var isfirstload:Boolean=true;
		
		/**
		 * 个人任务发布--攻打任务
		 */
		public function _b200(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			MissionChecker.setKEY('_54',true);
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.JGrenwuNeedgold*1.1;
			RPGScene.my.UI.updateCityinfo();
			RPGScene.my.msg('发布成功');
			trace('发布成功');
		}
		
		/**
		 * 个人任务发布--收集任务
		 */
		public function _b201(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			MissionChecker.setKEY('_54',true);
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.JGrenwuNeedgold*1.1;
			RPGScene.my.UI.updateCityinfo();
			RPGScene.my.msg('发布成功');
		}
		
		/**
		 * 个人发布任务--寄售
		 */
		public function _b202(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			MissionChecker.setKEY('_54',true);
		
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.JGrenwuNeedgold*.1;
			RPGScene.my.UI.updateCityinfo();
			RPGScene.my.msg('发布成功');
			
			makeEvent(0xb202);
		}
		
		/**
		 * 酒馆任务历史记录
		 */
		public function _b204(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			var arr:Array;
			var taskArr:Array=new Array();
			for(var i:uint=0;i<result;i++)
			{
				arr=new Array();
				var s_name:String=buff.readUTFBytes(30);
				arr.push(s_name);
				var d_name:String=buff.readUTFBytes(30);
				arr.push(d_name);
				var atk_name:String=buff.readUTFBytes(30);
				arr.push(atk_name);
				var props_cityID:int=buff.readInt();
				arr.push(props_cityID);
				var props_num:int=buff.readInt();
				arr.push(props_num);
				var type:int=buff.readByte();
				arr.push(type);
				taskArr.push(arr);
				trace("0xb204======>>>>>",arr);
			}		
			makeEvent(0xb204,taskArr);
		}
		/**
		 * 个人发布任务列表
		 */
		public function _b205(buff:D5ByteArray):void
		{
			RPGScene.my.closeWait();
			var totle:uint = buff.readUnsignedInt();
			var arr:Vector.<Object> = new Vector.<Object>();
			trace(buff.length);
			for(var i:uint=0;i<(totle>(SanguoGlobal.Configer.JGrenwupernum*SanguoGlobal.Configer.JGrenwupage)?SanguoGlobal.Configer.JGrenwupernum:(totle-SanguoGlobal.Configer.JGrenwupernum*(SanguoGlobal.Configer.JGrenwupage-1)));i++)
			{
				var obj:Object = new Object();
				obj['id'] = buff.readInt();
				obj['type'] = buff.readByte();
				obj['uid'] = buff.readInt();
				obj['name'] = buff.readUTFBytes(30);
				
				obj['city_props']=buff.readInt();
				
				obj['nation_num']=buff.readShort();
				obj['d_name']=buff.readUTFBytes(30);
				
				obj['reward'] = buff.readUnsignedInt();
				obj['etype'] = buff.readByte();
				arr.push(obj);
				trace("b205xxx==============>>",buff.length,totle,obj.id,obj.type,obj.uid,obj.name,obj.city_props,obj.nation_num,'xx',obj.d_name,obj.reward,obj.etype);
			}
			//Sanguo.my.UI.changeTest(0xb205,'====================');
			var arrx:Array=[arr,totle];

			makeEvent(0xb205,arrx);

			//(WinBox.my.getWindow(JG_Renwu) as JG_Renwu).setData2(arr);

			return;
//			if(_scene as MyCityScene==null) return;
//			if((_scene as MyCityScene).Operation as JGOperation==null) return;
//			if(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Renwu==null) return;
//			(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Renwu).reshowTab(arr,totle);
		}
		
		/**
		 * 个人任务详情
		 */
		public function _b206(buff:D5ByteArray):void
		{
			var obj:Object = new Object();
			obj['time'] = buff.readInt();
			obj['type'] = buff.readByte();
			if(int(obj.type)==1)
			{
				obj['targetuid'] = buff.readInt();
				obj['targetname'] = buff.readUTFBytes(30);
				obj['targetcountry'] = buff.readByte();
				obj['targetcity'] = buff.readShort();
			}else{
				obj['itemid'] = buff.readInt();
				obj['num'] = buff.readByte();
				
			}
			makeEvent(0xb206,obj);
			return;
			if(_scene as MyCityScene==null) return;
			if((_scene as MyCityScene).Operation as JGOperation==null) return;
			if(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Renwu==null) return;
			(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Renwu).completeRenwu(obj);
		}
		
		/**
		 * 完成个人发布任务
		 */
		public function _b207(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result==0)
			{
//				Sanguo.my.msg('该任务可能已被完成或撤销');
				RPGScene.my.msg('该任务可能已被完成或撤销,攻打任务应需先攻城才完成');
				return;
			}else if(result<0){
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			var totle:uint = buff.readByte();
			var str:String='';
			
			for(var i:uint=0;i<totle;i++)
			{
				var type:int = buff.readByte();
				var itemid:int = buff.readInt();
				var num:int = buff.readInt();
				if(type==3)
				{
					str += SanguoGlobal.Configer.itemConfig(itemid).equ_prop_name+' x'+num+' ';
				}else str += '银币 x'+num+' ';
				SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold + num;
			}
			RPGScene.my.msg('完成任务\n\n获得 '+str);
			
			RPGScene.my.UI.updateUserinfo();
			
			SanguoGlobal.userdata.updatapackage();
			SanguoGlobal.socket.RYcall(0xb400,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//			SanguoGlobal.socket.RYcall(0xb205,SanguoGlobal.SERVER_USER,0,SanguoGlobal.Configer.JGrenwupage,9);
		}
		
		/**
		 * 取消任务
		 */
		public function _b208(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			var leftgold:uint = buff.readUnsignedInt();
			SanguoGlobal.userdata._gold = leftgold;
			RPGScene.my.UI.updateCityinfo();
			
			SanguoGlobal.userdata.updatapackage();
			SanguoGlobal.socket.RYcall(0xb400,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//			SanguoGlobal.socket.RYcall(0xb205,SanguoGlobal.SERVER_USER,0,SanguoGlobal.Configer.JGrenwupage,9);
		}

		/**
		 * 赋税调整
		 */
		public function _c000(buff:D5ByteArray):void
		{
			var taxes:int = buff.readByte();
			if(taxes == -2)
			{
				_scene.showMsg("权限不足");
				//权限不足
				return;
				
			}else if(taxes == -1)
			{
				_scene.showMsg("正在冷却中");
				//冷却期
				return;
				
			}else if(taxes == 0)
			{
				_scene.showMsg("修改失败");
				//修改失败
				return;
				
			}else if(taxes == 1)
			{
				_scene.showMsg("修改成功");
				SanguoGlobal.socket.RYcall(0xc017,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				//修改成功
				return;
			}
			
			if(_scene==null ) return;
			//Sanguo.my.UI.timelist();
		}
		/**
		 * 武将培养数据保存
		 */ 
		public function _bf07(buff:D5ByteArray):void
		{
			//1字节 0 保存失败 1 成功
			var result:int=buff.readByte();
			
			makeEvent(0xbf07,result);
			
			if(result==-11)
			{
				_scene.showMsg("替换失败");
				return;
			}else{
				_scene.showMsg("替换成功");
				
				MissionChecker.setKEY('_50',true);
//				if(_scene as MyCityScene==null) return;
//				if((_scene as MyCityScene).Operation as SZOperation==null) return;
//				Sanguo.my.updateGenList();
//				//nextStep = ((_scene as MyCityScene).Operation as SZOperation).rePeiyang;
//				((_scene as MyCityScene).Operation as SZOperation).savedata(1);
				return;
			}
			
		}
		/**
		 * 武将培养数据取消
		 */ 
		public function _bf08(buff:D5ByteArray):void
		{
			//1字节  0失败 1成功
			var result:int=buff.readByte();
			
			makeEvent(0xbf08,result);
//			if(result==-11)
//			{
//				_scene.showMsg("维持失败");
//				return;
//			}else{
//				_scene.showMsg("维持成功");
////				if(_scene as MyCityScene==null) return;
////				if((_scene as MyCityScene).Operation as SZOperation==null) return;
////				Sanguo.my.updateGenList();
////				((_scene as MyCityScene).Operation as SZOperation).savedata(0);
//				return;
//			}
		}
		
		/**
		 * 太守巡访
		 */
		public function _c001(buff:D5ByteArray):void
		{
			var success:int = buff.readByte();
			if(success == -8)
			{
				_scene.showMsg('权限不足');
				return;
			}else if(success == -5){
				_scene.showMsg('巡查次数已耗尽');
				return;
			}else if(success == -4){
				_scene.showMsg('该城池已被巡查');
				return;
			}else if(success == 0){
				_scene.showMsg('巡视失败');
				return;
			}else if(success == 1){
				//巡访成功
				_scene.showMsg('巡查成功');
			}
			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
			
		}
		
		/**
		 * 科技情况-  个人
		 */
		public function _c002(buff:D5ByteArray):void
		{
			//科技总数
			var tec_count:uint = buff.readShort();
			var data:Vector.<SkillData> = new Vector.<SkillData>;
			for(var i:uint; i < tec_count; i++)
			{
				var skill:SkillData = new SkillData();
				skill._id = buff.readUnsignedInt();
				skill._lv = buff.readUnsignedInt();
				if(skill.lv) data.push(skill);
			}
			SanguoGlobal.userdata._skillList = data;
			
			MissionChecker.setKEY('_24',true);
			
			if(RPGScene.firstRun==-1) SanguoGlobal.socket.RYcall(0xce02,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);

			if((_scene as MyCityScene)!=null&&((_scene as MyCityScene).Operation!=null)&&!((_scene as MyCityScene).Operation as ITechShower))
			{
//				trace('here',((_scene as MyCityScene).Operation as ITechShower));
				if(((_scene as MyCityScene).Operation as ITechShower)){
				((_scene as MyCityScene).Operation as ITechShower).showTech();
				}
			}
			
			if((WinBox.my.getWindow(GD_Keji))as GD_Keji!=null)
			{
				((_newWIN=WinBox.my.getWindow(GD_Keji))as GD_Keji).Callback_shenji();
			}
		}
		
		/**
		 * 科技情况 - 名城
		 */
		public function _ce02(buff:D5ByteArray):void
		{
			//科技总数
			var tec_count:uint = buff.readShort();
			var data:Vector.<SkillData> = new Vector.<SkillData>;
			for(var i:uint; i < tec_count; i++)
			{
				var skill:SkillData = new SkillData();
				skill._id = buff.readUnsignedInt();
				skill._lv = buff.readUnsignedInt();
				if(skill.lv) data.push(skill);
			}
			SanguoGlobal.userdata._skillListA = data;
			
			if(RPGScene.firstRun==-1) SanguoGlobal.socket.RYcall(0xcf02,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//			if(_scene as MyCityScene == null) return;
			if((WinBox.my.getWindow(GD_Zhengling))as GD_Zhengling!=null)
			{
				((_newWIN=WinBox.my.getWindow(GD_Zhengling))as GD_Zhengling).Callback_shenji();
			}
			if(RPGScene.my.UI.Operation as ITechShower==null) return;
			(RPGScene.my.UI.Operation as ITechShower).showTech();
		}
		
		
		/**
		 * 科技情况 - 国家
		 */
		public function _cf02(buff:D5ByteArray):void
		{
		
			//科技总数
			var tec_count:uint = buff.readShort();

			var data:Vector.<SkillData> = new Vector.<SkillData>;
			for(var i:uint; i < tec_count; i++)
			{
				var skill:SkillData = new SkillData();
				skill._id = buff.readUnsignedInt();
				skill._lv = buff.readUnsignedInt();
				if(skill.lv) data.push(skill);
			}
			SanguoGlobal.userdata._skillListC = data;
			
			if(RPGScene.firstRun==-1)
			{
				// 获取武将列表
//				SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//				SanguoGlobal.socket.RYcall(0xff00,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,0,1,UserData.PACKAGETOTAL);
				SanguoGlobal.userdata.updatapackage();
			}
			if((WinBox.my.getWindow(HG_NeiZheng))as HG_NeiZheng!=null)
			{
				((_newWIN=WinBox.my.getWindow(HG_NeiZheng))as HG_NeiZheng).Callback_shenji();
			}
//			if(_scene as MyCityScene == null) return;
			if(RPGScene.my.UI.Operation as ITechShower==null) return;
			(RPGScene.my.UI.Operation as ITechShower).showTech();
		}
		
		/**
		 * 个人项科技升级所需要的资源
		 */
		public function _c003(buff:D5ByteArray):void
		{
			//4字节 消费黄金
			var gold:uint = buff.readUnsignedInt();
			//4字节 冷却时间（秒）
			var cdtime:uint = buff.readUnsignedInt();
			
			//makeEvent(0xc003,[gold,cdtime]);
			
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as ITechShower==null) return;
			((_scene as MyCityScene).Operation as ITechShower).showRes(gold,cdtime);
		}
		/**
		 * 科技情况-  地区科技升级所需要的资源
		 */ 
		public function _ce03(buff:D5ByteArray):void
		{
			//4字节 消费黄金
			var gold:uint = buff.readUnsignedInt();
			//4字节  消费战功
			var jungong:uint=buff.readInt();
			//4字节 冷却时间（秒）
			var cdtime:uint = buff.readUnsignedInt();
			
//			if(_scene as MyCityScene == null) return;
			if(RPGScene.my.UI.Operation as ITechShower==null) return;
			CDCenter.my.update(30,cdtime);
			(RPGScene.my.UI.Operation as ITechShower).showRes(gold,cdtime);
			
		}
		/**
		 * 国家科技升级所需要的资源
		 */ 
		public function _cf03(buff:D5ByteArray):void
		{
			//4字节 消费黄金
			var gold:uint = buff.readUnsignedInt();
			//4字节  消费战功
			var jungong:uint=buff.readInt();
			//4字节 冷却时间（秒）
			var cdtime:uint = buff.readUnsignedInt();
			CDCenter.my.update(31,cdtime);
//			trace("<cf03>",gold,cdtime);
//			if(_scene as MyCityScene == null) return;
//			trace("<cf03>$",(_scene as MyCityScene).Operation);
//			if((_scene as MyCityScene).Operation as ITechShower==null) return;
//			trace("<cf03>$&");
//			((_scene as MyCityScene).Operation as ITechShower).showRes(gold,cdtime);
			
//			if(Sanguo.my.UI.operation.win2 is HG_NeiZheng)
//			{
//				var opt:HG_NeiZheng = Sanguo.my.UI.operation.win2 as HG_NeiZheng;
//				
//				opt.showRes(gold,cdtime);
//			}
			
			if(RPGScene.my.UI.Operation as ITechShower==null) return;
			(RPGScene.my.UI.Operation as ITechShower).showRes(gold,cdtime);
		}
		/**
		 * 个人科技研究
		 */
		public function _c004(buff:D5ByteArray):void
		{
			var tech:int = buff.readByte();
			
			//makeEvent(0xc004,tech);
			
			if(tech<0)
			{
				RPGScene.my.msg(Mather._0(tech));
				return;
			}
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.depgold;
			SanguoGlobal.userdata._fightPoint = SanguoGlobal.userdata.fightPoint - SanguoGlobal.Configer.depfight;
			
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.showFocus(5);
			RPGScene.my.UI.tl();
			_scene.showMsg("研究成功");
			
			SanguoGlobal.socket.RYcall(0xc002,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
			if(_scene as MyCityScene == null) return;
			if(_scene==null ) return;
			if((_scene as MyCityScene).Operation as GFOperation != null) ((_scene as MyCityScene).Operation as GFOperation).reGailiang();
			
			return;
		}
		
		/**
		 * 科技情况-地区科技研究
		 */
		public function _ce04(buff:D5ByteArray):void
		{
			var tech:int = buff.readByte();
			if(tech==-5)
			{
				RPGScene.my.msg('府库银两不足！');
				return;
			}
			else if(tech<0) return;
			SanguoGlobal.Configer.CountryMoney = SanguoGlobal.Configer.CountryMoney - SanguoGlobal.Configer.depgold;
			SanguoGlobal.Configer.CountryZhanGong = SanguoGlobal.Configer.CountryZhanGong - SanguoGlobal.Configer.depfight;
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			_scene.showMsg("研究成功");
			makeEvent(0xce04,tech);
			
			//if(_scene as MyCityScene == null) return;
			//if(_scene==null ) return;
			SanguoGlobal.socket.RYcall(0xce02,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//			if((_scene as MyCityScene).Operation as GDOperation != null) ((_scene as MyCityScene).Operation as GDOperation).reZhengling(2);
//			if(Sanguo.my.UI.operation.win2 is GD_Zhengling)
//			{
//				var opt:GD_Zhengling = Sanguo.my.UI.operation.win2 as GD_Zhengling;
//				
//				opt.refreshKeji();
//			}
			return;
			
		}

		
		/**
		 * 科技情况-国家科技研究
		 */
		public function _cf04(buff:D5ByteArray):void
		{
			var tech:int = buff.readByte();
			if(tech<0)
			{
				RPGScene.my.msg(Mather._0(tech));
				return;
			}
			
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			_scene.showMsg("研究成功");
			//if(_scene as MyCityScene == null) return;
			//if(_scene==null ) return;
			SanguoGlobal.Configer.CityMoney= SanguoGlobal.Configer.CityMoney - SanguoGlobal.Configer.depgold;
			SanguoGlobal.Configer.CityZhanGong = SanguoGlobal.Configer.CityZhanGong - SanguoGlobal.Configer.depfight;
			SanguoGlobal.socket.RYcall(0xcf02,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			//			if((_scene as MyCityScene).Operation as HGOperation != null) ((_scene as MyCityScene).Operation as HGOperation).reNeizheng();
//			if(Sanguo.my.UI.operation.win2 is HG_NeiZheng)
//			{
//				var opt:HG_NeiZheng = Sanguo.my.UI.operation.win2 as HG_NeiZheng;
//				
//				opt.refreshKeji();
//			}
			
			return;
			
		}
		
		/**
		 *个人正在进行研究的科技列表
		 */
		public function _c005(buff:D5ByteArray):void
		{
			//1字节 正在进行研究的科技个数
			var tec_count:uint = buff.readByte();
			
			//4字节 科技ID
			var uid:uint = buff.readUnsignedInt();
			
			//4字节 剩余冷却时间（秒）
			var cdtime:uint = buff.readUnsignedInt();
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as GFOperation == null) return;
			((_scene as MyCityScene).Operation as GFOperation).reGailiang();
			
			if((_scene as MyCityScene).Operation as ITechShower==null) return;
			((_scene as MyCityScene).Operation as ITechShower).showRes(0,cdtime);
			
		}
		/**
		 *地区正在进行研究的科技列表
		 */
		public function _ce05(buff:D5ByteArray):void
		{
			//1字节 正在进行研究的科技个数
			var tec_count:uint = buff.readByte();
			
			//4字节 科技ID
			var uid:uint = buff.readUnsignedInt();
			
			//4字节 剩余冷却时间（秒）
			var cdtime:uint = buff.readUnsignedInt();
			/*
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as GDOperation == null) return;
			//((_scene as MyCityScene).Operation as GDOperation).reZhengling(1,"升级科技剩余冷却时间:"+cdtime);
			*/
			if(RPGScene.my.UI.operation as ITechShower==null) return;
			(RPGScene.my.UI.operation as ITechShower).showRes(0,cdtime);
			
		}
		/**
		 *国家正在进行研究的科技列表
		 */
		public function _cf05(buff:D5ByteArray):void
		{
			//1字节 正在进行研究的科技个数
			var tec_count:uint = buff.readByte();
			
			//4字节 科技ID
			var uid:uint = buff.readUnsignedInt();
			
			//4字节 剩余冷却时间（秒）
			var cdtime:uint = buff.readUnsignedInt();
			/*
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as HGOperation == null) return;
			((_scene as MyCityScene).Operation as HGOperation).reNeizheng();
			*/
			
			
			if(RPGScene.my.UI.operation as ITechShower==null) return;
			(RPGScene.my.UI.operation as ITechShower).showRes(0,cdtime);
			
		}
		/**
		 * 获取当前的粮草价格及服务器允许的交易限额
		 */
		public function _c006(buff:D5ByteArray):void
		{
			//4字节 当前粮食的交易价格（用4字节整形保存浮点型）
			var price:Number = Number(buff.readFloat().toFixed(2));
			
			//4字节 当前服务器允许的交易限额
			var max:uint = buff.readUnsignedInt();
			
			//4字节 当前已交易的数量
			var now:uint = buff.readUnsignedInt();
			
			makeEvent(0xc006,[price,max-now]);
			
			return;
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as SCOperation == null) return;
			((_scene as MyCityScene).Operation as SCOperation).reopenJiaoyi(price,max);

		}
		
		/**
		 * 出售粮食
		 */
		public function _c007(buff:D5ByteArray):void
		{
			var sale:int = buff.readByte();
			if(sale < 0)
			{
				RPGScene.my.msg(Mather._0(sale));
				return;
			}
			
			makeEvent(0xc007);
			
//			if(_scene as MyCityScene == null) return;
//			if((_scene as MyCityScene).Operation as SCOperation == null) return;
//			((_scene as MyCityScene).Operation as SCOperation).changeUserdata();
			
			_scene.showMsg('出售成功');
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			return;
		}
		
		/**
		 * 购买粮食
		 */
		public function _c008(buff:D5ByteArray):void
		{
			var buy:int = buff.readByte();
			if(buy<0)
			{
				RPGScene.my.msg(Mather._0(buy));
				return;
			}
			
			makeEvent(0xc008);
			
//			if(_scene as MyCityScene == null) return;
//			if((_scene as MyCityScene).Operation as SCOperation == null) return;
//			((_scene as MyCityScene).Operation as SCOperation).changeUserdata();
			
			_scene.showMsg('购买成功');
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			return;
			
		}
		
		/**
		 * 商品列表
		 */
		public function _c009(buff:D5ByteArray):void
		{
			var max:uint = buff.readUnsignedShort();
			//2字节 商品个数
			var count:uint = buff.readUnsignedShort();
			
			var data:Vector.<ItemData> = new Vector.<ItemData>;
			
			for(var i:uint=0; i < count; i++)
			{
				
				var itemdata:ItemData = new ItemData();
				
				itemdata._id = buff.readUnsignedInt();
				
				itemdata._packageid = buff.readUnsignedInt();
				itemdata._own=buff.readUnsignedInt();
				buff.readUnsignedInt(); // 不处理的等级数据，因为商店中均为1级
				itemdata._slv = 1;
				itemdata._name = buff.readUTFBytes(20);
				itemdata._lv = buff.readByte();
				itemdata._buy = buff.readUnsignedInt();
				itemdata._buy_rmb = buff.readUnsignedInt();
				itemdata._sell = buff.readUnsignedInt();
				buff.readUnsignedShort();
				data.push(itemdata);
			}
			
			makeEvent(0xc009,[data,max]);
			return;
			
			if(_scene as MyCityScene == null) return;
			
			var itemShower:IItemShower = (_scene as MyCityScene).Operation.win2 as IItemShower;
			if(itemShower == null) return;
			if(data.length != 0)
			{
				itemShower.total = max;
				if(max == 0) itemShower.total = 1;
			}else itemShower.total = 1;
			itemShower.showItem(data);
		}
		
		/**
		 * 我的道具列表
		 */ 
		public function _ff00(buff:D5ByteArray):void
		{
			var total:uint = buff.readUnsignedShort();

			var num:uint = buff.readUnsignedShort();
			
			var data:Vector.<ItemData> = new Vector.<ItemData>;
			var data2:Vector.<ItemData>=new Vector.<ItemData>;
			for(var i:uint=0; i < num; i++)
			{
				var id:uint = buff.readUnsignedInt();
				
				var itemdata:ItemData = SanguoGlobal.userdata.newItem(id);
				
				itemdata._id = id;
				itemdata._packageid = buff.readUnsignedInt();
				itemdata._own=buff.readUnsignedInt();
				itemdata._slv = buff.readUnsignedInt();
				itemdata._name = buff.readUTFBytes(20);
				itemdata._lv = buff.readByte();
				itemdata._buy = buff.readUnsignedInt();
				itemdata._buy_rmb = buff.readUnsignedInt();
				itemdata._sell = buff.readUnsignedInt();
				itemdata._num = buff.readUnsignedShort();
				itemdata._Num = itemdata._Num_ = itemdata.num;
				//trace(itemdata.name,itemdata.num,itemdata.own,itemdata.manyto_one,'*******');
				if(itemdata.own==0)
				{
					data.push(itemdata);
				} 
				if(itemdata.slv>0)
				{
					data2.push(itemdata);
				}
				
				SanguoGlobal.userdata.addItem(itemdata,1);
//				if(!itemdata.own) trace(i,itemdata.name,'=================');
				trace(i,itemdata.own,itemdata.name,itemdata.num,itemdata.own);
			}
			if(UserData.NOWPACKAGECALL<Math.ceil(total/SanguoGlobal.userdata.PACKAGEPER))
			{
				UserData.NOWPACKAGECALL++;//trace(UserData.NOWPACKAGECALL,'----------------');
				SanguoGlobal.socket.RYcall(0xff00,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,0,UserData.NOWPACKAGECALL,SanguoGlobal.userdata.PACKAGEPER);
				return;
			}else{
				if(SanguoGlobal.userdata.$callback!=null)
				{
					SanguoGlobal.userdata.$callback();
				}
//				UserData.NOWPACKAGECALL = 1;
				
				RPGScene.my.realwait=false;
				RPGScene.my.closeWait();
			}
			
			
//			if(UserData.NOWPACKAGECALL<=Math.ceil(SanguoGlobal.userdata.packageUnlock/UserData.PACKAGEPER))
//			{
//				UserData.NOWPACKAGECALL++;
//				SanguoGlobal.socket.RYcall(0xff00,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,0,UserData.NOWPACKAGECALL,UserData.PACKAGEPER);
//			}else if(Sanguo.firstRun==-1) Sanguo.my.UI.timelist();
//			if(Sanguo.firstRun==-1) Sanguo.my.UI.timelist();
			
			// 获取副本进度
			if(RPGScene.firstRun==-1) SanguoGlobal.socket.RYcall(0xe000,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			return;
			
			
			SanguoGlobal.userdata._itemList=data2;
			var itemShower:IItemShower = WinBox.my.getWindow(BB_all)==null ? null : WinBox.my.getWindow(BB_all) as IItemShower;

			if(itemShower==null)
			{
				if(_scene as MyCityScene == null) return;
				if(_scene.Operation==null) return;
				if(_scene.Operation as JGOperation) (_scene.Operation as JGOperation).reDuihuan(data,total);
				itemShower = _scene.Operation.win2 as IItemShower;
				
				return;
			}
			
			if(data.length != 0)
			{
				itemShower.total = total;
				if(total == 0) itemShower.total = 1;
			}else itemShower.total = 1;
			
			itemShower.showItem(data);

		}
		
		/**
		 * 使用道具
		 */
		public function _ff01(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			var itemid:uint = buff.readUnsignedInt();
			
			//使用道具解锁
			SanguoGlobal.Configer.isUsebook = true;
			makeEvent(0xff01,[result,itemid]);
			if(result==0)
			{
				RPGScene.my.msg('使用失败!');
				return;
			}else if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			var str:String='';
			for each(var obj:Object in SanguoGlobal.Configer.itemEffectConfig)
			{
				if(int(obj.item_id) == itemid)
				{   
					var ob:BB_all=WinBox.my.getWindow(BB_all) as BB_all;
					switch(int(obj.effect_id))
					{
						case 1:
							//学会某技能
							str = '学习新技能';
							break;
						case 2:
							//增加行动力
							if(ob!=null){
							SanguoGlobal.userdata._action = SanguoGlobal.userdata.action + int(obj.item_effect_count)*ob.sellnum;
							str = '行动力增加'+int(obj.item_effect_count)*ob.sellnum;
							}
							break;
						case 3:
							//增加玩家主将经验
							str = '主将增加'+obj.item_effect_count;
							break;
						case 4:
							//让玩家获得的经验增加
							str = '经验增加'+obj.item_effect_count*ZhuangBei.num;
							break;
						case 5:
							//让玩家获得的战功增加
							if(ob!=null){
							SanguoGlobal.userdata._fightPoint = SanguoGlobal.userdata.fightPoint + int(obj.item_effect_count)*ob.sellnum;
							str = '战功增加'+obj.item_effect_count*ob.sellnum;
							}
							break;
						case 6:
							//让玩家征兵时获得额外的士兵
							str = '兵力增加'+obj.item_effect_count;
							break;
						case 7:
							//让玩家在强化装备时不消耗任何资源
							//Sanguo.my.UI.uiAurainfo.addID(itemid);
							break;
						case 8:
							//让玩家在强化装备失败时不会降低装备级别
							//Sanguo.my.UI.uiAurainfo.addID(itemid);
							break;
						case 9:
							//直接获得银两
							if(ob!=null){
							SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold + int(obj.item_effect_count)*ob.sellnum;
							str = '银两增加'+obj.item_effect_count*ob.sellnum;
							}
							break;
						case 10:
							//直接获得粮食
							if(ob!=null){
							SanguoGlobal.userdata._food = SanguoGlobal.userdata.food + int(obj.item_effect_count)*ob.sellnum;
							str = '粮食增加'+obj.item_effect_count*ob.sellnum;
							}
							break;
						case 11:
							//直接获得武将潜力值
							str = '潜力值增加'+obj.item_effect_count;
							break;
						case 12:
							//直接获得士兵
							if(ob!=null){
							SanguoGlobal.userdata._solid = SanguoGlobal.userdata.solid + int(obj.item_effect_count)*ob.sellnum;
							str = '兵力增加'+obj.item_effect_count*ob.sellnum;
							}
							break;
						case 13:
							//让玩家收粮时获得额外的粮食
							break;
						case 14:
							//让玩家在征税时获得额外的银两
							break;
						case 15:
							//让玩家在增加人口时获得额外的人口
							break;
						case 16:
							//直接提升武将勇武
							str = '勇武增加'+obj.item_effect_count;
							break;
						case 17:
							//直接提升武将统率
							str = '统率增加'+obj.item_effect_count;
							break;
						case 18:
							//直接提升武将智力
							str = '智力增加'+obj.item_effect_count;
							break;
						case 19:
							//随机获取一个特定品质的武将
							if(ob!=null){
							str = '获得'+ob.sellnum+'个新武将';
							}
							SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
							break;
						case 20:
							//直接提升武将经验
							str = '经验增加'+obj.item_effect_count*ZhuangBei.num;
							break;
						case 21:
							//提升出征时部队的攻击
							//Sanguo.my.UI.uiAurainfo.addID(itemid);
							str = '部队攻击增加'+obj.item_effect_count+'%';
							SanguoGlobal.userdata.addTeamAuradata(itemid);
							break;
						case 22:
							//提升出征时部队的防御
							//Sanguo.my.UI.uiAurainfo.addID(itemid);
							str = '部队防御增加'+obj.item_effect_count+'%';
							SanguoGlobal.userdata.addTeamAuradata(itemid);
							break;
						case 23:
							//直接提升民忠
							if(ob!=null){
							SanguoGlobal.userdata._peopLike = SanguoGlobal.userdata.peopLike + int(obj.item_effect_count)*ob.sellnum;
							str = '民忠增加'+obj.item_effect_count*ob.sellnum;
							}
							break;
						case 24:
							//直接提升武将亲密度
							str = '亲密度增加'+obj.item_effect_count;
							break;
						case 25:
							//直接获得元宝
							if(ob!=null){
							SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb + int(obj.item_effect_count)*ob.sellnum;
							str = SanguoGlobal.Configer.wordkey(100)+'增加'+obj.item_effect_count*ob.sellnum;
							}
							break;
						case 26:
							//直接提升出征时武将的勇武
							//Sanguo.my.UI.uiAurainfo.addID(itemid);
							str = '勇武增加'+obj.item_effect_count+'%';
							break
						case 27:
							//直接提升出征时武将的智谋
							//Sanguo.my.UI.uiAurainfo.addID(itemid);
							str = '智谋增加'+obj.item_effect_count+'%';
							break;
						case 28:
							//直接提升出征时武将的统率
							//Sanguo.my.UI.uiAurainfo.addID(itemid);
							str = '统率增加'+obj.item_effect_count+'%';
							break;
						case 29:
							//立即增加城池200点农业值
							if(ob!=null){
							SanguoGlobal.userdata._farmExp = SanguoGlobal.userdata.farmExp + int(obj.item_effect_count)*ob.sellnum;
							str = '城池农业值增加'+obj.item_effect_count*ob.sellnum+'点';
							}
							break;
						case 30:
							//立即增加城池200点商业值
							if(ob!=null){
							SanguoGlobal.userdata._bussExp = SanguoGlobal.userdata.bussExp + int(obj.item_effect_count)*ob.sellnum;
							str = '城池商业值增加'+obj.item_effect_count*ob.sellnum+'点';
							}
							break;
						case 31:
							//立即增加城池200点科技值
							if(ob!=null){
							SanguoGlobal.userdata._scienExp = SanguoGlobal.userdata.scienExp + int(obj.item_effect_count)*ob.sellnum;
							str = '城池科技值增加'+obj.item_effect_count*ob.sellnum+'点';
							}
							break;
						case 32:
							//立即增加城池200点城防值
							if(ob!=null)
							{
							SanguoGlobal.userdata._wallExp = SanguoGlobal.userdata.wallExp + int(obj.item_effect_count)*ob.sellnum;
							str = '城池城防值增加'+obj.item_effect_count*ob.sellnum+'点';
							}
							break;
						case 33:
							//获得妻妾
							break;
						case 34:
							//威望提升符
							if(ob!=null)
							{
								SanguoGlobal.userdata._exp = SanguoGlobal.userdata.exp + int(obj.item_effect_count)*ob.sellnum;
								str = '威望增加'+obj.item_effect_count*ob.sellnum+'点';
							}
							break;
						case 35:
							//战功提升符
							if(ob!=null)
							{
								SanguoGlobal.userdata._fightPoint = SanguoGlobal.userdata.fightPoint + int(obj.item_effect_count)*ob.sellnum;
								str = '战功增加'+obj.item_effect_count*ob.sellnum+'点';
							}
							break
						default:break;
					}
					break;
				}
			}
			if(str=='') RPGScene.my.msg('道具使用成功');
			else RPGScene.my.msg(str);
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			
			return;
			var _list:Vector.<ItemData> = SanguoGlobal.userdata.getItemByitemid(itemid);
			if(_list.length)
			{
				_list[0]._num = _list[0].num - 1;
				if(_list[0].num==0) SanguoGlobal.userdata.delItem(_list[0].packageid);
			}
//			makeEvent(0xff01,[result,itemid]);
			return;
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as SZOperation == null) return;
			//判断itemid为书 刷新武将技能
			//SanguoGlobal.socket.RYcall(0xb004,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.nowGenid);
			
		}
		/**
		 * 开宝箱
		 */
		public function _ff02(buff:D5ByteArray):void
		{
			trace('ff02 开宝箱 =================');
			var result:int=buff.readInt();
			var arr:Array=new Array();
			var str:String='';
			for(var i:uint=0;i<result;i++)
			{
				var ar:Array=new Array();
				ar.push(buff.readInt());
				ar.push(buff.readInt());
				arr.push(ar);
				var cnt:uint=0;
				if(ar[0]<0)
				{
					str+=config(ar[0],+ar[1])+' ';
					if((cnt+1)%4==0)
					{
						str+="<br/>";
					}
					cnt++;
				}
				else
				{
					str+=SanguoGlobal.Configer.itemConfig(ar[0]).equ_prop_name+'+'+ar[1];
					cnt++;
					if((cnt+1)%4==0)
					{
						str+="<br/>";
					}
				}		
			}
			RPGScene.my.msg(str);
			var win:XWindow=WinBox.my.getWindow(BB_all);
			if(win!=null){
				SanguoGlobal.userdata.updatapackage((win as BB_all).refreshpg);
			}
			RPGScene.my.UI.updateUserinfo();
			makeEvent(0xff02);
			
		}
		private function config(id:int,num:int=100):String
		{
			var str:String='';
			switch(id)
			{
				case -1:
					SanguoGlobal.userdata._exp=SanguoGlobal.userdata.exp+num;
					return ' 威望+'+num;
					break;
				case -2:
					SanguoGlobal.userdata._fightPoint=SanguoGlobal.userdata.fightPoint+num;
					return ' 战功+'+num;
					break;
				case -3:
					if(SanguoGlobal.userdata.peopLike+num<SanguoGlobal.userdata.peoplike_limit)
					{
						SanguoGlobal.userdata._peopLike=SanguoGlobal.userdata.peopLike+num;
						return ' 民忠+'+num;
					}
					else {
						str=' 民忠+'+(SanguoGlobal.userdata.peoplike_limit-SanguoGlobal.userdata.peopLike)+' 已达上限';
						SanguoGlobal.userdata._peopLike=SanguoGlobal.userdata.peoplike_limit;
						return str;
					}
					break;
				case -4:
					if(SanguoGlobal.userdata.food+num<SanguoGlobal.userdata.food_limit)
					{
						SanguoGlobal.userdata._food=SanguoGlobal.userdata.food+num;
						return ' 粮草+'+num;
					}
					else {
						str=' 粮草+'+(SanguoGlobal.userdata.food_limit-SanguoGlobal.userdata.food)+' 已达上限';
						SanguoGlobal.userdata._food=SanguoGlobal.userdata.food_limit;
						return str;
					}
					break;
				case -5:
					if(SanguoGlobal.userdata.gold+num<SanguoGlobal.userdata.gold_limit)
					{
						SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold+num;
						return ' 银两'+num;
					}
					else {
						str=' 银两'+(SanguoGlobal.userdata.gold_limit-SanguoGlobal.userdata.gold)+' 已达上限';
						SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold_limit;
						return str;
					}
					break;
				case -6:
					SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					return ' 经验'+num;
					break;
				case -7:
					var XdlLimit:Array=[5,5,5,10,10,10,15,15,20,20];
					var lmt:uint=50;
					if(SanguoGlobal.userdata.vip>0)
					{
						lmt+=XdlLimit[SanguoGlobal.userdata.vip-1];
					}
					if(SanguoGlobal.userdata.action+num<lmt)
					{
						return ' 行动力'+num;
					}
					else{
						str=' 行动力+'+(lmt-SanguoGlobal.userdata.action)+' 已达上限';
						SanguoGlobal.userdata._action=lmt;
						return str;
					}
					break;
				case -8:
					SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb+num;
					return ' '+SanguoGlobal.Configer.wordkey(100)+'+'+num;
					break;
				default:return '';
			}
		}
		/**
		 * 获取主将数据
		 */
//		public function getGenData():GenData
//		{
//			for each(var data:GenData in SanguoGlobal.userdata.genList)
//			{
//				if(data.id >= 1000) return data;
//			}
//			return null;
//		}
		/**
		 * 出售商品
		 */
		public function _c00a(buff:D5ByteArray):void
		{
			var sale:int = buff.readByte();
			if(sale<0)
			{
				RPGScene.my.msg(Mather._0(sale));
				return;
			}
			
			//出售成功
			_scene.showMsg("出售成功！");
			
			SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold + SanguoGlobal.Configer.bagarr[0]*SanguoGlobal.Configer.bagarr[1];
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb + SanguoGlobal.Configer.bagarr[0]*SanguoGlobal.Configer.bagarr[2];
			
			RPGScene.my.UI.updateCityinfo();
			RPGScene.my.UI.updateUserinfo();
			
			makeEvent(0xc00a);
			
			//SanguoGlobal.socket.RYcall(0xff00,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.bagtype,SanguoGlobal.Configer.bagpage,SanguoGlobal.Configer.bagpernum);
			return;
		
		}
		
		/**
		 * 购买商品
		 */
		public function _c00b(buff:D5ByteArray):void
		{
			var buy:int = buff.readByte();
			
			if(buy < 0)
			{
				RPGScene.my.msg(Mather._0(buy));
				return;
			}
			if(SanguoGlobal.Configer.nowItemdata!=null) 
			{
				if(SanguoGlobal.Configer.buyType==0) SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - SanguoGlobal.Configer.nowItemdata.buy;
				else if(SanguoGlobal.Configer.buyType==1) SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - SanguoGlobal.Configer.nowItemdata.buy_rmb;
				_scene.showMsg("购买成功！");
				makeEvent(0xc00b);
//				SanguoGlobal.userdata.updatapackage();
//				SanguoGlobal.userdata.addItem(SanguoGlobal.Configer.nowItemdata);
			}
			//SanguoGlobal.userdata.updatapackage();
//			if(SanguoGlobal.Configer.BuyhorseID!=0&&SanguoGlobal.Configer.itemConfig(SanguoGlobal.Configer.BuyhorseID).equ_prop_type==3)
//			{
//				MissionChecker.setKEY('_51',true);
//			}
//			else 
//			if(SanguoGlobal.Configer.nowItemdata.id!=0&&SanguoGlobal.Configer.itemConfig(SanguoGlobal.Configer.nowItemdata.id).equ_prop_type==1)
//			{
				MissionChecker.setKEY('_49',true);
				
//			}
			if((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu!=null)
			{
				SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold-SanguoGlobal.Configer.itemConfig(SanguoGlobal.Configer.BuyhorseID).pay_silver;
			}
//			{ 
//				var temp:uint=(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Majiu).goumai.horseId;
//				if(temp!=0) 
//				{
//					SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold-SanguoGlobal.Configer.itemConfig(temp).pay_silver;
//					(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Majiu).goumai.horseId=0;
//				}
//				((_scene as MyCityScene).Operation as JGOperation).showMa2();
//			}
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			return;
		}
		
		/**
		 * 装备升级
		 */
		public function _c00c(buff:D5ByteArray):void
		{
			if(_scene==null ) return;
			MissionChecker.setKEY('_44',true);
			
			var levelup:int = buff.readByte();
			if(levelup<0)
			{
				RPGScene.my.msg(Mather._0(levelup));
				return;
				
			}else if(levelup==0)
			{
				RPGScene.my.UI.timelist();
				if(SanguoGlobal.Configer.nowSelectitem!=null&&SanguoGlobal.Configer.buyType==0) 
				{
					SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - Mather._1092(SanguoGlobal.Configer.nowSelectitem.buy,SanguoGlobal.Configer.nowSelectitem.slv);
					if(SanguoGlobal.Configer.nowSelectitem.slv>10&&SanguoGlobal.Configer.nowSelectitem.slv<16)
					{
						if(!SanguoGlobal.Configer.isUsehelp) SanguoGlobal.Configer.nowSelectitem._slv=SanguoGlobal.Configer.nowSelectitem.slv-1;
					}
					else if(SanguoGlobal.Configer.nowSelectitem.slv>15&&SanguoGlobal.Configer.nowSelectitem.slv<21)
					{
						if(!SanguoGlobal.Configer.isUsehelp) SanguoGlobal.Configer.nowSelectitem._slv=15
					}
					
				}
				RPGScene.my.msg('升级失败!');
				
				if(WinBox.my.getWindow(JG_Majiu)!=null)
				{
					((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu).CallBackQianghua();
				}
				if(WinBox.my.getWindow(Strengthen)!=null)
				{
					((_newWIN=WinBox.my.getWindow(Strengthen))as Strengthen).CallBackShenji();
				}
				RPGScene.my.UI.updateUserinfo();
				RPGScene.my.UI.updateCityinfo();
				return;
			}
			else if(levelup==1){
				 
				RPGScene.my.UI.timelist();
				//升级成功
				_scene.showMsg("升级成功！");
				if(SanguoGlobal.Configer.nowSelectitem!=null&&SanguoGlobal.Configer.buyType==0) 
				{
					
					SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - Mather._1092(SanguoGlobal.Configer.nowSelectitem.buy,SanguoGlobal.Configer.nowSelectitem.slv);
					var _ob:Object=SanguoGlobal.userdata.getItemBypackageid(SanguoGlobal.Configer.nowSelectitem.packageid)
					_ob._slv=_ob.slv+1;
				}
			}
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo()
			if(WinBox.my.getWindow(JG_Majiu)!=null)
			{
				((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu).CallBackQianghua();
			}
			if(WinBox.my.getWindow(Strengthen)!=null)
			{
				((_newWIN=WinBox.my.getWindow(Strengthen))as Strengthen).CallBackShenji();
			}
			
			//冷却时间
			var cdtime:uint = buff.readUnsignedInt();
			
			if(_scene as MyCityScene == null) return;
			RPGScene.my.UI.tl();
			
		}
		
		/**
		 * 装备升级的相关资料
		 */
		public function _c00d(buff:D5ByteArray):void
		{
			//2字节 当前攻击加成
			var att:uint = buff.readShort();
			
			//2字节 当前防御加成
			var defense:uint = buff.readShort();
			
			//4字节 冷却时间，若当前没有升级动作，则为0
			var cdtime:uint = buff.readUnsignedInt();
			
			//2字节 升级后的攻击加成
			var att_add:uint = buff.readShort();
			
			//2字节 升级后的防御加成
			var defense_add:uint = buff.readShort();
			
			//4字节 升级需要银两
			var gold:uint = buff.readUnsignedInt();
			
			//4字节 升级需要粮食
			var rmb:uint = buff.readUnsignedInt();

			//4字节 升级需要战功
			var exploit:uint = buff.readUnsignedInt();
			
			//4字节 升级需要碎片数量
			var broken:uint = buff.readUnsignedInt();

			var result:String = "攻 +"+att.toString()+" 防 +"+defense.toString()+"\n";
			result+="下一级：\n";
			result+="攻 +"+att_add.toString()+" 防 +"+defense_add.toString()+"\n";
			result+="耗费银两 "+gold.toString()+"\n";
			result+="耗费"+SanguoGlobal.Configer.wordkey(100)+" "+rmb.toString()+"\n";
			result+="耗费战功 "+exploit.toString() +" 碎片 "+result+'个';
			
			if(_scene as MyCityScene == null) return;
			/*
			var itemShower:IItemShower = (_scene as MyCityScene).Operation.win2 as IItemShower;
			if(itemShower == null) return;
			itemShower.ItemMyInfo(cdtime,result);
			*/
			RPGScene.my.UI.timelist();
			RPGScene.my.UI.tl();
			if(_scene==null ) return;
			return;
		}
		
		/**
		 * 神秘商人福禄榜
		 */
		public function _c109(buff:D5ByteArray):void
		{
			var totle:int=buff.readByte();
			
			var _arr:Array=new Array();
			for(var i:uint=0;i<totle;i++)
			{
				var arr:Array=new Array();
				arr.push(buff.readUTFBytes(30));//昵称
				arr.push(buff.readInt());//物品ID
				arr.push(buff.readByte());//货币类型 1 元宝 2 银两
				arr.push(buff.readInt());//价格
				
				var $name:String = '<font color="#ffcc00">'+arr[0]+'</font>';
				var $item:ItemData = SanguoGlobal.userdata.newItem(arr[1]);
				var $itemname:String = '<font color="#'+Mather._10($item.lv)+'">'+$item.name+'</font>';
				
				var str:String = $name + '购得了'+ $itemname;
				
				_arr.push(str);
			}
			
			if(_arr.length>10) _arr.splice(0,_arr.length-10);
			
			if(WinBox.my.getWindow(SecretBussy)!=null)
			{
				((_newWIN=WinBox.my.getWindow(SecretBussy))as SecretBussy).refreshlist(_arr);
				return;
			}
		}
		/**
		 * 可招募的将领列表
		 */
		public function _c00e(buff:D5ByteArray):void
		{
			//1字节 武将个数
			var count:uint = buff.readByte();
			
			//4字节 刷新冷却期
			var cdtime:int=buff.readInt();
			
			//2字节 花费元宝
			//var rmb:uint = buff.readShort();
			
			//4字节 武将ID
			var uid:int;
			
			//2字节 武将统率值
			var value_tongyu:uint;
			
			//2字节 武将勇武值
			var value_yongwu:uint;
			
			//2字节 武将智力值
			var value_zhili:uint;
			
			// 武将工资
			var gen_p:uint;
			
			RPGScene.my.UI.timelist();
			var arr:Array = new Array();
			for(var i:uint; i < count; i++)
			{
				gen_p = buff.readUnsignedInt();
				uid = buff.readInt();
				value_tongyu = buff.readShort();
				value_yongwu = buff.readShort();
				value_zhili = buff.readShort();
				var arrTemp:Array=new Array();
				arrTemp.push(uid,gen_p);
				arr.push(arrTemp);
				trace('id==',uid);
				
			}
//			if(_scene as MyCityScene == null) return;
//			if((_scene as MyCityScene).Operation as JGOperation == null) return;
//					
//			if(((_scene as MyCityScene).Operation as JGOperation).Type == 1 && SanguoGlobal.userdata.rmb >= 20)
//			{
//				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 20;
//				
//			}else{
//				Sanguo.my.UI.timelist();
			
//				Sanguo.my.UI.tl();
//			}
			
			if(SanguoGlobal.Configer.shuaselect==1){
				
				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 20;
				SanguoGlobal.Configer.shuaselect=2;
			}
			
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			
			((_newWIN=WinBox.my.getWindow(JG_Zhaomu))as JG_Zhaomu)._4(arr);
//			((_scene as MyCityScene).Operation as JGOperation).showGen(arr);
			
		}
		
		/**
		 * 获取可招募对象
		 */ 
		public function _c019(buff:D5ByteArray):void
		{
			//1字节 武将个数
			var count:uint = buff.readByte();
			
			//4字节 刷新冷却期
			var cdtime:int=buff.readInt();
			
			//2字节 花费元宝
			//var rmb:uint = buff.readShort();
			
			//4字节 武将ID
			var uid:int;
			
			//2字节 武将统率值
			var value_tongyu:uint;
			
			//2字节 武将勇武值
			var value_yongwu:uint;
			
			//2字节 武将智力值
			var value_zhili:uint;
			
			// 武将工资
			var gen_p:uint;
			
			
			var arr:Array = new Array();
			for(var i:uint; i < count; i++)
			{
				gen_p = buff.readUnsignedInt();
				uid = buff.readInt();
				value_tongyu = buff.readShort();
				value_yongwu = buff.readShort();
				value_zhili = buff.readShort();
				var arrTemp:Array=new Array();
				arrTemp.push(uid,gen_p);
				arr.push(arrTemp);
			}
			SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb-20;
			
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as JGOperation == null) return;
			RPGScene.my.UI.timelist();
			if(((_scene as MyCityScene).Operation as JGOperation).Type == 1 && SanguoGlobal.userdata.rmb >= 20)
			{
				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 20;
			}
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			((_scene as MyCityScene).Operation as JGOperation).showGen(arr);
			if(_scene==null ) return;
			
		}

		
		/**
		 * 赠与喜好品
		 */
		public function _c020(buff:D5ByteArray):void
		{
			var result:int = buff.readInt();
			SanguoGlobal.Configer.taskCompleteNum++;
			MissionChecker.setKEY('_60',true);
			makeEvent(0xc020,result);
			if(!result)
			{
				RPGScene.my.msg('赠与失败!');
				return;
			}
			
			RPGScene.my.msg('亲密度提升');
			
			return;
			//Sanguo.my.UI.onClick_public(0,[4]);
			if(_scene as MyCityScene==null) return;
			if((_scene as MyCityScene).Operation as JGOperation==null) return;
			SanguoGlobal.Configer.nowNPCID=0;
		}
		
		/**
		 * 聊天
		 */
		public function _c021(buff:D5ByteArray):void
		{
			var result:int = buff.readInt();
			SanguoGlobal.Configer.taskCompleteNum++;
			MissionChecker.setKEY('_60',true);
			if(result==0)
			{
				RPGScene.my.msg('你被华丽的无视了');
				return;
			}else if(result==-1){
				RPGScene.my.msg('改日再聊吧');
				return;
			}
			RPGScene.my.msg('亲密度略微提升');
		}
		
		/**
		 * 得到友好度
		 */
		public function _c022(buff:D5ByteArray):void
		{
			var friend:int = buff.readInt();
			var friend_limit:int = buff.readInt();
			
			makeEvent(0xc022,[friend,friend_limit]);
		}
		
		/**
		 * 亲密度招募武将
		 */
		public function _c023(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			if(result<0)
			{
				if(result==-1) RPGScene.my.msg('亲密度不足');
				else if(result==-2) RPGScene.my.msg('威望不足');
				else RPGScene.my.msg(Mather._0(result));
				return;
			}
			RPGScene.my.msg('招募成功');
			
			SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		
		/**
		 * 自动刷新武将
		 */
		public function _c024(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
//			if(result<0)
//			{
//				Sanguo.my.msg(Mather._0(result));
//				return;
//			}else if(!result){
//				Sanguo.my.msg(Mather._0('操作失败'));
//				return;
//			}
			
			//刷新用过的次数
			var num:int = buff.readInt();
			
			if(num<0)
			{
				RPGScene.my.msg(Mather._0(num));
				return;
			}else if(!num){
				RPGScene.my.msg('操作失败');
				return;
			}
			
			//武将个数
			var gennum:uint = buff.readByte();
			
			var arr:Array = new Array();
			for(var i:uint; i < gennum; i++)
			{
				var gen_p:uint = buff.readUnsignedInt();
				var id:int = buff.readInt();
				var value_tongyu:int = buff.readShort();
				var value_yongwu:int = buff.readShort();
				var value_zhili:int = buff.readShort();
				var arrTemp:Array=new Array();
				arrTemp.push(id,gen_p);
				arr.push(arrTemp);
			}
			
			if(SanguoGlobal.Configer.depType==WorkID.SHUAJIANG)
			{
				SanguoGlobal.userdata.useItemByID(WorkID.ITEM_SHUAJIANG,num);
				SanguoGlobal.Configer.depType = 0;
				SanguoGlobal.Configer.depNum = 0;
			}else{
				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 20 * num;
				RPGScene.my.UI.updateUserinfo();
			}
			
			((_newWIN=WinBox.my.getWindow(JG_Zhaomu))as JG_Zhaomu)._4(arr);
			
			RPGScene.my.msg('刷新次数'+num);
		}
		
		/**
		 * 自动刷新马匹
		 */
		public function _c025(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			//刷新次数
			var num:int = buff.readInt();
			
			if(num<0)
			{
				RPGScene.my.msg(Mather._0(num));
				return;
			}else if(!num){
				RPGScene.my.msg('操作失败');
				return;
			}
			
			//马匹个数
			var gennum:uint = buff.readByte();
			
			var arr:Array = new Array();
			for(var i:uint; i < gennum; i++)
			{
				var gen_p:uint = buff.readUnsignedInt();
				var id:int = buff.readInt();
				var value_tongyu:int = buff.readShort();
				var value_yongwu:int = buff.readShort();
				var value_zhili:int = buff.readShort();
				var arrTemp:Array=new Array();
				arrTemp.push(id,gen_p);
				arr.push(arrTemp);
			}
			
			if(SanguoGlobal.Configer.depType==WorkID.SHUAMA)
			{
				SanguoGlobal.userdata.useItemByID(WorkID.ITEM_SHUAMA,num);
				SanguoGlobal.Configer.depType = 0;
				SanguoGlobal.Configer.depNum = 0;
			}else{
				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 20 * num;
				RPGScene.my.UI.updateUserinfo();
			}
			
			((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu)._4(arr);
			
			RPGScene.my.msg('刷新次数'+num);
		}
		
		/**
		 * 国家赋税调整
		 */ 
		public function _c030(buff:D5ByteArray):void
		{
			//2字节 总名城个数
			var chengNum:uint=buff.readShort();
			var a:Array=new Array();
			for(var i:uint=0;i<chengNum;i++)
			{
				var arr:Array=new Array();
				//2字节 名城编号
				var cityId:uint=buff.readShort();
				// 	1字节 是否征收过 0否 1是
				var sign:uint=buff.readByte();
				//30字节 太守昵称
				var name:String=buff.readUTFBytes(30);
				//4字节 剩余银两库存
				var yingb:uint=buff.readUnsignedInt();
				
				arr.push(cityId,name,yingb,sign);		
				a.push(arr);
				trace("<c030>",chengNum,cityId,name,yingb,sign)
			}
			
			
			if(WinBox.my.getWindow(HG_NeiZheng))
			{	
				var opt:HG_NeiZheng = WinBox.my.getWindow(HG_NeiZheng) as HG_NeiZheng;
				opt.showList(a);
			}
			
			
			
			//			if(_scene as MyCityScene==null) return;
			//			if((_scene as MyCityScene).Operation as HGOperation==null) return;
			//			((_scene as MyCityScene).Operation as HGOperation).showList(a);
		}
		
		/**
		 * 国家征税
		 */ 
		public function _c031(buff:D5ByteArray):void
		{
			//1字节 操作结果
			var result:int=buff.readByte();
			//4字节 税收金额
			var shuishou:uint=buff.readInt();
			//4字节 国库现在的剩余金额
			var guoku:uint=buff.readUnsignedInt();
			//4字节 被征税府库的剩余金额
			var fuku:uint=buff.readUnsignedInt();
//			trace("<c031>",result,shuishou,guoku,fuku);
			if(result==1)
			{
				SanguoGlobal.Configer.CountryMoney=guoku;
				SanguoGlobal.socket.RYcall(0xc030,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.country);
				
//				if(Sanguo.my.UI.operation.win2 is HG_NeiZheng)
//				{	
//					var opt:HG_NeiZheng = Sanguo.my.UI.operation.win2 as HG_NeiZheng;
//					//if(fuku>0)  opt.setRcontent(guoku,1);
//					//else opt.setRcontent(guoku,0);
//				}
			}
		}
		
		
		/**
		 * 招募武将
		 */
		public function _c00f(buff:D5ByteArray):void
		{
			var enlist:int = buff.readByte();
			if(enlist < 0)
			{
				RPGScene.my.msg(Mather._0(enlist));
				return;
			}
			
			if(enlist==1)
			{
//				if(_scene as MyCityScene==null) return;
//				if((_scene as MyCityScene).Operation as JGOperation==null) return;
////				var temp:uint=(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Zhaomu).gid;
//			    var  arr:Array=new Array();
//				arr=(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Zhaomu).dataArray;
//	
//				for each (var tarr:Array in arr)
//				{
//					if(tarr[0]==temp)  SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold-tarr[1];
//					
//				}
				var _gen:GenData=new GenData();
				_gen.gen_id=((_newWIN=WinBox.my.getWindow(JG_Zhaomu))as JG_Zhaomu).zhaomu_id;
				SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold-((_newWIN=WinBox.my.getWindow(JG_Zhaomu))as JG_Zhaomu).money;
				SanguoGlobal.userdata.genList.push(_gen);
				RPGScene.my.updateGenList(); // 更新我的武将列表
				_scene.showMsg("招募武将成功！");
				if(SanguoGlobal.userdata.genList&&SanguoGlobal.userdata.genList.length>3) MissionChecker.setKEY('_4',true);
				SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
				//SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				((_newWIN=WinBox.my.getWindow(JG_Zhaomu))as JG_Zhaomu).Cover_1();
				
				
			}else{
//				if((_scene as MyCityScene)==null) return;
//				if((_scene as MyCityScene).Operation as JGOperation==null) return;
//				(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Zhaomu).uplist();
				
				_scene.showMsg("招募武将失败！");
			}
		}
		
		
		
		/**
		 * 可购买的马匹列表
		 */
		public function _c010(buff:D5ByteArray):void
		{
			
			var num:uint = buff.readUnsignedByte();
			var cd:uint = buff.readUnsignedInt();
			//4字节 武将ID
			var uid:int;
			
			//2字节 武将统率值
			var value_tongyu:uint;
			
			//2字节 武将勇武值
			var value_yongwu:uint;
			
			//2字节 武将智力值
			var value_zhili:uint;
			
			// 马匹价格
			var gen_p:uint;
			
			if(num>0)
			{
				var arr:Array = new Array();
				for(var i:uint; i < num; i++)
				{
					gen_p = buff.readUnsignedInt();
					uid = buff.readInt();
					value_tongyu = buff.readShort();
					value_tongyu = buff.readShort();
					value_zhili = buff.readShort();
					var tempArr:Array=new Array();
					tempArr.push(uid,gen_p);
					arr.push(tempArr);
				}
			}
			if(_scene as MyCityScene == null) return;
			if(num==0)
			{
				(_scene as MyCityScene).showMsg('没有可购买的马匹。下次请早！');
				return;
			}
			
//			if((_scene as MyCityScene).Operation as JGOperation == null) return;
//			((_scene as MyCityScene).Operation as JGOperation).showMa(arr);
			
//			var temp:uint=(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Majiu).goumai.freshH;
			var temp:int=SanguoGlobal.Configer.shuaselect;
			((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu)._4(arr)

			if(temp==1){
				SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb-20;
				RPGScene.my.UI.updateUserinfo();
				RPGScene.my.UI.updateCityinfo();
				SanguoGlobal.Configer.shuaselect=2;
			}else RPGScene.my.UI.timelist();
		}
		
		/**
		 * 马匹驯养
		 */
		public function _c011(buff:D5ByteArray):void
		{
			var levelup:int = buff.readByte();
			MissionChecker.setKEY('_70',true);
			if(levelup<0)
			{
				RPGScene.my.msg(Mather._0(levelup));
				return;
				
			}else if(levelup==0)
			{
				RPGScene.my.UI.timelist();
				if(SanguoGlobal.Configer.nowSelectitem!=null&&SanguoGlobal.Configer.buyType==0) 
				{
					SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - Mather._1092(SanguoGlobal.Configer.nowSelectitem.buy,SanguoGlobal.Configer.nowSelectitem.slv);
					if(SanguoGlobal.Configer.nowSelectitem.slv>10&&SanguoGlobal.Configer.nowSelectitem.slv<16)
					{
						if(!SanguoGlobal.Configer.isUsehelp) SanguoGlobal.Configer.nowSelectitem._slv=SanguoGlobal.Configer.nowSelectitem.slv-1;
					}
					else if(SanguoGlobal.Configer.nowSelectitem.slv>15&&SanguoGlobal.Configer.nowSelectitem.slv<21)
					{
						if(!SanguoGlobal.Configer.isUsehelp) SanguoGlobal.Configer.nowSelectitem._slv=15
					}
					
				}
				RPGScene.my.msg('升级失败!');
				
				if(WinBox.my.getWindow(JG_Majiu)!=null)
				{
					((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu).CallBackQianghua();
				}
				if(WinBox.my.getWindow(Strengthen)!=null)
				{
					((_newWIN=WinBox.my.getWindow(Strengthen))as Strengthen).CallBackShenji();
				}
				RPGScene.my.UI.updateUserinfo();
				RPGScene.my.UI.updateCityinfo();
				return;
			}
			else if(levelup==1){
				
				RPGScene.my.UI.timelist();
				//升级成功
				_scene.showMsg("升级成功！");
				if(SanguoGlobal.Configer.nowSelectitem!=null&&SanguoGlobal.Configer.buyType==0) 
				{
					
					SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold - Mather._1092(SanguoGlobal.Configer.nowSelectitem.buy,SanguoGlobal.Configer.nowSelectitem.slv);
					var _ob:Object=SanguoGlobal.userdata.getItemBypackageid(SanguoGlobal.Configer.nowSelectitem.packageid)
					_ob._slv=_ob.slv+1;
				}
			}
			
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo()
			if(WinBox.my.getWindow(JG_Majiu)!=null)
			{
				((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu).CallBackQianghua();
			}
			if(WinBox.my.getWindow(Strengthen)!=null)
			{
				((_newWIN=WinBox.my.getWindow(Strengthen))as Strengthen).CallBackShenji();
			}
			
			//冷却时间
			var cdtime:uint = buff.readUnsignedInt();
			
			if(_scene as MyCityScene == null) return;
			RPGScene.my.UI.tl();
			
			if(_scene==null ) return;
			MissionChecker.setKEY('_44',true);
			return;
		}
		
		/**
		 * 马匹驯养信息
		 */
		public function _c012(buff:D5ByteArray):void
		{
			var arr:Array = new Array();
			
			//2字节 当前统率加成
			var add_tongyu:uint = buff.readShort();
			arr.push(add_tongyu);
			
			//2字节 当前勇武加成
			var add_yongwu:uint = buff.readShort();
			arr.push(add_yongwu);
			
			//2字节 当前智谋加成
			var add_zhili:uint = buff.readShort();
			arr.push(add_zhili);
			
			//4字节 冷却时间，若当前没有升级动作，则为0
			var cdtime:uint = buff.readUnsignedInt();
			arr.push(cdtime);
			
			//2字节 升级后的统率加成
			var add_tongyu_lev:uint = buff.readShort();
			arr.push(add_tongyu_lev);
			
			//2字节 升级后的勇武加成
			var add_yongwu_lev:uint = buff.readShort();
			arr.push(add_yongwu_lev);
			
			//2字节 升级后的智谋加成
			var add_zhili_lev:uint = buff.readShort();
			arr.push(add_zhili_lev);
			
			//4字节 升级需要粮食
			var provisions:uint = buff.readUnsignedInt();
			arr.push(provisions);
			
			//4字节 升级需要银两
			var gold:uint = buff.readUnsignedInt();
			arr.push(gold);
			
			//4字节 升级需要战功
			var enlist:uint = buff.readUnsignedInt();
			arr.push(enlist);
			
			//4字节 升级需要碎片数量
			var broken:uint = buff.readUnsignedInt();
			arr.push(broken);
			
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as JGOperation == null) return;
			((_scene as MyCityScene).Operation as JGOperation).showXuny(arr);
		}
		
		/**
		 * 消息打探
		 */
		public function _c013(buff:D5ByteArray):void
		{
			var tie:int = buff.readByte();
			if(tie < 0)
			{
				RPGScene.my.msg(Mather._0(tie));
				return;
			}
			//4字节 银币
			var money:uint = buff.readUnsignedInt();
			
			//4字节 粮食
			var food:uint = buff.readUnsignedInt();
			
			//4字节 人口
			var peop:uint = buff.readUnsignedInt();
			
			//4字节 兵力
			var army:uint = buff.readUnsignedInt();
			
			_scene.notice('打探到目标的相关消息：'+'\n'+'银币：'+ money +'\n'+'粮食：'+ food +'\n'+'人口：'+ peop +'\n'+'兵力：'+ army);
		}
		
		/**
		 * 物品兑换
		 */
		public function _c014(buff:D5ByteArray):void
		{
			//兑换物品数量 0为兑换失败 小于0为失败原因
			var num:uint = buff.readShort();
			
			//2字节 第一物品剩余数量
			var fnum:uint = buff.readShort();
			
			//2字节 第二物品剩余数量
			var snum:uint = buff.readShort();
			
			//2字节 第三物品剩余数量
			var tnum:uint = buff.readShort();
			
			//2字节 第四物品剩余数量
			var fonum:uint = buff.readShort();
			
			//以下内容循环
			for(var i:uint=0;buff.length=0;i++)
			{
				//4字节 兑换物品ID
				var itemid:uint = buff.readUnsignedInt();
				
				//4字节 兑换物品个数
				var itemnum:uint = buff.readUnsignedInt();
			}

		}
		
		/**
		 * 神秘商人获取
		 */
		public function _c015(buff:D5ByteArray):void
		{
			
			var result:int = buff.readByte();
			var timer:uint=buff.readUnsignedInt();
			var total:uint = buff.readShort();
			
			var itemdata:Vector.<ItemData> = new Vector.<ItemData>;
			for(var i:uint=0;i<total;i++)
			{
				var uid:uint = buff.readUnsignedInt();
				var lvl:uint = buff.readUnsignedInt();
				var uname:String = buff.readUTFBytes(20);
				var lv:uint = buff.readByte();
				var price:uint = buff.readUnsignedInt();
				var rmb:int = buff.readUnsignedInt();
				var sell:uint = buff.readUnsignedInt();
//				数量
				var count:uint = buff.readShort();
				var state:uint = buff.readByte();
				
				var item:ItemData = SanguoGlobal.userdata.newItem(uid);
				item._id = uid;
				item._slv = lvl;
				item._lv = lv;
				item._buy = price;
				item._buy_rmb = rmb;
				item._sell = sell;
				item._num = count;
				item._state=state;
				itemdata.push(item);
				
			}
			
			if((_scene as MyCityScene)==null) return;
			if((_scene as MyCityScene).Operation as BaseOperation == null) return;
			if(result != -2)
			{
				if(SanguoGlobal.Configer.depType==WorkID.BUSSYRESET)
				{
					SanguoGlobal.userdata.useItemByID(WorkID.ITEM_BUSSYRESET,SanguoGlobal.Configer.depNum);
					SanguoGlobal.Configer.depType = 0;
					SanguoGlobal.Configer.depNum = 0;
				}else{
					//记得补上扣钱 刷新信息(判断是不是强制刷新 现在强制刷新扣除10元宝 以后看策划)
					if(SanguoGlobal.Configer.deleteGoal==1)
					{
						SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb-10;
						RPGScene.my.UI.updateUserinfo();
						RPGScene.my.UI.updateCityinfo();
						SanguoGlobal.Configer.deleteGoal=0;
					}
				}

				((_scene as MyCityScene).Operation as BaseOperation).showBussy(itemdata);
			
			}

		}
		
		/**
		 * 神秘商人商品购买
		 */
		public function _c016(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			trace("神秘商人商品购买=====================",result);
			if(result==-7)
			{
				result=-5;
			}
			if(result==-5)
			{
				result=-7;
			}
			if(result==-2)
			{
//				Sanguo.my.UI.sceneChange(1);
//				(Sanguo.my.scene as MyCityScene).onClickBuilding(SanguoGlobal.userdata.posArea);
				RPGScene.my.msg("神秘商人走了")
				return
			}
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			switch(result)
			{
				//潘龙添加  报错提示
				case 0:
					RPGScene.my.msg('购买失败!');
					break;
				case 1: 
					RPGScene.my.msg('购买成功!');
//					扣去强制刷新的金币 刷新 界面
					if(SanguoGlobal.Configer.buyob.type==0)
					{
						SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold-SanguoGlobal.Configer.buyob.num;
					}
					else
					{
						SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb-SanguoGlobal.Configer.buyob.num;
					}
					SanguoGlobal.userdata.updatapackage();
					RPGScene.my.UI.updateUserinfo();
					RPGScene.my.UI.updateCityinfo();
								
					
					//刷新商人 物品列表 （去服务器取）
					
					//去获取神秘商人物品列表 （可能别人在你买的时候也买了）
					SanguoGlobal.socket.RYcall(0xc015,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.posArea,SanguoGlobal.Configer.nowBuilderId,2);
					//更新福禄榜 （这里缺少服务器消息 记得以后添加）
					SanguoGlobal.socket.RYcall(0xc109,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//					((_scene as MyCityScene).Operation as BaseOperation)._rongyaobang(1);
			
					break;
			}
		}
		/**
		 * 获取税率
		 */
		public function _c017(buff:D5ByteArray):void
		{
			var fushui:Number =buff.readShort();
			var time:uint=buff.readUnsignedInt();
			
			if(RPGScene.my.UI.operation==null) return;
			if(WinBox.my.getWindow(GD_Zhengling)!=null)
			{
//				var opt:GD_Zhengling = Sanguo.my.UI.operation.win2 as GD_Zhengling;
				(WinBox.my.getWindow(GD_Zhengling)as GD_Zhengling).setLcontent(fushui,time);	
				SanguoGlobal.socket.RYcall(0xcd05,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.province);
			}
			
			//			if(_scene as MyCityScene == null) return;
			//			if((_scene as MyCityScene).Operation as GDOperation == null) return;
			//			((_scene as MyCityScene).Operation as GDOperation).reFushui(fushui,time);
			
		}
		
		public function _c018(buff:D5ByteArray):void
		{
			var success:int = buff.readByte();
			
			makeEvent(0xc018,success);
			
			if(success==0)
			{
				_scene.showMsg('解雇武将失败');
				return;
			}else if(success<0){
				_scene.showMsg(Mather._0(success));
				return;
			}
			
//			if(success == 1){
//				_scene.showMsg('解雇武将成功');
//				
//				Sanguo.my.UI.updateCityinfo();
//				Sanguo.my.UI.updateUserinfo();
//				
//				var city:MyCityScene = Sanguo.my.scene as MyCityScene;
//				if(city==null) return;
//				if(city.operation as SZOperation==null) return;
//				(city.operation as SZOperation).fireGen();
//				return;
//			}else if(success == 0){
//				_scene.showMsg('解雇武将失败');
//				return;
//			}else{
//				_scene.showMsg('数据异常');
//				return;
//			}
		}
		
		/**
		 * 君王巡视
		 */
		public function _cc00(buff:D5ByteArray):void
		{
			var success:int = buff.readByte();
			if(success == -8)
			{
				_scene.showMsg('权限不足');
				return;
			}else if(success == -5){
				_scene.showMsg('巡查次数已耗尽');
				return;
			}else if(success == -4){
				_scene.showMsg('该城池已被巡查');
				return;
				
			}else if(success == 0){
				_scene.showMsg('巡视失败');
				return;
			}else if(success == 1){
				//巡视成功
				_scene.showMsg('巡视成功');
				return;
			}
			if(_scene==null ) return;
			RPGScene.my.UI.timelist();
		}
		/**
		 * 获取国家/名城概况
		 */ 
		public function _cd00(buff:D5ByteArray):void
		{

			// 1字节 原封返回分类(0皇帝 1国家)
			var type:uint = buff.readUnsignedByte();
			// 4字节 领袖用户ID（国家为皇帝，地区为太守
			var id:uint=buff.readUnsignedInt();
			//4字节 领袖等级
			var lv:uint=buff.readUnsignedInt();
			//4字节 领袖威望
			var weiwang:uint=buff.readUnsignedInt();
			//4字节 赞成票
			var agree:uint=buff.readUnsignedInt();
			//4字节 总票数
			var tolagree:uint=buff.readUnsignedInt();
			//4字节  领袖的LVONE武将ID
			var headid:uint=buff.readUnsignedInt();
			SanguoGlobal.Configer._leaderHeadId=headid;
			//4字节 领袖战功
			var jungong:uint=buff.readUnsignedInt();
			//4字节 当前府库/国库余额
			var fuku:uint=buff.readUnsignedInt();
			//30字节 领袖昵称
			var nam:String=buff.readUTFBytes(30);	
			//4字节 投票CD
			var CD1:int=buff.readInt();
			//4字节 修改公告CD
			var CD2:uint=buff.readUnsignedInt();
			//1字节 投票记录数量（不超过20）
			var len:uint=buff.readByte();
			if(AreaScene.gettaishou==false&&WorldCityScene.getnickname==0)
			{
				var arr:Array = new Array();
	//			
				if(type==0)
				{
					SanguoGlobal.Configer.CountryMoney=fuku;
					SanguoGlobal.Configer.CountryZhanGong=jungong;
				}
				if(type==1)
				{
					SanguoGlobal.Configer.CityMoney=fuku;
					SanguoGlobal.Configer.CityZhanGong=jungong;
				}
				for(var i:uint=0;i<len;i++)
				{
					//1字节 投票结果
					var result:int=buff.readByte();
					//30字节 投票用户昵称
					var niceng:String=buff.readUTFBytes(30);
					
					arr.push([result?'<font color="#faad40">明君</font>':'<font color="#fc4724">庸君</font>',niceng]); 
				}
				trace('agree:'+agree,'tolagree:'+tolagree,'CD1:'+CD1,'CD2:'+CD2);
				/*

				*/
				var tempArr:Array=new Array();
				tempArr.push(id,lv,weiwang,agree,tolagree,headid,jungong,fuku,nam,CD1,CD2,arr);
				
					
				trace("<cd00>",tempArr);
				
				
				makeEvent(0xcd00,tempArr);
			}
			else
				if(AreaScene.gettaishou==true)
				{
				var areascene:AreaScene=_scene as AreaScene;
					if(areascene!=null)
					{
						if(nam!=null&&nam!='')
						{
						SanguoGlobal.userdata._areaTaishou=nam;
						}
						areascene.clickCity();
					}
					AreaScene.gettaishou=false;
				}
				else if(WorldCityScene.getnickname!=0)
				{
					
					var worldscene:WorldCityScene=_scene as WorldCityScene;
				
		            if(worldscene!=null&&WorldCityScene.getnickname==1)
					{
						if(nam!=null&&nam!='')
						{
						SanguoGlobal.userdata._areaHuangdi=nam;
						}
						worldscene.getTaishou();
					}
					else if(worldscene!=null&&WorldCityScene.getnickname==2)
					{
						if(nam!=null&&nam!='')
						{
							SanguoGlobal.userdata._areaTaishou=nam;
						}
						worldscene.clickworld();
						WorldCityScene.getnickname=0;
					}
					
				}
			return;
			
			if(RPGScene.my.UI.operation==null) return;
			if(RPGScene.my.UI.operation.win2 is HG_NeiZheng)
			{
				
				var opt2:HG_NeiZheng = RPGScene.my.UI.operation.win2 as HG_NeiZheng;
				
				opt2.CountyInfo(tempArr);
				opt2.setLeaderCD(CD2,CD1);
				opt2.showLeaderRoll(arr);
			}
			
			if(RPGScene.my.UI.operation.win2 is GD_Zhengling)
			{
				
				var opt:GD_Zhengling = RPGScene.my.UI.operation.win2 as GD_Zhengling;
				
				opt.CountyInfo(tempArr);
				opt.setLeaderCD(CD2,CD1);
				opt.showLeaderRoll(arr);
			}
			
			
			
			//			if(Sanguo.my.scene.operation is GDOperation)
			//			{
			//				var opt:GDOperation = Sanguo.my.scene.operation as GDOperation;
			//				
			//				opt.showLeaderInfo(id,lv,weiwang,mingwang,headid,jungong,fuku,nam);
			//				opt.setLeaderCD(CD2,CD1);
			//				opt.showLeaderRoll(arr);
			//			}
		}
		/**
		 * 修改国家/名城的公告
		 */ 
		public function _cd01(buff:D5ByteArray):void
		{
			//1字节操作结果 -1 权限不足 0 CD未到 1成功
			var result:int=buff.readByte();
			//4字节 CD时间
			var time:uint=buff.readUnsignedInt();
			if(result==-1)
			{
				_scene.showMsg('权限不足！！');
				return;
			}else if(result==0)
			{
				_scene.showMsg('正在冷却中');
				return;
			}else if(result==1)
			{
				_scene.showMsg('修改成功！');
				return;	
			}
				
		}
		/**
		 * 给领袖投票
		 */ 
		public function _cd02(buff:D5ByteArray):void
		{
			//1字节操作结果 -1 权限不足 0 CD未到 1成功
			var result:int=buff.readByte();
			//4字节 CD时间
			var time:uint=buff.readUnsignedInt();
//			trace(result,"---",time);
			if(result==-1)
			{
				_scene.showMsg('权限不足！！');
				return;
			}else if(result==0)
			{
				_scene.showMsg('未知错误！');
				return;
			}else if(result<0){
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			if(result==1)
			{
				_scene.showMsg('投票成功！');
				
				makeEvent(0xcd02);
				return;	
				if(SanguoGlobal.userdata.workMode==0)SanguoGlobal.socket.RYcall(0xcd00,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.workMode,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.country);
				else if(SanguoGlobal.userdata.workMode==1) SanguoGlobal.socket.RYcall(0xcd00,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.workMode,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.province);
				
			}
		}
		
		/**
		 * 获取领袖昵称
		 */
		public function _cd03(buff:D5ByteArray):void
		{
			//皇帝ID
			var kingID:uint = buff.readUnsignedInt();
			//皇帝头像ID
			//var kingHead:uint = buff.readUnsignedInt();
			//皇帝昵称
			var kingName:String = buff.readUTFBytes(30);
			
			//太守ID
			var shouID:uint = buff.readUnsignedInt();
			//太守头像ID
			//var shouHead:uint = buff.readUnsignedInt();
			//太守昵称
			var shouName:String = buff.readUTFBytes(30);
			if(kingID==0) kingName=""+Mather._13(SanguoGlobal.userdata.country);
			if(shouID==0) shouName=""+Mather.getTaishou(SanguoGlobal.userdata.province);
			//if(_scene == null) return;
			SanguoGlobal.userdata._huangdi=kingName;
			SanguoGlobal.userdata._taishou=shouName;
			RPGScene.my.UI.hName.htmlText = kingName;
			RPGScene.my.UI.tName.htmlText = shouName;
			
			makeEvent(0xcd03);
		}
		/**
		 * 读取国家/地区公告
		 */ 
		public function  _cd04(buff:D5ByteArray):void
		{
			var str:String=buff.readUTFBytes(600);
			
			makeEvent(0xcd04,str);
			return;
			if(RPGScene.my.UI.operation.win2 is HG_NeiZheng)
			{
				var opt2:HG_NeiZheng = RPGScene.my.UI.operation.win2 as HG_NeiZheng;
				
				opt2.gonggao(str);
			}
			
			
			
			if(RPGScene.my.UI.operation.win2 is GD_Zhengling)
			{
				var opt:GD_Zhengling = RPGScene.my.UI.operation.win2 as GD_Zhengling;
				
				opt.gonggao(str);
			}
			
			//			if(_scene as MyCityScene == null) return;
			//			if((_scene as MyCityScene).Operation as GDOperation == null) return;
			//			((_scene as MyCityScene).Operation as GDOperation).gonggao(str);
			
		}
		
		
		/**
		 * 读取国家/地区库存
		 */ 
		public function _cd05(buff:D5ByteArray):void
		{
			//4字节 库存
			var money:uint=buff.readUnsignedInt();
			//1字节 是否可以提取 
			var Max:uint=buff.readByte();
//			if(Sanguo.my.UI.operation.win2 is GD_Zhengling)
//			{
//				var opt:GD_Zhengling = Sanguo.my.UI.operation.win2 as GD_Zhengling;
//				opt.setRcontent(money,Max);
//			}
			if(WinBox.my.getWindow(GD_Zhengling)!=null)
			{
				(WinBox.my.getWindow(GD_Zhengling)as GD_Zhengling).setRcontent(money,Max);;	
			}
			
			
			//			if(_scene as MyCityScene == null) return;
			//			if((_scene as MyCityScene).Operation as GDOperation == null) return;
			//			((_scene as MyCityScene).Operation as GDOperation).setRcontent(money,Max);
			/*
			if(Sanguo.my.UI.Operation as GDOperation == null) return;
			(Sanguo.my.UI.Operation as GDOperation).reFushui(money,Max);
			*/
		}
		/**
		 * 提取国家/地区库存到个人账户
		 */ 
		public function _cd06(buff:D5ByteArray):void
		{
		  //提取的结果
		  var result:int=buff.readByte();
		  //当前个人账户的余额
		  var money:uint=buff.readUnsignedInt();
		  if(result < 0)
		  {
			  RPGScene.my.msg(Mather._0(result));
			  return;
		  }
		  _scene.showMsg('提取成功！');
		  SanguoGlobal.userdata._gold=money;
		  RPGScene.my.UI.updateUserinfo();
		  SanguoGlobal.socket.RYcall(0xcd05,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.province);
		}

		/**
		 * 读取国家库存
		 */ 
		public function _cd07(buff:D5ByteArray):void
		{
			//4字节 库存
			var money:uint=buff.readUnsignedInt();
			//1字节 是否可以提取
			var Max:uint=buff.readByte();
			SanguoGlobal.Configer.CountryMoney=money;
//			trace("<cd07>",money,Max)
			if(WinBox.my.getWindow(HG_NeiZheng))
			{	
				var opt1:HG_NeiZheng = WinBox.my.getWindow(HG_NeiZheng) as HG_NeiZheng;
				opt1.fushui.ShowMoney();
				
			}
			 
		}
		/**
		 * 提取国家库存到个人账户
		 */ 
		public function _cd08(buff:D5ByteArray):void
		{
			//提取的结果
			var result:int=buff.readByte();
			//当前个人账户的余额
			var money:uint=buff.readUnsignedInt();
			
//			trace("<cd08>",result,money);
		
			if(result < 0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			_scene.showMsg('提取成功！');
			SanguoGlobal.userdata._gold=money;
			RPGScene.my.UI.updateUserinfo();
			SanguoGlobal.socket.RYcall(0xcd07,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.province);
		}
		/**
		 * 国战城战战报
		 */ 
		public function _cd09(buff:D5ByteArray):void
		{

//			var _type:int=buff.readByte();//0为国战

             var num:int=buff.readUnsignedInt();
//			 SanguoGlobal.cd09num=num;
			 var arr:Array=new Array();
			 var str1:String;
			 var str2:String;
			 var ar:Array;
			 var i:int,k:int;
			 var temp:Array;
			 if(SanguoGlobal.cd09flag==false){//国战

				 for(i=0;i<Math.min(1,num);i++)
				 {
					 ar=new Array();
					 
					 for(k=0;k<11;k++)
					 {
						 ar.push(buff.readInt());
					 }
					 SanguoGlobal.Configer.CountryBattleRecoderList.push(ar);
					 str1=buff.readUTFBytes(32);
					 str2=buff.readUTFBytes(1024);
					 str2=str2.replace((/#/g),"");
//					 str1="6,28,45,39";
//					 str2="柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|";
					 temp=str2.split("|");
					 ar=new Array();
					 for each(var str:String in temp){
						 if(str=="") break;
						 ar.push(str.split(","));
					 }
					 SanguoGlobal.Configer.Country_active_list.push(ar);
					 
				 }
					 trace('cd09 arr',SanguoGlobal.cd09flag,arr);
					 if(SanguoGlobal.cd09count<Math.min(3,num)){
					 SanguoGlobal.cd09count++;						 
				 	 SanguoGlobal.socket.RYcall(0xcd09,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.country,SanguoGlobal.cd09count,SanguoGlobal.cd09flag,1);
					 return;
					 } 

			 }else {//城战
				 for(i=0;i<Math.min(1,num);i++)
				 {
					 ar=new Array();
					 for(k=0;k<11;k++)
					 {
						 ar.push(buff.readInt());
					 }
						 trace(ar,i);
					 SanguoGlobal.Configer.CityBattleRecoderList.push(ar);
					 
//					 trace('cd09 arr',SanguoGlobal.cd09flag,arr,buff.length);

					 str1=buff.readUTFBytes(32);
					 
					 str2=buff.readUTFBytes(1024);
//					 str1="6,28,45,39";
//					 str2="柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|柳吉伦,3,40,112|慕容姣青,1,10,40|"; 
//					 trace("援助玩家",str1,"活跃玩家",str2);
					 str2=str2.replace((/#/g),"");
					 //援助城池====================
					 SanguoGlobal.Configer.helpCityList.push(str1.split(","));
					 //活跃玩家=====================					 
					 temp=str2.split("|");
					 ar=new Array();
					 for each(var _str:String in temp){
						 if(_str=="") break;
						 ar.push(_str.split(","));
//						 trace("活跃玩家子项",ar,ar.length);
					 }
					 SanguoGlobal.Configer.City_active_list.push(ar);
					 //=============================
				 }
				 if(SanguoGlobal.cd09count<Math.min(3,num)){
					 SanguoGlobal.cd09count++;						 
				 	 SanguoGlobal.socket.RYcall(0xcd09,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.province,SanguoGlobal.cd09count,SanguoGlobal.cd09flag,1)
					 return;
				 } 
			 }
			 var win:BattleUI=WinBox.my.getWindow(BattleUI);
					 if(win!=null){
				 win.showBattleRecordList();
			 }
//			makeEvent(0xcd09,arr);
//			trace('sssss',SanguoGlobal.Configer.CityBattleRecoderList);
//			Sanguo.my.msg('num'+num);
		}
		/**
		 * 出征
		 */
		public function _d000(buff:D5ByteArray):void
		{
			var success:int = buff.readByte();
			if(success == 0)
			{
				_scene.showMsg('配置队列失败');
				return;
			}else{
				_scene.showMsg('配置队列成功，现在可以出征了');
				MissionChecker.setKEY('_53',true);
				
				SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//				if(_scene as MyCityScene == null) return;
//				if((_scene as MyCityScene).Operation as BYOperation == null) return;
//				((_scene as MyCityScene).Operation as BYOperation)._1_();
				return;
			}
			
		}
		/**
		 * 创建集体战斗队列（国战、战役）
		 */ 
		public function _d002(buff:D5ByteArray):void
		{
			//1字节 返回结果 若大于0，则返回队列主键ID（或内存索引ID）
		   var 	result:int=buff.readByte();
		   if(result < 0)
		   {
			   RPGScene.my.msg(Mather._0(result));
			   return;
		   }
		   
		   if(result>0)
		   {
			   _scene.showMsg('申请成功！！');   
			   var win:GD_Zhengling=WinBox.my.getWindow(GD_Zhengling);
			   if(win!=null&&win.chengzhanSprite!=null){
				   win.chengzhanSprite.ATTAckButton
			   }
			   SanguoGlobal.socket.RYcall(0xd00e,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.province);  
			   return ;
		   }
			
		}
		/**
		 * 当前正在进行的城战列表
		 */ 
		public function _d003(buff:D5ByteArray):void
		{
			//2字节  队列记录数
			var record:uint=buff.readShort();
			//1字节 列表类型
			var type:uint=buff.readByte();
			SanguoGlobal.userdata._battleList=new Vector.<BattleData>;
			for(var i:uint=0;i<record;i++)
			{
				//4字节  战场ID
				 var id:uint=buff.readUnsignedInt();
				//1字节  攻击方国家ID
				 var gongjicountyID:uint=buff.readByte();
				//2字节  攻击方名城ID
				 var gongjicityID:uint=buff.readShort();
				//1字节 守方国家ID
				 var fangshoucountyID:uint=buff.readByte();
				 //2字节 守方名城ID
				 var fangshoucityID:uint=buff.readShort();
				 
				 var s_city_1:int=buff.readByte();
				 var s_city_2:int=buff.readByte();
				 var d_city_1:int=buff.readByte();
				 var d_city_2:int=buff.readByte();
				 
				 var bat:BattleData=new BattleData();
				 bat.id=id; 
				 bat.g_ctr=gongjicountyID; 
				 bat.g_city=gongjicityID;
				 bat.f_ctr=fangshoucountyID;
				 bat.f_city=fangshoucityID;
				 bat.g_help_city_1=s_city_1;
				 bat.g_help_city_2=s_city_2;
				 bat.f_help_city_1=d_city_1;
				 bat.f_help_city_2=d_city_2;
				 trace(s_city_1,s_city_2,d_city_1,d_city_2);
				SanguoGlobal.userdata.battleList.push(bat);
			}

			if(RPGScene.firstRun==-1) 
			{
				SanguoGlobal.socket.RYcall(0xc002,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				SanguoGlobal.socket.RYcall(0xce02,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				SanguoGlobal.socket.RYcall(0xcf02,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}
			if(WinBox.my.getWindow(GD_Zhengling)!=null)
			{
				
				(WinBox.my.getWindow(GD_Zhengling)as GD_Zhengling).update_battle_info();
			}

		}
		/**
		 * 已经完成的战役、国战列表
		 */ 
		public function _d004(buff:D5ByteArray):void
		{
			//2字节  队列记录数
			var record:uint=buff.readShort();
			var arr:Array=new Array();
			for(var i:uint=0;i<record;i++)
			{
				//4字节  战场ID
				var id:uint=buff.readUnsignedInt();
				//4字节  攻击方国家ID
				var countyID:uint=buff.readUnsignedInt();
				//4字节  攻击方名称ID
				var  cityID:uint=buff.readUnsignedInt();
				//4字节  胜利场数
				var shengli:uint=buff.readUnsignedInt(); 
				//4字节   战败场数
				var shibai:uint=buff.readUnsignedInt();
				
				arr.push(id);
			}
			//SanguoGlobal.userdata._battle=id;
		}
		
		/**
		 * 战役、国战战报列表
		 */ 
		public function _d005(buff:D5ByteArray):void
		{
//			国战战报存储数组
//			SanguoGlobal.Configer.reportType
			//2字节 胜利场数
			var shengli:uint=buff.readShort();
			//2字节 战败场数
			var shibai:uint=buff.readShort();
			//4字节 下一轮战斗的剩余触发时间
			var time:int=buff.readInt();
			//4字节 城防值
			var chengfang:int=buff.readInt();
			//2字节 战报个数
			var len:uint=buff.readShort();

			SanguoGlobal.ReportCZList=new Vector.<ReportData>;
			for(var i:uint=0;i<len;i++)
			{
				//4字节 攻方用户ID
				 var jinggongID:uint=buff.readUnsignedInt();
				//4字节 守方用户ID
				 var fangyuID:uint=buff.readUnsignedInt();
				//4字节 胜利方用户ID
				 var shengliID:uint=buff.readUnsignedInt();
				 //1字节  攻击方等级
				 var g_lv:uint=buff.readByte();
				 //1字节  防守方等级
				 var f_lv:uint=buff.readByte();
				 //30字节 战报地址
				 var reportAddress:String=buff.readUTFBytes(30);
				//30字节   攻方用户名
				 var jinggongName:String=buff.readUTFBytes(30);
				 //30字节  防守方用户名
				 var fangshouName:String=buff.readUTFBytes(30);
				 var report:ReportData=new ReportData();
				 report.fangyuID=fangyuID;
				 report.gongjiID=jinggongID;
				 report.shengliID=shengliID;
				 report.gongjiLv=g_lv;
				 report.fangyuLv=f_lv;
				 report.fangyuName=fangshouName;
				 report.gongjiName=jinggongName;
				 report.reportAdress=reportAddress;
				 SanguoGlobal.ReportCZList.push(report);
			 trace("reportAddress",len,reportAddress,i,"<d005>",report.fangyuID+":"+report.gongjiID+":"+fangyuID+":"+shengliID+":"+jinggongName+":"+fangshouName,":",g_lv,":",f_lv);
			}
			    var st:String=GD_Chengzhan.latestAddres;
				if(len==0||SanguoGlobal.ReportCZList[0].reportAdress==GD_Chengzhan.latestAddres)
				{
					SanguoGlobal.Configer.reportType=1;
				}
				else
				{
					SanguoGlobal.Configer.reportType=0;
				}
				trace("<d005>",shengli,shibai,time,chengfang,SanguoGlobal.Configer.reportType,GD_Chengzhan.latestAddres)

			if(RPGScene.my.UI.Operation as BottomOperation != null)
			{
				(RPGScene.my.UI.Operation as BottomOperation).report(time,chengfang);
				return;
			}
		
		}
		
		/**
		 * 战报详细信息    协议取消
		 */ 
		public function _d006(buff:D5ByteArray):void
		{
			var reportnum:uint = buff.readUnsignedInt();
			
			if(_scene as MyCityScene!=null && (_scene as MyCityScene).Operation as IWarReport!=null)
			{
				((_scene as MyCityScene).Operation as IWarReport).getTotal(reportnum); 
			}
			
			makeEvent(0xd006,reportnum);
		}
		
		/**
		 * 玩家对玩家的战斗触发
		 */
		public function _d007(buff:D5ByteArray):void
		{
			var _result:int = buff.readByte();
			if(_result<0)
			{
				if(_result==-20)
				{
					RPGScene.my.msg('目标正在保护期内');
				}else{
					RPGScene.my.msg(Mather._0(_result));
				}
				
				return;
			}
			//30字节 
			var result:String = buff.readUTFBytes(30);
			//_scene.showMsg(result);
			
			//4字节战斗结果 
//			var result:uint = buff.readUnsignedInt();
//			if(result > 0) _scene.showMsg('发起战斗成功,战斗ID为 ' + result);
//			else if(result == 0) _scene.showMsg('发起战斗失败');
//			else if(result < 0) _scene.showMsg('内部错误');
			
			CDCenter.my.callupdate();
			
			_scene.sanguo.changeScene(RPGScene.SCENE_FIGHT,[Mather._6(result),null,1,1]);
			
			//刷新用户信息
//			SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		/**
		 * 玩家战报列表
		 */ 
		public function _d008(buff:D5ByteArray):void
		{
		  	//2字节 队列记录个数
			var record:uint=buff.readShort();
			
			var list:Vector.<WarReport> = new Vector.<WarReport>;
			for(var i:uint=0;i<record;i++)
			{
				var data:WarReport = new WarReport();
				data._gid = buff.readUnsignedInt();
				data._fid = buff.readUnsignedInt();
				data._gname = buff.readUTFBytes(30);
				data._fname = buff.readUTFBytes(30);
				data._gnum = buff.readUnsignedInt();
				data._fnum = buff.readUnsignedInt();
				data._date = buff.readUnsignedInt();
//				trace("xxxxxxx==",new Date(data.date*1000).getDate());
				data._winer = buff.readUnsignedInt();
				data._url = buff.readUTFBytes(30);
				list.push(data);
				//trace(data.gname+'攻方',data.fname+'守方')
			}
			
			makeEvent(0xd008,list);
			return;
			
			if(_scene as MyCityScene!=null && (_scene as MyCityScene).Operation as IWarReport!=null)
			{
				((_scene as MyCityScene).Operation as IWarReport).showReport(list);
			}
			
			if(RPGScene.my.UI.operation!=null && (RPGScene.my.UI.operation).win2 as IWarReport!=null)
			{
				((RPGScene.my.UI.operation).win2 as IWarReport).showReport(list);
			}
		}
		/**
		 * 城战的对战详情
		 */ 
		public function _d009(buff:D5ByteArray):void
		{
			//2字节 我的战场排序，若未参加且可参战，返回0，若未参加，且不可参展，返回-1
			var sort:int=buff.readShort();
			//4字节 开始时间
			var timeS:int=buff.readInt();
			//4字节 结束时间
			var timeE:int=buff.readInt();
			//2字节 长度
			var len:uint=buff.readShort();
			/**
			 * 进攻方
			 */ 
			var jingong:Array=new Array();
			/**
			 * 防守方
			 */ 
			var fangshou:Array=new Array();
			
			for(var i:uint=0;i<len;i++)
			{
			//1字节 标志位 0攻击方 1 防御方
			 var sign:uint=buff.readByte();
			//30字节 玩家名
			 var name:String=buff.readUTFBytes(30);
			//2字节 玩家等级
			 var lv:uint=buff.readShort();
			//4字节 玩家ID
			 var id:uint=buff.readUnsignedInt();
			 var obj:Object=new Object();
			 obj.name=name;
			 obj.lv=lv;
			 obj.id=id;
			 trace("玩家",obj.name,obj.lv,sign);
			 if(sign==0)
			 {
			 	jingong.push(obj);
				
			 }else if(sign==1)
			 {
				fangshou.push(obj);
			 }
			}
			if(GD_Chengzhan.selectedBattle!=null)
			{
			GD_Chengzhan.selectedBattle.timeS=timeS;
			GD_Chengzhan.selectedBattle.timeE=timeE;
			}
			trace("<d009>",sort,"@",timeS,"@",timeE,"@");
			
			SanguoGlobal.Configer.battleTime[2][0]=timeS;
			SanguoGlobal.Configer.battleTime[2][1]=timeE;
			RPGScene.my.UI.resetTime(SanguoGlobal.Configer.battleTime); 
			if(WinBox.my.getWindow( GD_Chengzhan)!=null)
			{
				(WinBox.my.getWindow(GD_Chengzhan)as GD_Chengzhan).list(jingong,fangshou,sort,timeS,timeE);
			}
//			if(Sanguo.my.UI.Operation as BottomOperation == null) return;
//			(Sanguo.my.UI.Operation as BottomOperation).list(jingong,fangshou,sort,timeS,timeE);
			
		}
		public function _dccc(buff:D5ByteArray):void
		{
			var res:int=buff.readByte();
//			trace('邀请||',res);
			if(res==1){
				ShowChengzhan.index++;
				if(ShowChengzhan.index>=SanguoGlobal.Configer.needHelpBattleList.length) 
				{
					ShowChengzhan.index=0;
					RPGScene.my.msg('邀请成功');//刷新城战数据
					SanguoGlobal.socket.RYcall(0xd003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.userdata.country,SanguoGlobal.userdata.province,0);
					return;
				}
				SanguoGlobal.socket.RYcall(0xdccc,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.needHelpBattleList[ShowChengzhan.index].g_city,ShowChengzhan.clickAttakId);
			}else if(res<0){
				RPGScene.my.msg(Mather._0(res));
			}
	         
		}
		/**
		 * 战役战斗CD清除
		 */ 
		public function _d010(buff:D5ByteArray):void
		{
			var result:int=buff.readByte();
			if(result < 0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			//4字节  减少的冷却时间
		
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 2;
			RPGScene.my.UI.updateUserinfo();
			CDCenter.my._cdList[22] = 0;
			if(GD_Chengzhan.selectedBattle!=null)
			{
				SanguoGlobal.socket.RYcall(0xd009,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,GD_Chengzhan.selectedBattle.id,0);
				SanguoGlobal.socket.RYcall(0xd005,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,GD_Chengzhan.selectedBattle.id);
			}
			if(_scene) _scene.showMsg("操作成功，可继续战斗！！");
		
			
			if(RPGScene.my.UI.Operation as BottomOperation == null) return;
			(RPGScene.my.UI.Operation as BottomOperation).report(0,SanguoGlobal.Configer.battleChengfang);
		}
		
		/**
		 * 国战、战役参战
		 */ 
		public function _d00a(buff:D5ByteArray):void
		{
			//1字节 参展结果1成功 0失败
			var result:int=buff.readByte();
			if(result==1)
			{
				_scene.showMsg('参战成功');
				SanguoGlobal.socket.RYcall(0xd009,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,GD_Chengzhan.selectedBattle.id,0);
			}else{
				_scene.showMsg('参战失败');
				RPGScene.my.closeWait();
			}
			
		}
		
		/**
		 * 战役审核列表
		 */ 
		public function _d00c(buff:D5ByteArray):void
		{
			
			if(SanguoGlobal.ExamineList!=null) SanguoGlobal.ExamineList.splice(0,SanguoGlobal.ExamineList.length);
			
			//1字节返回结果
			var result:int=buff.readByte();
			
			SanguoGlobal.ExamineList=new Vector.<ExamineData>;
			if(result>0)
			{
			
			  //1字节 剩余审核额度
				var remain:int=buff.readByte();
			  //2字节 待审核的战役列表记录数
				var record:uint=buff.readShort();
				
			    SanguoGlobal.userdata._remain=remain;
				for(var i:uint=0;i<record;i++)
				{
					//2字节 名城ID
					var county:uint=buff.readShort();
					//30字节  太守名称
					var owner:String=buff.readUTFBytes(30);
					//2字节  目标城池ID
					var county2:uint=buff.readShort();
					//30字节  目标城池太守名称
					var owner2:String=buff.readUTFBytes(30);
					//4字节 我方玩家数量
					var people:uint=buff.readUnsignedInt();
					//4字节 对象玩家数量
					var people2:uint=buff.readUnsignedInt();
					//120字节 请战宣言
					var content:String=buff.readUTFBytes(120);
					
					var data:ExamineData=new ExamineData();
					data.countyid=county;
					data.countyid2=county2;
					data.owner=owner;
					data.owner2=owner2;
					data.people=people;
					data.people2=people2;
					data.content=content;
					SanguoGlobal.ExamineList.push(data);
					trace("<d00c>",remain,data);
					
				}
//					if(_scene as MyCityScene == null) return;
//					if((_scene as MyCityScene).Operation as HGOperation == null) return;
//					
//					((_scene as MyCityScene).Operation as HGOperation).back(record);
				if(WinBox.my.getWindow(HG_Guozhan)!=null)
				{
					(WinBox.my.getWindow(HG_Guozhan)as HG_Guozhan).show_pl();
					trace(SanguoGlobal.ExamineList.length);
				}
					
			 }
			else
			{
					
				_scene.showMsg("你没有这个权限!");	
			}
				
		
		}
		/**
		 * 审批战役
		 */ 
		public function _d00d(buff:D5ByteArray):void
		{
			//1字节 返回结果  1成功  0失败    -3发起的城池不存在   -4源城池已存在一个战役 -5目标城池已存在一个战役   
			var result:int=buff.readByte();
			if(result==1)
			{
				_scene.showMsg('操作成功');
				SanguoGlobal.socket.RYcall(0xd00c,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				return;
			}else{
				if(result==-3)
				{
					  trace("发起的城池不存在!");
					  return;
				}else if(result==-4)
				{
					_scene.showMsg('该城池已创建一战役!');
					  return;
				}else if(result==-5)
				{
					_scene.showMsg('目标城池已被攻击!');	
				}
			}
			
		}
		
		
		/**
		 * 当前城池的战役读取
		 */ 
		
		public function _d00e(buff:D5ByteArray):void
		{
			
			var arr:Array=new Array();
			var status:uint;
			var contuny_id:uint;
			var cityID:uint;
			var num:uint;
			var name:String;
			var huifu:String;
			status=buff.readByte();
			if(status!=0)
			{
				cityID=buff.readUnsignedInt();
				name=buff.readUTFBytes(30);
				contuny_id=buff.readUnsignedInt();
				num=buff.readUnsignedInt();
				huifu=buff.readUTFBytes(120);
			}
//			var s_city_0:int=buff.readByte();
//			var s_city_1:int=buff.readByte();
//			var d_city_0:int=buff.readByte();
//			var d_city_1:int=buff.readByte();
//			var s_arr:Array=[s_city_0,s_city_1];
//			var d_arr:Array=[d_city_0,d_city_1];
//			trace("s_city|",s_arr,"d_city|",s_arr);
//			s_arr=[18,12];
//			d_arr=[32,29];
			//4字节 攻击目标
			
//			if(_scene as MyCityScene == null) return;
//			if((_scene as MyCityScene).Operation as GDOperation == null) return;
//			((_scene as MyCityScene).Operation as GDOperation).back(status,d_city_id,name);
			if(WinBox.my.getWindow(GD_Zhengling)!=null)
			{
				
				(WinBox.my.getWindow(GD_Zhengling)as GD_Zhengling).chengzhanBack(contuny_id,cityID,status)
			}
			
		}
		/**
		 * 撤销当前战役申请
		 */ 
		public function _d00f(buff:D5ByteArray):void
		{
			
			//1字节 返回结果   0为撤销失败  1为撤销成功
			
			var result:int=buff.readByte();
			if(result==0)
			{
			     _scene.showMsg('撤销失败');	
				 return;
			}else if(result==1)
			{
				_scene.showMsg('撤销成功');
//				if(_scene as MyCityScene == null) return;
//				if((_scene as MyCityScene).Operation as GDOperation == null) return;
//				((_scene as MyCityScene).Operation as GDOperation).back(0,0,"");
				if(RPGScene.my.UI.operation.win2 is GD_Zhengling)
				{
					var opt:GD_Zhengling = RPGScene.my.UI.operation.win2 as GD_Zhengling;
					opt.reback(0,0,"");
				}
				return;
			}
		}
		/**
		 * 加入/更新竞技榜参战队伍
		 */ 
		public function _d020(buff:D5ByteArray):void
		{
			//1字节 设置成功
			var result:int=buff.readByte();
			if(result==1)
			{
				_scene.notice('设定成功！');

				makeEvent(0xd020);
//				if(JJ_all.waitAutoSetGen>0)
//				{
//					SanguoGlobal.socket.RYcall(0xd023,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,JJ_all.waitAutoSetGen);
//					JJ_all.waitAutoSetGen = 0;
//					return;
//				}
//				}else {
//					SanguoGlobal.socket.RYcall(0x9000,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//				}
				return;
			}else
			{
				_scene.showMsg('设定失败！');
				return;
			}
		} 
		


		/**
		 * 读取自己在竞技榜的相关信息
		 * 服务器逻辑：根据用户ID，获取用户指定的出战武将列表。并返回用户当前在竞技榜中的排名名次
		 */ 
		public function  _d021(buff:D5ByteArray):void
		{
			var data:MyJJinfo = new MyJJinfo();
			data._myOrder=buff.readUnsignedInt();

			if(data.myOrder!=0)
			{
				//2字节  当日已进行了多少场比赛
				data._gameTimes=buff.readUnsignedShort();
				//if(data.gameTimes>=15) data._gameTimes=15;
				//4字节  冷却时间  
				data._cd=buff.readInt();
				if(data.cd<0) data._cd=0;
				//4字节  武将ID（第一出场）
				data._gen1=buff.readUnsignedInt();
				//4字节  武将ID（第二出场）
				data._gen2=buff.readUnsignedInt();
				//4字节 武将ID（第三出场）
				data._gen3=buff.readUnsignedInt();
			}
			SanguoGlobal.userdata._jjc=data;
			
			CDCenter.my.update(CDCenter.JINGJI,data.cd);
			
			if(RPGScene.firstRun==-1) 
			{
				Debug.trace('MyCityScene',_scene as MyCityScene);
				updateCity();
			}
			RPGScene.my.UI.tl();
			
			makeEvent(0xd021,data);
			
			return;
			if(RPGScene.my.UI.Operation as BottomOperation == null) return;
			(RPGScene.my.UI.Operation as BottomOperation).updata(data);
			
		}
		/**
		 * 竞技榜可挑战玩家列表
		 */
		public function _d022(buff:D5ByteArray):void
		{
			//1字节  当前记录总数
			var record:uint= buff.readByte();
			var list:Vector.<JingjiData> = new Vector.<JingjiData>;
			for(var i:uint=0;i<record;i++)
			{
				var jingji:JingjiData=new JingjiData();
				jingji.uid = buff.readUnsignedInt();
				jingji.rank = buff.readUnsignedInt();
				jingji.lv = buff.readShort();
				jingji.name = buff.readUTFBytes(30);
				jingji.country = buff.readByte();
				list.push(jingji);
				trace('0xd022',jingji.country,jingji.name,jingji.shengli,jingji.total);
			}	
			
			list = list.reverse();
			
			makeEvent(0xd022,list);
			return;
			if(RPGScene.my.UI.Operation as BottomOperation== null) return;
			if(list.length>0) (RPGScene.my.UI.Operation as BottomOperation).TZ(list);
			
		}
		/**
		 * 竞技场选择对手挑战
		 */ 
		public function _d023(buff:D5ByteArray):void
		{
			//1字节  返回标志
			var  sign:int=buff.readByte();
			switch(sign)
			{
				case 0:
					_scene.showMsg("对手不在列表");
					break;
				case 1:
					//30字节  战报地址
					var reportAddress:String=buff.readUTFBytes(30);	
					//1字节 奖励的数量
					var count:uint = buff.readByte();
					
					var give:Array = new Array();
					for(var i:uint=0;i<count;i++)
					{
						var type:uint = buff.readUnsignedShort();
						var id:int = buff.readUnsignedInt();
						var num:uint = buff.readUnsignedShort();
						give.push([type,id,num])
					}
					MyCityScene.AUTO_OPEN=BuildingID.JingJi;
					
					makeEvent(0xd023);
					
					RPGScene.my.UI.setStatictime(1,600);
					
					_scene.sanguo.changeScene(RPGScene.SCENE_FIGHT,[Mather._6(reportAddress),give]);
					
					SanguoGlobal.socket.RYcall(0xd021,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					
					if(give.length) SanguoGlobal.userdata.updatapackage();
					
					MissionChecker.setKEY('_55',true);
					break;
				case -3:
					_scene.showMsg("次数不够！");
					break;
				case -4:
					_scene.showMsg("战斗冷却时间还没到！");
					break;
				default:break;
				
			}
		
		}
		/**
		 * 竞技场排名
		 * 服务器逻辑：获取当前竞技场的排名情况。若存在搜索关键字，根据关键字进行查询
		 */ 
		public function _d024(buff:D5ByteArray):void
		{
			//4字节 我的排名
			var myrank:uint=buff.readUnsignedInt();
			//1字节  当前记录总数
			var record:uint=buff.readUnsignedInt();
			
			var count:uint = int(buff.bytesAvailable/50);
			
			var list:Vector.<JingjiData> = new Vector.<JingjiData>;
			for(var i:uint=0;i<count;i++)
			{
		
				var jingji:JingjiData=new JingjiData();
				
					
				//4字节  排名
				jingji.rank=buff.readUnsignedInt();	
				//2字节  玩家主将等级
				jingji.lv=buff.readShort();
				//30字节 玩家昵称
				jingji.name=buff.readUTFBytes(30);
				//1字节  玩家所属国家
				jingji.country=buff.readByte();
				//1字节  玩家武将数
				jingji.gen_num=buff.readByte();
				//4字节  玩家威望
				jingji.weiwang=buff.readUnsignedInt();
				//4字节  胜利场数
				jingji.shengli =buff.readUnsignedInt();
				//4字节  总场数
				jingji.total=buff.readUnsignedInt();
				
				list.push(jingji);
				trace('_d024',jingji.name,jingji.shengli,jingji.total);
				
			}	
				
				makeEvent(0xd024,[list,record]);
				return;
				if(RPGScene.my.UI.Operation as BottomOperation == null) return;
				(RPGScene.my.UI.Operation as BottomOperation).PM(list,record);
			
		}
		/**
		 * 加入太守/皇帝争夺战
		 */ 
		public function _d040(buff:D5ByteArray):void
		{
			//1字节  1字节 结果 1成功 0条件不足 -1权限不足
			var result:int=buff.readByte();

			//4字节  返回数量
			var num:uint=buff.readUnsignedInt();
			if(result==-3)
			{
				_scene.showMsg("已报名");
				return;
			}else if(result==-1){
				_scene.showMsg("已开打");		
				return;
			}else if(result==1){
				_scene.showMsg("参赛成功"); 
				
				makeEvent(0xd040,num);
				return;
				if(_scene as MyCityScene == null) return;
				if((_scene as MyCityScene).Operation as GDOperation == null) return;
				((_scene as MyCityScene).Operation as GDOperation).check(1);
				return;
			}
			
		}
		
		/**
		 * 当前比赛的状态
		 */ 
		public function _d041(buff:D5ByteArray):void 
		{
			

			var report:Array=new Array(); //战报
			var listArr:Array=new Array();
			
			var num:uint=buff.readByte();
			var reportnum:uint=buff.readByte();
				for (var i:uint=0;i<num;i++)
				{
					var userid:uint=buff.readUnsignedInt();
					var genid:uint=buff.readUnsignedInt();
					var genlv:uint=buff.readInt();
					var name:String=buff.readUTFBytes(30);
					var zhengba:ZhengbaData=new ZhengbaData();
					zhengba.userid=userid;
					zhengba.userhead=genid;
					zhengba.username=name; 
					zhengba.lv=genlv;
					trace("taishou======",userid,genid,genlv,name);
					if(SanguoGlobal.ZhengbaList==null) SanguoGlobal.ZhengbaList=new Vector.<ZhengbaData>;
					SanguoGlobal.ZhengbaList.push(zhengba);
					
				}
				// 16 当前太守  17上任太守
			   for (var j:uint=0;j<17;j++)	
			   {
				   var id:uint=buff.readUnsignedInt();
				    //if(j==17)  buff.readInt();
				   listArr.push(id);
			   }
			   
			   for (var m:uint=0;m<reportnum;m++)
			   {
				   var reportAdd:String=buff.readUTFBytes(32);
				   
				   report.push(reportAdd);
			   }
			   trace(listArr);
			   makeEvent(0xd041,[listArr,report]);
			   return;
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as GDOperation == null) return;
			((_scene as MyCityScene).Operation as GDOperation).add(listArr,report);	
			
			
			
		}
		/**
		 * 比赛信息获取
		 */ 
		public function _d042(buff:D5ByteArray):void
		{
			//1字节  是否已报名参赛  0为未报名 1为已报名
			 var sign:uint=buff.readByte();
			 //4字节  已报名参赛的人数
			 var num:uint=buff.readUnsignedInt();
			//4字节 字符串8强赛剩余时间
			 var time8:uint=buff.readUnsignedInt();
			
			//4字节 4强赛剩余时间
			 var time4:uint=buff.readUnsignedInt();
			//4字节 半决赛剩余时间
			 var time2:uint=buff.readUnsignedInt();
			//4字节 决赛剩余时间
			 var time1:uint=buff.readUnsignedInt();
			 //4字节  太守争霸  剩余时间
			 var time0:uint=buff.readUnsignedInt();
			//4字节 当前太守用户ID
			 var userid:uint=buff.readUnsignedInt();
			//4字节 当前太守LVONE ID
			 var genid:uint=buff.readUnsignedInt();
			//30字节 当前太守名
			 var name:String=buff.readUTFBytes(30);
			 var timeArr:Array=new Array();
			timeArr.push(time8);
			timeArr.push(time4);
			timeArr.push(time2);  
			timeArr.push(time1);
			timeArr.push(time0);
			
			if(SanguoGlobal.Configer.battleType==0)
			{
				SanguoGlobal.Configer.battleTime[0][0]=time8;
				SanguoGlobal.Configer.battleTime[0][1]=time0;
				RPGScene.my.UI.resetTime(SanguoGlobal.Configer.battleTime);
				if(SanguoGlobal.Configer.isLoop==1)
				{	
				SanguoGlobal.Configer.battleType=1;
				SanguoGlobal.socket.RYcall(0Xd042,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,1);
				SanguoGlobal.Configer.isLoop=0;
				}
			}
			else if(SanguoGlobal.Configer.battleType==1)
			{
				SanguoGlobal.Configer.battleTime[1][0]=time8;
				SanguoGlobal.Configer.battleTime[1][1]=time0;
				RPGScene.my.UI.resetTime(SanguoGlobal.Configer.battleTime);
			}
			
			
			makeEvent(0xd042,[timeArr,sign,num]);
			return;
			//var temp:Array=new Array(60,120,180,240);
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as GDOperation == null) return;
			
			((_scene as MyCityScene).Operation as GDOperation).timelist(timeArr,sign);
			((_scene as MyCityScene).Operation as GDOperation).addrenshu(num);
			
			
		}
		private var _reportAdd:String;
		/**
		 * 拉进战场
		 * 服务器逻辑：当比赛过程产生新一轮战报的时候。会给参加战斗的全部角色主动发送本数据包。通知该角色进入战斗场景发送战报
		 */ 
		public function  _d043(buff:D5ByteArray):void
		{
			// 1字节    战场类型      1 竞技场 2城战 3国战  4太守争霸  5皇帝 6武将副本 7部队副本 8比赛
			var type:uint=buff.readByte();
         
			//32字节  战报地址
			var reportAdd:String=buff.readUTFBytes(32);
			_reportAdd=reportAdd;
			
			//if(cwin!=null && this.contains(cwin)) this.removeChild(cwin);
			RPGScene.my.closeShowMsg();
			var arr:Array=new Array();
			arr=[['进入',onEnter],['取消',onCan]];
			switch(type)
			{
				case 1:
					RPGScene.my.ShowMsg2("竞技场已开始，是否进入？",arr,'战斗进入提示'); 
					RPGScene.my.showMsgData = 1;
					break;
				case 2:
					RPGScene.my.ShowMsg2("战役已开始，是否进入？",arr,'战斗进入提示');
					RPGScene.my.showMsgData = 2;
					break;
				case 3:
					RPGScene.my.ShowMsg2("国战已开始，是否进入？",arr,'战斗进入提示');
					RPGScene.my.showMsgData = 3;
					break;
				case 4:
					RPGScene.my.ShowMsg2("太守争霸赛已开始，是否进入？",arr,'战斗进入提示');	
					RPGScene.my.showMsgData = 4;
					break;
				case 5:
					RPGScene.my.ShowMsg2("皇帝争霸赛已开始，是否进入？",arr,'战斗进入提示');
					RPGScene.my.showMsgData = 5;
					break;
				case 6:
					RPGScene.my.ShowMsg2("武将副本已开始，是否进入？",arr,'战斗进入提示');
					RPGScene.my.showMsgData = 6;
					break;
				case 7:
					RPGScene.my.ShowMsg2("部队副本已开始，是否进入？",arr,'战斗进入提示');
					RPGScene.my.showMsgData = 7;
					break;
				case 8:
					RPGScene.my.ShowMsg2("比赛已开始，是否进入？",arr,'战斗进入提示');
					RPGScene.my.showMsgData = 8;
					break;
				default:
					RPGScene.my.showMsgData = 0;
					break;
					
			}
		}
		
	
		
		/**
		 * 进入
		 */
		private function onEnter(u:uint):void
		{
			
				RPGScene.my.closemsg();
				RPGScene.my.closeShowMsg();
				_scene.sanguo.changeScene(RPGScene.SCENE_FIGHT,[Mather._6(_reportAdd)]);
			
		}
		/**
		 * 取消
		 */ 
		private function onCan(u:uint):void
		{
			RPGScene.my.closeShowMsg();
		}
		
		/**
		 * 当前角色的副本进度
		 */ 
		public function _d050(buff:D5ByteArray):void
		{
			var id:uint = buff.readUnsignedInt();
			var nowpoint:uint = buff.readUnsignedInt();
			var zeronpc:uint = buff.readUnsignedInt();
			
			SanguoGlobal.userdata._dungeonID = id;
			SanguoGlobal.userdata._dungeonNode = nowpoint;
			SanguoGlobal.userdata._dungeonZero = zeronpc;
			
			RPGScene.my.closeWait();
			trace("==========Fuben===========",id,nowpoint,zeronpc);
			if(RPGScene.firstRun==-1)
			{
				SanguoGlobal.socket.RYcall(0xc002,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}else{
				if(_scene as DungeonScene!=null)
				{
//					if(FB_all.lastFB) FB_all.lastFB.step++;
//					FB_all.setFuBen();
					NPCDailog.my.onComplate();

					(_scene as DungeonScene).update(id,nowpoint-zeronpc+1,zeronpc);
					//if(FB_all.lastFB) 
					//{
					//	FB_all.lastFB.step++;
					//	trace(FB_all.lastFB.step);
					//}
					//trace("=========Fuben 222========");
					//FB_all.setFuBen();
					//NPCDailog.my.onComplate();

//					(_scene as DungeonScene).unlock(SanguoGlobal.userdata.dungeonNode);
//					Sanguo.my.changeScene(Sanguo.SCENE_DUNGEON,[SanguoGlobal.userdata.dungeonID,SanguoGlobal.userdata.dungeonNode,SanguoGlobal.userdata.dungeonZero]);
					
				}
				
				return;
				//if(_scene as MyCityScene == null) return;
				if(_scene as MyCityScene!=null)
				{
					var op:BottomOperation = RPGScene.my.UI.Operation as BottomOperation;
					
					if(op==null) return;
					op.setFuBen();
				}
			}
		}
		/**
		 * 副本战斗
		 */ 
		public function _d052(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			if(result<0)
			{
				RPGScene.my.msg("条件不足，无法进入该据点！");
				FightScene.nodeData=null;
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			var script:String = buff.readUTFBytes(32);
//			trace("d052",script);
			var count:int = buff.readByte();
			var give:Array = new Array();
			var isrefresh:Boolean;
			
			if(result==1)
			{
				for(var i:uint=0;i<count;i++)
				{
					var type:uint = buff.readUnsignedShort();
					var id:int = buff.readUnsignedInt();
					var num:uint = buff.readUnsignedShort();
					
					give.push([type,id,num]);
					switch(type)
					{
						case 0:
//							SanguoGlobal.userdata.addid(id,num);
							isrefresh = true;
							break;
						case 1:
							SanguoGlobal.userdata._exp=SanguoGlobal.userdata.exp+num;
							break;
						case 2:
							SanguoGlobal.userdata._fightPoint=SanguoGlobal.userdata.fightPoint+num;
							break;
					    case 4:
							SanguoGlobal.userdata._food=SanguoGlobal.userdata.food+num;
							break;
						case 5:
							SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold+num;
							break;
					}
				}
				
//				if(isrefresh)
//				{
//					if(SanguoGlobal.userdata.packageUnown>=SanguoGlobal.userdata.packageUnlock)
//					{
//						Sanguo.my.msg('背包已满,请注意查收邮件!');
//					}else{
//						SanguoGlobal.userdata.updatapackage();
//					}
//				}
			}
			
//			Sanguo.my.UI.updateUserinfo();
//			Sanguo.my.UI.updateCityinfo();
			
			CDCenter.my.callupdate();
			
			_scene.sanguo.changeScene(RPGScene.SCENE_FIGHT,[Mather._6(script),give]);
//			Sanguo.my.UI.changeTest(52,'|'+Sanguo.my.flashvars.serverid.toString()+'|'+script+'|'+Mather._6(script));
//			Sanguo.my.msg('|'+Sanguo.my.flashvars.serverid.toString()+'|'+script+'|'+Mather._6(script));
			//刷新用户信息
//			SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
			//副本战斗结束刷新武将信息
			SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		
		/**
		 * 武将FB列表
		 */
		public function _d053(buff:D5ByteArray):void
		{
			var num:uint = buff.readUnsignedByte();
			var arr:Array = new Array();
			for(var i:uint=0;i<num;i++)
			{
				var genid:uint = buff.readUnsignedInt();
				var genname:String = buff.readUTFBytes(30);
				arr.push([genid,genname]);
			}
			trace('副本武将列表',arr);
			if(!(_scene as DungeonScene)) return;
			(_scene as DungeonScene).showaGenDungeon(arr);
			
		}
		
		/**
		 * 武将FB战报
		 */
		public function _d054(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			makeEvent(0xd054);
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			
			var script:String = buff.readUTFBytes(32);
			var count:int = buff.readByte();
			var give:Array = new Array();
			var str:String='';
			var isrefresh:Boolean;
			
			if(result==1)
			{
				for(var i:uint=0;i<count;i++)
				{
					var type:uint = buff.readUnsignedShort();
					var id:int = buff.readUnsignedInt();
					var num:uint = buff.readUnsignedShort();
					give.push([type,id,num]);
					switch(type)
					{
						case 0:
							//装备
//							SanguoGlobal.userdata.addid(id,num);
							isrefresh = true;
							break;
						case 1:
							SanguoGlobal.userdata._exp=SanguoGlobal.userdata.exp+num;
							break;
						case 2:
							SanguoGlobal.userdata._fightPoint=SanguoGlobal.userdata.fightPoint+num;
							break;
						case 4:
							SanguoGlobal.userdata._food=SanguoGlobal.userdata.food+num;
							break;
						case 5:
							SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold+num;
							break;
					}
				}
				
//				if(isrefresh)
//				{
//					if(SanguoGlobal.userdata.packageUnown>=SanguoGlobal.userdata.packageUnlock)
//					{
//						Sanguo.my.msg('背包已满,请注意查收邮件!');
//					}else{
//						SanguoGlobal.userdata.updatapackage();
//					}
//				}
			}
			
//			Sanguo.my.UI.updateUserinfo();
//			Sanguo.my.UI.updateCityinfo();
			
			CDCenter.my.callupdate();
			
			_scene.sanguo.changeScene(RPGScene.SCENE_FIGHT,[Mather._6(script),give]);
			
			if(_scene as DungeonScene) (_scene as DungeonScene).autoVisible(0);;
			
			//刷新用户信息
//			SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		
		/**
		 * 武将FB节点
		 */
		public function _d056(buff:D5ByteArray):void
		{
			//副本Id
			var dungeonid:int = buff.readByte();
			//副本武将ID
			var dungeongenid:int = buff.readUnsignedInt();
			//重置武将副本的次数
			var resetnum:int = buff.readByte();
			//免费刷新的次数
			var freeresetnum:int = buff.readByte();
			
			SanguoGlobal.userdata._wjdungeonID = dungeonid;
			SanguoGlobal.userdata._wjdungeonGenid = dungeongenid;
			SanguoGlobal.userdata._resetwjdungeon = resetnum;
			SanguoGlobal.userdata._freeresetnum = freeresetnum;
			
			makeEvent(0xd056);
		}
		
		/**
		 * 重置武将副本
		 */
		public function _d057(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			var usermb:uint = buff.readUnsignedShort();
			
			
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				
			}else if(result==0)
			{
				RPGScene.my.msg('重置失败');
				
			}else{
				
				SanguoGlobal.userdata._wjdungeonID = 0;
				SanguoGlobal.userdata._wjdungeonGenid = 0;
				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - usermb;
				SanguoGlobal.userdata._resetwjdungeon = SanguoGlobal.userdata.resetwjdungeon + 1;
				
				RPGScene.my.msg('重置成功');
				RPGScene.my.UI.updateUserinfo();
			}
			
			makeEvent(0xd057,result);
			
		}
		/**
		 * 国战 城战历史战役列表（最多三个）
		 */
		public function _d088(buff:D5ByteArray):void
		{
		  
		}
		public function _d089(buff:D5ByteArray):void
		{
			
		}
		/**
		 * 国战 列表获取
		 */ 
		public function _d090(buff:D5ByteArray):void
		{
			//1字节 战场个数 
			var num:uint=buff.readByte();
			
			if(SanguoGlobal.guoZlist==null) SanguoGlobal.guoZlist = new Vector.<GuozhanData>();
			else SanguoGlobal.guoZlist.splice(0,SanguoGlobal.guoZlist.length);
			
			//SanguoGlobal.guoZ.targetCity=0;
			for (var i:uint=0;i<num;i++)
			{
				var guoZ:GuozhanData = new GuozhanData();
				guoZ._guozhanID=buff.readUnsignedInt();
				guoZ.status=buff.readByte();
				guoZ.starttime=buff.readUnsignedInt();
				guoZ.endtime=buff.readUnsignedInt();
				guoZ.gongCountry = buff.readUnsignedByte();
				guoZ.shouCountry = buff.readUnsignedByte();
				guoZ.targetCity = buff.readUnsignedShort();
				
				if(SanguoGlobal.guoZ&&SanguoGlobal.guoZ.guozhanID==guoZ.guozhanID)
				{
					SanguoGlobal.guoZ._guozhanID = guoZ.guozhanID;
					SanguoGlobal.guoZ.status = guoZ.status;
					SanguoGlobal.guoZ.starttime = guoZ.starttime;
					trace('国战剩余时间===',SanguoGlobal.guoZ.starttime);
					SanguoGlobal.guoZ.endtime = guoZ.endtime;
					SanguoGlobal.guoZ.gongCountry = guoZ.gongCountry;
					SanguoGlobal.guoZ.shouCountry = guoZ.shouCountry;
					SanguoGlobal.guoZ.targetCity = guoZ.targetCity;
				}
				
				SanguoGlobal.guoZlist.push(guoZ);
			}
			
			if(!SanguoGlobal.guoZ) SanguoGlobal.guoZ = new GuozhanData();
			
			if(RPGScene.my.scene is MyCityScene)
			{
				var opt:BaseOperation = RPGScene.my.scene.operation;
				if(opt is HGOperation) (opt as HGOperation).updateGuozhan(num);
			}
			
			if(RPGScene.my.scene is GuozhanScence)
			{
				(RPGScene.my.scene as GuozhanScence)._updateInfo();
			}
			
			if(SanguoGlobal.guoZ!=null)
			{
				// 计算特定时间
				var date:Date = new Date();
				date.setTime(CDCenter.my.systemTime*1000);
				
				while(date.day!=3) date.setDate(date.date+1);
				date.setHours(20,0,0)
				
				var checker:int = int(date.time/1000)-CDCenter.my.systemTime;
				if(checker<0) checker=0;
				if(checker<3600)
				{
					SanguoGlobal.Configer.battleTime[3][0]=checker;
					SanguoGlobal.Configer.battleTime[3][1]=checker+3600;
				}
				
				RPGScene.my.UI.resetTime(SanguoGlobal.Configer.battleTime);
			}
			if(WinBox.my.getWindow(HG_Guozhan)!=null)
			{
				(WinBox.my.getWindow(HG_Guozhan)as HG_Guozhan).guozhantuShow(num)
			}
			//if(SanguoGlobal.guoZ!=null)  SanguoGlobal.socket.RYcall(0xd091,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.guoZ.guozhanID);
			
		}
		
		/**
		 * 新国战-战场信息获取
		 */ 
		public function _d091(buff:D5ByteArray):void
		{
			
			var gongNum:uint=0;
			var fangNum:uint=0;
			//2字节 地图编号（扩展用，直接返回1）
			var mapid:uint=buff.readShort();
			//1字节 据点个数
			var num:uint=buff.readByte();
			SanguoGlobal.guoZ.doornum = num;
		    //4字节  城防值
			SanguoGlobal.guoZ.cityvalue=buff.readUnsignedInt();
			//1字节   所在据点位置
			SanguoGlobal.guoZ.nowPoint=buff.readByte();
			//1字节 进攻方国家ID
			SanguoGlobal.guoZ.gongCountry=buff.readByte();
			//1字节 防守方国家ID
			SanguoGlobal.guoZ.shouCountry=buff.readByte();
			
			SanguoGlobal.guoZ.enterCD = buff.readInt();
			
			//trace(mapid,num,cityvalue,now,jingongC,fangshouC,SanguoGlobal.guoZ.enterCD);
			SanguoGlobal.guoZ.gNum = 0;
			SanguoGlobal.guoZ.fNum = 0;
			
			for(var i:uint=0;i<num;i++)
			{
				var data:FightStation;
				
				//1字节 索引
				var id:uint=buff.readByte();
				
				if(id>=SanguoGlobal.guoZ.fList.length)
				{
					//trace("[Decoder d091] 发现未定义的国战节点");
					continue;
				}
				//trace("[Decoder d091] 发现国战节点",id);
				data = SanguoGlobal.guoZ.fList[id];
				if(data==null)
				{
					data = new FightStation(id);
					SanguoGlobal.guoZ.fList[id] = data;
				}
				//1字节 据点归属0守方 1攻方
				data.$status=buff.readByte();
				//4字节 据点攻方人数
				data.$gnum=buff.readInt();
				//4字节 据点防守人数
				data.$fnum=buff.readInt();
				
				SanguoGlobal.guoZ.gNum+=data.gnum;
				SanguoGlobal.guoZ.fNum+=data.fnum;
				//trace("节点信息",id,data.gnum,data.fnum);

			}
			
			//trace(SanguoGlobal.guoZ.gNum,SanguoGlobal.guoZ.fNum,'FightInfo');
			var guojia:Array=new Array();
			
			if(_scene as GuozhanScence)   (_scene as GuozhanScence)._updateInfo();
		}
		/**
		 * 新国战 据点详情获取
		 */ 
		public function _d092(buff:D5ByteArray):void
		{   
			if(SanguoGlobal.guoZ==null) {
			    trace('国战数据空了！');
				SanguoGlobal.guoZ=new GuozhanData();
			}
			SanguoGlobal.guoZ.fightCD = buff.readInt();
			trace("战斗CD:",SanguoGlobal.guoZ.fightCD);
			var jingong:Array=new Array();
			var fangshou:Array=new Array();
			
			//4字节 攻击方人数
			var num1:uint=buff.readUnsignedInt();
			//Sanguo.my.UI.uiChatbox.addMsg("<font color='#e91313'>[调试]</font>收到D093数据通知，攻击人数"+num1);
			for(var i:uint=0;i<num1;i++)
			{
				var arr1:Array=new Array();
				//4字节 用户ID
				var id1:uint=buff.readUnsignedInt();
				//15字节 用户昵称
				var name1:String=buff.readUTFBytes(15);
				//2字节 用户等级
				var lv1:uint=buff.readShort();
				arr1.push(id1,name1,lv1);
				jingong.push(arr1); 
			}
			
			//4字节 防守方人数
			var num2:uint=buff.readUnsignedInt();
			//Sanguo.my.UI.uiChatbox.addMsg("<font color='#e91313'>[调试]</font>收到D093数据通知，攻击人数"+num2);
			for (var j:uint=0;j<num2;j++)
			{
				var arr2:Array=new Array();
			//4字节 用户ID
				var id2:uint=buff.readUnsignedInt();
			//15字节 用户昵称
				var name2:String=buff.readUTFBytes(15);
			//2字节 用户等级
				var lv2:uint=buff.readShort();
				arr2.push(id2,name2,lv2);
				fangshou.push(arr2);
			}
			//var guojia:Array=new Array();
			//guojia.push(Mather._1(SanguoGlobal.guoZ.gongCountry),num1,Mather._1(SanguoGlobal.guoZ.shouCountry),num2,SanguoGlobal.guoZ.cityvalue);
			
			trace("<d092>",jingong,"%%%",fangshou)
			if(_scene as GuozhanScence)   
			{
				//Sanguo.my.UI.uiChatbox.addMsg("<font color='#e91313'>[调试]</font>收到D093数据通知，开始设置在线列表"+num2);
				(_scene as GuozhanScence).setOnlineList(jingong,fangshou,num1,num2);
				//(_scene as GuozhanScence).additem2(guojia);
			}
		}
		/**
		 * 新国战 进入据点
		 */ 
		public function _d093(buff:D5ByteArray):void
		{
			//1字节 进入状态 1成功 0失败 -1权限不足
			var re:int=buff.readByte();
			
			trace("进入据点",re);
			if(re==1)
			{
				//_scene.notice("参战成功");	
				
				if(_scene as GuozhanScence)
				{
					(_scene as GuozhanScence).goEnterPoint();
				}
				
				
				//SanguoGlobal.socket.RYcall(0xd092,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.guoZ.guozhanID,1);
				
			}else{
				var result:String = '';
				switch(re)
				{
					case -6:
						result = '等级不符合条件！无法进入本战场';
						break;
					case -8:
						result = '您刚刚离开战斗，还需要'+(SanguoGlobal.guoZ.enterCD<0?120:SanguoGlobal.guoZ.enterCD)+'秒才能进入。请耐心等待！';
						break;
					case -4:
						result = '无法频繁切换据点，请稍候...';
						break;
					case -3:
						// 已在据点中，重新进入
						(_scene as GuozhanScence).goEnterPoint();
						//result = "您已经在据点中了！";
						return;
						break;
					case -100:
						result = '不能同时进入多个据点，目前正在东门激战';
						break;
					case -101:
						result = '不能同时进入多个据点，目前正在西门激战';
						break;
					case -102:
						result = '不能同时进入多个据点，目前正在南门激战';
						break;
					default:
						result = '未知原因'+re;
						break;
				}
				
				RPGScene.my.msg2(result);
				RPGScene.my.closeWait();
			}	
		}
		
		/**
		 * 新国战 攻击 
		 */ 
		public function _d094(buff:D5ByteArray):void
		{
			//1字节 攻击状态1成功 0失败 -1不在战场
			var status:int=buff.readByte();
			//32字节 战报地址（若不成功则为空）
			var reportAdd:String=buff.readUTFBytes(32);
			
			trace('D094 回包------------->'+ reportAdd ,'++++++',Mather._6(reportAdd));
			
			if(status==1 && reportAdd!='')
			{
				//FightScene.returnBack = Sanguo.SCENE_GUOZHAN;
				//_scene.sanguo.changeScene(Sanguo.SCENE_FIGHT,[Mather._6(reportAdd)]);
				if(_scene is GuozhanScence)
				{
					(_scene as GuozhanScence).fight(Mather._6(reportAdd));
				}
			}else{
				
				switch(status)
				{
					case -1:
						RPGScene.my.msg("参战失败！战斗尚未开始！");
						break;
					case -2:
						RPGScene.my.msg("战斗尚未开始，请耐心等待！");
						break;
					case -3:
						RPGScene.my.msg("没有参战");
						break;
					case -4:
						RPGScene.my.msg("目标错误");
						break;
					case -5:
						RPGScene.my.msg("目标没有参战");
						break;
					case -6:
						RPGScene.my.msg("参数错误");
						break;
					case -10:
						RPGScene.my.msg("数据错误！");
						break;
					case -33:
						RPGScene.my.msg("没有参加国战");
						break;
						break;
					case -55:
						RPGScene.my.msg("目标不在战场");
						break;
					default:
						RPGScene.my.msg("参战失败:"+status+','+reportAdd);	
						break;
				}
			}
			
			(_scene as GuozhanScence).calllock = false;
			
		} 
		/**
		 * 新国战 被攻击
		 */ 
		public function _d095(buff:D5ByteArray):void
		{
			//4字节 敌方ID
			var id:uint=buff.readUnsignedInt();
			//30字节 敌方昵称
			var name:String=buff.readUTFBytes(30);
			//32字节 战报地址
			var reportAdd:String=buff.readUTFBytes(32);
			
			if(_scene is GuozhanScence)
			{
				(_scene as GuozhanScence).fight(Mather._6(reportAdd));
			}
		}
		/**
		 * 新国战 有人进场
		 */ 
		public function _d096(buff:D5ByteArray):void
		{
			//1字节 阵营0守1攻
			var camp:int=buff.readByte();
			//4字节 用户ID
			var uid:uint=buff.readUnsignedInt();
			//15字节 用户昵称             15还是32
			var name:String=buff.readUTFBytes(15);

			
			trace("发现进场",name,uid,camp);
			
			if(uid==SanguoGlobal.userdata.uid) return;
			
			if(RPGScene.my.scene is GuozhanScence)
			{
				(RPGScene.my.scene as GuozhanScence).somebodyIn(camp,uid,name);
			}
			
		}
		/**
		 * 新国战 目前城防状况
		 */ 
		public function _d097(buff:D5ByteArray):void
		{
			//1字节 据点个数
			var num:uint=buff.readByte();
			for (var i:uint=0;i<num;i++)
			{
			//1字节 据点编号
				var id:uint=buff.readByte();
			//1字节 占用状态
				var status:uint=buff.readByte();
			}
			//4字节  城防值
			var cityvalue:uint=buff.readUnsignedInt();
			
			if(SanguoGlobal.guoZ!=null)
			{
				SanguoGlobal.guoZ.cityvalue=cityvalue;
				if(_scene is GuozhanScence) (_scene as GuozhanScence).updateInfo();
			}
			
		}
		/**
		 * 新国战 离开据点
		 */ 
		public function _d098(buff:D5ByteArray):void
		{
			var str:String;
			//字节 离开状态 0自行离开 大于0则为用户ID（被该用户打败）
			var status:uint=buff.readUnsignedInt();
			//4字节 用户ID
			var id:uint=buff.readUnsignedInt();
			
			//失败方
			var nickname:String = buff.readUTFBytes(30);
			
			//胜利方
			var atkname:String = buff.readUTFBytes(30);
			if(status==0)
			{
				str=nickname+"已离开";
			}else{
				str=nickname+"被"+atkname+"打败！";
			}
			
			
			trace("[Decoder d098] 离开据点",str,id,SanguoGlobal.userdata.uid);
			
			if(_scene as GuozhanScence)  
			{
				if(id==SanguoGlobal.userdata.uid)
				{
					SanguoGlobal.guoZ.enterCD=15;
					(_scene as GuozhanScence).leaveComplate();
				}else{
					(_scene as GuozhanScence).somebodyOut(id,status);
					//(_scene as GuozhanScence).getlist();
					RPGScene.my.msg(str)
				}
			}
		}
		/**
		 *离开国战 
		 * @param buff
		 * 
		 */
		public function _dbbb(buff:D5ByteArray):void
		{
			var relse:int=buff.readByte();
			if(relse==0)
			{
				SanguoGlobal.guoZ.enterCD=120;
			}
			else
			{
				SanguoGlobal.guoZ.enterCD=120;
				
			}
			
			for each(var data:GuozhanData in SanguoGlobal.guoZlist)
			{
				data.enterCD = 120;
			}
			
			if(_scene as GuozhanScence)  
			{
				(_scene as GuozhanScence).leaveComplate();
			}
			
		}
		/**
		 * 新国战 创建
		 */ 
		public function _d099(buff:D5ByteArray):void
		{
			var respose:int=buff.readByte(); 
			if(respose>=0)
			{
				_scene.notice("创建成功！！");
					CDCenter.my.getWarinfo(1);
				if(	WinBox.my.getWindow(HG_Guozhan)!=null)
				{
					(WinBox.my.getWindow(HG_Guozhan)as HG_Guozhan).update();
				}
//				if(_scene is MyCityScene && (_scene as MyCityScene).operation is HGOperation)
//				{
//					((_scene as MyCityScene).operation as HGOperation).updateGuozhan_create();
//				}
			}else{
				switch(respose)
				{
					case -1:
						RPGScene.my.msg('无法针对该城池发动国战。');
						break;
					case -2:
						RPGScene.my.msg('当前时间无法创建国战！');
						break;
					case -3:
						RPGScene.my.msg('不能同时同打该城池');
						break;
					case -6:
						RPGScene.my.msg('权限不够');
						break;
					case -7:
						RPGScene.my.msg('不能攻打本国城池');
						break;
					case -8:
						RPGScene.my.msg('当前时间无法创建国战！');
						break
					default:
						RPGScene.my.msg('创建失败！');
						break;
					//-5是国家id错误
				}
			}
			
		}
		/**
		 * 新国战 获取某据点最近的战报记录
		 */ 
		public function _d09a(buff:D5ByteArray):void
		{
			//1字节 实际战报个数
			var num:int=buff.readByte();
			var reportArr:Array=new Array();
			//trace("查询参战完成",num);
			for(var i:uint=0;i<num;i++)
			{
				var  str:String="";
				var arr:Array=new Array();
		    	//32字节 战报地址
				var reportAdd:String=buff.readUTFBytes(32);
				//4字节 攻方用户ID
				var gongID:uint=buff.readInt();
				//30字节 攻方用户名
				var gongName:String=buff.readUTFBytes(30);
				//4字节 守方用户ID
				var shouID:uint=buff.readInt();
				//30字节 守方用户名
				var shouName:String=buff.readUTFBytes(30);
				//4字节 胜利方ID
			 	var shengli:uint=buff.readInt();
			 	if(shengli==gongID)
			 	{
				 	str="<font color='#e303f1'>"+gongName+"</font> <font color='#ebb101'>击败</font> <font color='#ff0000'>"+shouName+"</font>";
			 	
					arr.push(reportAdd,gongID,shouID,gongName,shouName);
					
				}else{
				 	str="<font color='#e303f1'>"+shouName+"</font> <font color='#ebb101'>击败</font> <font color='#ff0000'>"+gongName+"</font>";
			 	
					arr.push(reportAdd,shouID,gongID,shouName,gongName);
				}
//				trace(reportAdd,':',gongID,':',gongName,':',shouID,':',shouName,':',shengli)
			 	//arr.push(reportAdd,str);
			 
			 	reportArr.push(arr);
			}
			
			
			if(_scene as GuozhanScence)  
			{
				(_scene as GuozhanScence).toShowReport(reportArr);
			}
		}
		/**
		 * 新国战 国战结束
		 */
		public function _d09b(buff:D5ByteArray):void
		{
			//4字节 城防值
			var cityvalue:int=buff.readUnsignedInt();
			trace("<d09b>",cityvalue);
			/*
			//2字节 奖励个数
			var jiangli:Array=new Array();
			var num:uint=buff.readShort();
			for (var i:uint=0;i<num;i++)
			{
				var arr:Array=new Array();
				//4字节 奖励编号
				var Jid:uint=buff.readUnsignedInt();
				
				//4字节 奖励数量
				var Jnum:uint=buff.readUnsignedInt();
				arr.push(Jid,Jnum);
				jiangli.push(arr);
			}
			*/
			
//			var fun:Function = function():void
//			{
//				Sanguo.my.changeScene(Sanguo.SCENE_MYCITY);
//			}
			
			var str:String = '经过浴血奋战！\n'+(cityvalue>0 ? '防守方成功保卫了城池！' : '进攻方成功攻下了城池！');
//			if(cityvalue>0){
			RPGScene.my.imgtip(6,'',2,str);
//			}
			if(RPGScene.my.scene is GuozhanScence)
			{
				(RPGScene.my.scene as GuozhanScence).onKeyup(1);
			}
//			SanguoGlobal.guoZ = null;
			SanguoGlobal.socket.RYcall(0x0007,SanguoGlobal.SERVER_USER);
			SanguoGlobal.socket.RYcall(0x6300,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
		}
		
		/**
	 	* 获取角色当前的任务记录
	 	*/ 
		public function _e000(buff:D5ByteArray):void 
		{
			var num:uint = buff.readUnsignedInt();
			if(RPGScene.firstRun==-1)
			{
				//				SanguoGlobal.socket.RYcall(0xff00,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,0,1,UserData.PACKAGETOTAL);
				SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				
			}
			if(num==0)
			{
				//Sanguo.my.msg("没有任务可做");
				FollowUI.END = true;
				return;
			}
			var data:Vector.<MissionListData> = new Vector.<MissionListData>();
			for(var i:uint = 0;i<num;i++)
			{
				var mid:int=buff.readInt();
				if(data.length>=1){
					if(data[0]<mid){
						data[0].missionid = mid;
						data[0].status = buff.readByte();
						data[0].title = buff.readUTFBytes(30);
					}
				}else {
					var mission:MissionListData=new MissionListData();
					mission.missionid=mid;
					mission.status=buff.readByte();
					mission.title=buff.readUTFBytes(30);
					data.push(mission);
				}
			}
			Debug.trace('接收到的任务||',data);
			//UI功能按钮
			if(RPGScene.firstRun!=-1){ 
				FollowUI.my.show(data[0].missionid);
			}
			if(SanguoGlobal.Configer.missonId!=data[0].missionid)
			{
				SanguoGlobal.Configer.static_47=0;
				SanguoGlobal.Configer.missonId=data[0].missionid;
			}
			SanguoGlobal.Configer.missionStates=1;
			SanguoGlobal.Configer.setupMission(data);
			//SanguoGlobal.socket.RYcall(0xe002,SanguoGlobal.SERVER_USER,1,SanguoGlobal.userdata.uid)
			if(RPGScene.my.scene.operation!=null)
			{
				RPGScene.my.scene.operation.showNpcLogo();
			}
		}
		
		public function _e001(buff:D5ByteArray):void
		{
			var PrinOut:String
			var _arr:Array=new Array();
			var result:int = buff.readByte();
			var num:int=buff.readByte();
			for(var i:int=0;i<num;i++)
			{
				var _Id:int=buff.readUnsignedInt();
				var	_itemNum:int=buff.readUnsignedInt();
				var _ob:Object={ID:_Id,itemNum:_itemNum};
				_arr.push(_ob)
			}
			if(result==1)
			{
				if(_arr!=null)
				{
					for(i=0;i<_arr.length;i++)
					{
						if(_arr[i].ID!=40)
						{
							var str:String=SanguoGlobal.Configer.taskConfig[_arr[i].ID].name;
							if(_arr[i].ID!=33)
							{
								PrinOut=str.replace("XX",_arr[i].itemNum+"");
							}
							else
							{
								var ob:Object=SanguoGlobal.Configer.itemConfig(_arr[i].ID);
								PrinOut=str.replace("XX",SanguoGlobal.Configer.itemConfig(_arr[i].itemNum).equ_prop_name+"");
								SanguoGlobal.userdata.updatapackage();
							}
							RPGScene.my.msg(PrinOut);
							switch(_arr[i].ID)
							{
								case 30:
									SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold+_arr[i].itemNum;
									break;
								case 31:
									SanguoGlobal.userdata._food=SanguoGlobal.userdata.food+_arr[i].itemNum;
									break;
								case 34:
									SanguoGlobal.userdata._exp=SanguoGlobal.userdata.exp+_arr[i].itemNum;
									break;
								case 35:
									for each (var _gen:GenData in SanguoGlobal.userdata.genList)
									{
										if(_gen.id>1000&&_gen.lv<100)
										{
											var shenji:uint=0;
											_gen.gen_exp=_gen.exp+_arr[i].itemNum;
											if(_gen.exp>=Mather._1022(_gen.lv))
											{
												_gen.gen_exp=_gen.exp-Mather._1022(_gen.lv);
												_gen.gen_lv=_gen.lv+1;
											}
										}
									}
									break;
								case 36:
									SanguoGlobal.userdata._office=SanguoGlobal.userdata.office+_arr[i].itemNum;
									
									break;
								case 37:
									SanguoGlobal.userdata._killPoint=SanguoGlobal.userdata.killPoint+_arr[i].itemNum;
									break;
								case 38:
									SanguoGlobal.userdata._action=SanguoGlobal.userdata.action+_arr[i].itemNum;
									break;
								case 39:
									SanguoGlobal.userdata._vip=SanguoGlobal.userdata.vip+_arr[i].itemNum;
									break;
							}
//							Debug.trace('e001||','奖励类型||',_arr[i].ID,'数量||',_arr[i].itemNum);
						}
							
					}
					
				}
				RPGScene.my.UI.updateCityinfo();
				RPGScene.my.UI.updateUserinfo();
				NPCDailog.complateMission();
			}else{
				RPGScene.my.msg('完成任务失败！条件不足！');
			}
		}
		
		/**
		 * 查收邮件附件
		 */
		public function _6001(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			if(result == 0) RPGScene.my.msg('领取失败');
			else if(result < -2){
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			else{
//				SanguoGlobal.socket.RYcall(0x6007,SanguoGlobal.SERVER_USER,op.EmailID);
				makeEvent(0x6001);
				RPGScene.my.msg('领取成功\n获得：'+ SanguoGlobal.Configer.sendItem.name + ' x '+ SanguoGlobal.Configer.sendItem.num);
				if(SanguoGlobal.Configer.sendItem.id == -1) SanguoGlobal.userdata._gold = SanguoGlobal.userdata.gold+SanguoGlobal.Configer.sendItem.num;
				if(SanguoGlobal.Configer.sendItem.id == -2) SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb+SanguoGlobal.Configer.sendItem.num;
				RPGScene.my.UI.updateUserinfo();
				RPGScene.my.UI.updateCityinfo();
			}
			
		}
		
		public function _e002(buff:D5ByteArray):void
		{
			var num:uint = buff.readUnsignedShort();
			var id:uint;
			var allnum:uint;
			var doneNum:uint;
			for(var i:uint = 0;i<num;i++)
			{
				id = buff.readUnsignedShort();
				allnum = buff.readUnsignedShort();
				doneNum = buff.readUnsignedShort();
				
			}
		}
		
		/**
		 * 发送新邮件
		 */
		public function _6005(buff:D5ByteArray):void
		{
			// 0 未完成  1 完成
			var result:int = buff.readByte();
//			var op:BottomOperation = Sanguo.my.UI.Operation as BottomOperation;
//			if(op==null) return;
			
			if(result == 0) RPGScene.my.msg('发送失败');
			else{
				makeEvent(0x6005);
//				SanguoGlobal.socket.RYcall(0x6006,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,op.Page,11);
				RPGScene.my.msg('发送成功');
			}
		}
		
		/**
		 * 邮件列表
		 */
		public function _6006(buff:D5ByteArray):void
		{
			//2字节邮件总条数
			var num:uint = buff.readUnsignedShort();
			//var num:uint = buff.readUnsignedInt();
			var pernum:uint = buff.readUnsignedShort();
			
			var data:Vector.<YoujianData> = new Vector.<YoujianData>;
			var max:uint=0;
			//var op:BottomOperation = Sanguo.my.UI.Operation as BottomOperation;
			
//			if(op == null) max = num;
//			else{
//				if(num<11*op.Page) max = num - 11*(op.Page-1); 
//				else max = 11;
//			}
//			var page:uint = Math.ceil(num/11);
//			
//			if(SanguoGlobal.Configer.YJpage<page) max = 11;
//			else max = num%11;
//			trace(SanguoGlobal.Configer.YJpage,num,max);
			
			for(var i:uint=0;i<pernum;i++)
			{
				var email:YoujianData = new YoujianData();
				email._time = buff.readUnsignedInt();
				email._id = buff.readUnsignedInt();
				email._read = buff.readUnsignedShort();
				Debug.trace('邮件',email.read);
				if(email.read==0&&ComcodeSceneQQ.my.youjian!=null) {
					Debug.trace('新邮件提醒',email.read,ComcodeSceneQQ.my.youjian);
				ComcodeSceneQQ.my.youjian.shrink();
				}
				email._title = buff.readUTFBytes(50);
//				trace('emialName',email.title);
				email._title = emailTitleConfig(email.title);
				email._sendname = buff.readUTFBytes(30);
				if(email.sendname == '') email._sendname = '<font color="#FF0000">系统</font>';
				data.push(email);
//				trace(email.time,'|',email.id,'|',email.read,'|',email.read,'|',email.title,'|',email.sendname);
			};
			
			RPGScene.my.UI.uiUserinfo.EMAIL = 0;
			
			for each(var v:YoujianData in data)
			{
				if(!v.read) 
				{
					RPGScene.my.UI.uiUserinfo.EMAIL = 2;
					break;
				}
			}
			
			makeEvent(0x6006,[data,num,pernum]);
			return;
		}
		
		private function emailTitleConfig(title:String=''):String
		{
			switch(title)
			{
				case 'user mission':
					return '酒馆任务';
					break;
				case 'reward':
					return '竞技场奖励';
					break;
				case 'power reward':
					return '争霸奖励';
					break;
				case 'reward props':
					return '副本掉落';
				case '':
					return '系统邮件';
					break;
				default:break;
			}
			return title;
		}
		
		/**
		 * 得到邮件内容
		 */
		public function _6007(buff:D5ByteArray):void
		{
			var data:YoujianData = new YoujianData();
			var item_:Vector.<ItemData> = new Vector.<ItemData>;
			
			data._time = buff.readUnsignedInt();
			for(var i:uint=0;i<4;i++)
			{
				var item:ItemData = new ItemData();
				item._id = buff.readInt();
				item._num = buff.readUnsignedInt();
				if(item.id>0) item._name = SanguoGlobal.Configer.itemConfig(item.id).equ_prop_name;
				else if(item.id == -2) item._name = SanguoGlobal.Configer.wordkey(100);
				else if(item.id == -1) item._name = '银币';
				else if(item.id == -3) item._name = 'VIP';
				if(i==0) data._item_1 = item;
				if(i==1) data._item_2 = item;
				if(i==2) data._item_3 = item;
				if(i==3) data._item_4 = item;
			}
			item_.push(data.item_1);
			item_.push(data.item_2);
			item_.push(data.item_3);
			item_.push(data.item_4); 
			data._item = item_;
			
			data._sendname = buff.readUTFBytes(30);
			if(data.sendname == '') data._sendname = '系统';
			data._title = buff.readUTFBytes(50);
			
			data._title = emailTitleConfig(data.title);
			
			var str:String = buff.readUTFBytes(400);
			if(data.sendname == '系统')
			{
				var dem:Array;
				var _dem:String;
				
				if(str.match(new RegExp(/[(].*?[)]/g)).length)
				{
					data._cont = '竞技场排名奖励：\n';
					dem = ['银两','粮草','威望','元宝'];
					
					for(i=0;i<4;i++)
					{
						_dem = str.match(new RegExp(/[(].*?[)]/g))[i];
						data._cont = data.cont+ dem[i] +' x '+ _dem.substring(1,_dem.length-1)+'\n';
					}
				}else if(str.split('|').length>1){
					
					dem = str.split('|');
					
					switch(int(dem[3]))
					{
						case 1:
							//攻打任务
							_dem = dem[2]+' 击败了 '+dem[4]+' 完成了你发布的攻打任务';//，并获得银两x'+dem[6];
							break;
						case 2:
							//收集任务
							_dem = dem[2]+' 完成了你发布的收集任务，你获得 '+SanguoGlobal.Configer.itemConfig(int(dem[5])).equ_prop_name+'x'+dem[6];
							
							SanguoGlobal.userdata.updatapackage();
							break;
						case 3:
							//寄售任务
							_dem = dem[2]+' 购买了你出售的 '+SanguoGlobal.Configer.itemConfig(int(dem[5])).equ_prop_name+'x'+dem[6];
							break;
						default:break;
					}
					data._cont = _dem;
					
				}else if(data.title=='系统奖励'){
					data._cont = '系统奖励：\n'+SanguoGlobal.Configer.wordkey(100)+' x '+str.match(new RegExp(/[\[].*?[\]]/g))[0];
				}else data._cont = str;
				
			}else data._cont = str;
			if(data.title=="争霸奖励"){
			data._cont=data.cont.replace(/gold =/g,"元宝x")
			data._cont=data.cont.replace(/[\[\]]/g,"");
			}
			makeEvent(0x6007,data);
			return;
			var op:BottomOperation = RPGScene.my.UI.Operation as BottomOperation;
			if(op==null) return;
			op.reRead(data);
		}
		
		/**
		 * 删除邮件
		 */
		public function _600a(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
//			var op:BottomOperation = Sanguo.my.UI.Operation as BottomOperation;
//			if(op==null) return;
			
			if(result == 0)
			{
				RPGScene.my.msg('删除失败');
			}else{
				makeEvent(0x600a);
//				SanguoGlobal.socket.RYcall(0x6006,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,op.Page,11);
				RPGScene.my.msg('删除成功');
			}
		}
		
		/**
		 * 合成喜好品
		 */
		public function _600c(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			var total:uint = buff.readShort();
			var money:uint = buff.readUnsignedInt();
			
			for(var i:uint=0;i<total;i++)
			{
				var uid:uint = buff.readUnsignedInt();
				var count:uint = buff.readUnsignedInt();
			}
			
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as JGOperation == null) return;
			((_scene as MyCityScene).Operation as JGOperation).rechange(total,money);
			
		}
		
		/**
		 * 喜好品全部同品质数量
		 */
		public function _600d(buff:D5ByteArray):void
		{
			var total:uint = buff.readUnsignedInt();
			
			if(_scene as MyCityScene == null) return;
			if((_scene as MyCityScene).Operation as JGOperation == null) return;
			((_scene as MyCityScene).Operation as JGOperation).regoldtext(total);
		}
		
		/**
		 * 元宝迁城
		 */
		public function _6021(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				if(result==-3)
				{
					RPGScene.my.msg('太守/皇帝无法迁城');
				}else if(result==-4){
					RPGScene.my.msg('已报名参加大型会战，暂时无法迁城');
				}else{
					RPGScene.my.msg(Mather._0(result));
				}
				return;
			}
			var num:uint = buff.readUnsignedInt();
			
			SanguoGlobal.userdata._province = SanguoGlobal.Configer.moveTocity;
			SanguoGlobal.userdata._citypos = num;
			RPGScene.my.msg('成功迁入 '+ Mather._7(SanguoGlobal.Configer.moveTocity));
			SanguoGlobal.userdata._province = SanguoGlobal.Configer.moveTocity;
//			SanguoGlobal.Configer.myProvince.lable = Mather._7(SanguoGlobal.Configer.moveTocity);
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 50;
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();//更新太守皇帝名
			RPGScene.my.changeScene(RPGScene.SCENE_WORLD);
		}
		
		/**
		 * 道具迁城
		 */
		public function _6012(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			if(result<0)
			{
				if(result==-3)
				{
					RPGScene.my.msg('太守/皇帝无法迁城');
				}else if(result==-4){
					RPGScene.my.msg('已报名参加大型会战，暂时无法迁城');
				}else{
					RPGScene.my.msg(Mather._0(result));
				}
				return;
			}
			var num:uint = buff.readUnsignedInt();
			
			SanguoGlobal.userdata._province = SanguoGlobal.Configer.moveTocity;
			SanguoGlobal.userdata._citypos = num;
			RPGScene.my.msg('成功迁入 '+ Mather._7(SanguoGlobal.Configer.moveTocity));
			SanguoGlobal.userdata._province = SanguoGlobal.Configer.moveTocity;
			
			if(SanguoGlobal.Configer.depType==WorkID.MOVECITY)
			{
				SanguoGlobal.userdata.useItemByID(WorkID.ITEM_MOVECITY,SanguoGlobal.Configer.depNum);
				SanguoGlobal.Configer.depType = 0;
				SanguoGlobal.Configer.depNum = 0;
			}
			
//			Sanguo.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();//更新太守皇帝名
			RPGScene.my.changeScene(RPGScene.SCENE_WORLD);
		}
		
		/**
		 * 公告
		 */ 
		public function _3000(buff:D5ByteArray):void
		{
			//var type:uint = buff.readUnsignedByte();
			//var repy:uint = buff.readUnsignedInt(); // 重复次数
			//var times:uint = buff.readUnsignedInt(); // 间隔时间
			//var content:String = buff.readUTFBytes(900);
			
			//Sanguo.my.gonggao(content,repy);
			trace('公告更新');
			SanguoGlobal.socket.RYcall(0x6011,SanguoGlobal.SERVER_USER); // 获取最新公告
		}
		
		public function _4000(buff:D5ByteArray):void
		{
			var type:uint = buff.readUnsignedByte();
			var uid:uint = buff.readUnsignedInt();
			var time:uint = buff.readUnsignedInt();
			
			SanguoGlobal.userdata._canChat = time;
			if(type==2)
			{
				RPGScene.my.msg("您已经被管理员禁言，持续"+(time-CDCenter.my.systemTime)+"秒。");
				return;
			}
			
			var fun:Function = function():void
			{
				navigateToURL(new URLRequest("http://www.486g.com"),"_self");
			}
				
			RPGScene.my.wait();
			RPGScene.my.msg2("您已经被管理员断开游戏连接！请重新登录",fun,"提示");
			
		}
		public function _5001(buff:D5ByteArray):void
		{
			var res:int=buff.readByte();
			if(res>0){
				RPGScene.my.msg("更名成功");
				makeEvent(0x5001);
				SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}else{
				RPGScene.my.msg(Mather._0(res));
			}
		}

		/**
		 * 得到最近的公告
		 */ 
		public function _6011(buff:D5ByteArray):void
		{
			var count:uint = buff.bytesAvailable/913;
			
			var contentList:Vector.<String> = new Vector.<String>;
			var endList:Vector.<uint> = new Vector.<uint>;
			var spaceList:Vector.<uint> = new Vector.<uint>;
			for(var i:uint=0;i<count;i++)
			{
				var type:uint = buff.readUnsignedByte();
				var times:uint = buff.readUnsignedInt(); // 间隔时间
				var end:uint = buff.readUnsignedInt(); // 终止时间
				var id:uint = buff.readUnsignedInt();
				var content:String = buff.readUTFBytes(900);
				
				spaceList.push(times);
				contentList.push(content);
				endList.push(end);
				trace('公告信息:','type'+type,'times'+times,'end'+end,'id'+id,'content'+content);
			}
			
			RPGScene.my.gonggao(contentList,endList,spaceList);

		}
		/**
		 *获得儿子列表 
		 * @param buff
		 * 
		 */		
		public  function _6100(buff:D5ByteArray):void
		{
			var _arrerzi:Array=new Array()
			var num:int=buff.readByte();
			
			var opt:HYOperation;
			if((_scene as MyCityScene)!=null)
			{
				opt = (_scene as MyCityScene).operation as HYOperation;
			}
			
			for(var i:int=0;i<num;i++)
			{
				var data:FamilyData = new FamilyData();
				data._id = buff.readUnsignedInt();
				data._sonTime = buff.readUnsignedInt();
				data._name = buff.readUTFBytes(20);
				data._parent = buff.readUTFBytes(20);
				data._logoId = buff.readUnsignedInt();
				data._lv = buff.readByte();
//				trace("dataLV:=======Son",data.lv);
//				trace("buff:",buff);
//				trace("bufflength:",buff.length);
//				data._name=data.name.replace(new RegExp(/[^\u4e00-\u9fa5]/g),'')
				data._type = FamilyData.SON;
				
				if(opt) opt.addData(data,2);
			}
			if(opt) opt.ShowFamily();
		}
		/**
		 *获得妻妾列表 
		 * @param buff
		 * 
		 */		
		public  function _6101(buff:D5ByteArray):void
		{
			var _obList:Array=new Array();
			var num:int = buff.readByte();
			
			var opt:HYOperation;
			SanguoGlobal.userdata._wifeTotle=num;
			if((_scene as MyCityScene)!=null)
			{
				opt = (_scene as MyCityScene).operation as HYOperation;
			}
			if(opt==null) return;
			for(var i:int=0;i<num;i++)
			{
				var data:FamilyData = new FamilyData();
				data._id = buff.readUnsignedInt();
				data._qinmi = buff.readUnsignedInt();
				data._qinmiMax = buff.readUnsignedInt();
				data._happy = buff.readUnsignedInt();
				data._name = buff.readUTFBytes(20);
				data._huaiyun =buff.readByte();
				var IsSEE:uint = buff.readByte();
				data._logoId = buff.readUnsignedInt();
				data._sonTime = buff.readUnsignedInt();
				data._lv = buff.readByte();
				data._character=buff.readInt();
//				Debug.trace("wifeList",data.id,'|',data.logoId,data.qinmi,':',data.qinmiMax,':',data.happy,':',data.name,':',data.huaiyun,':',data.character,':',IsSEE);
				data._type = FamilyData.WIFE;
				switch(IsSEE)
				{
					case 0:
						data._see="今天没有看望"
						break;
					case 0:
						data._see="今天已经看望"
						break;
				}
				if(opt) opt.addData(data,1);
			}
			
			SanguoGlobal.socket.RYcall(0x6100,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		/**
		 *亲密妻妾 
		 * @param buff
		 * 
		 */		
		public  function _6102(buff:D5ByteArray):void
		{
			var _arr:Array=new Array();
			var rest:int = buff.readByte();
			switch(rest)
			{
				case 1:
					var qimidu:int = buff.readUnsignedInt();
					var qimifanshi:int=buff.readUnsignedInt();
					var kuailezhi:int=buff.readUnsignedInt();
					var logoId:int=buff.readUnsignedInt();
					var name:String=buff.readUTFBytes(20);
//					Sanguo.my.msg('由于去看望了'+name+'与之亲密度增加到'+qimidu);
					RPGScene.my.msg('由于去看望了'+name+'与之快乐值增加到'+kuailezhi);
					SanguoGlobal.socket.RYcall(0x6101,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//					SanguoGlobal.socket.RYcall(0x6100,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					((_scene as MyCityScene).Operation as HYOperation).showDoqiqie(qimifanshi,name,logoId);
					SanguoGlobal.socket.RYcall(0xb021,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					MissionChecker.setKEY('_65',true);
					break;
				case 0:
					RPGScene.my.msg('未知错误');
					break;
				case -1:
					RPGScene.my.msg('今天已看望过');
					break;
				case -2:
					RPGScene.my.msg('改行为达到上限');
					break;
				default:break;
			}
		}
		/**
		 *休妻 
		 * @param buff
		 * 
		 */		
		public function _6103(buff:D5ByteArray):void
		{
			var rest:int = buff.readByte();
			switch(rest)
			{
				
				case 0:
					//未知
					RPGScene.my.msg('未知!');
					break;
				case 1:
					//成功
					((_scene as MyCityScene).Operation as HYOperation)._family=null;
					RPGScene.my.msg('成功!');
					SanguoGlobal.socket.RYcall(0x6101,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					break;
			}
			//重新获取 妻妾 儿子 列表
//			SanguoGlobal.socket.RYcall(0x6101,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);

		}
		/**
		 *让儿子加入帐下 
		 * @param buff
		 * 
		 */		
		public function _6104(buff:D5ByteArray):void
		{
			var rest:int = buff.readByte();
			switch(rest)
			{
				case -18:
					//武将达到上限
					RPGScene.my.msg('武将达到上限!');
					break;
				case -1:
					//未成年
					RPGScene.my.msg('未成年!');
					break;
				case 0:
					//未知
					RPGScene.my.msg('未知!');
					break;
				case 1:
					//成功
					((_scene as MyCityScene).Operation as HYOperation)._family=null;
					RPGScene.my.msg('成功!');
					SanguoGlobal.socket.RYcall(0x6101,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					SanguoGlobal.socket.RYcall(0xb003,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//					SanguoGlobal.socket.RYcall(0x6100,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
					break;
			}
			//重新获取 妻妾列表
//			SanguoGlobal.socket.RYcall(0x6101,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//			SanguoGlobal.socket.RYcall(0x6100,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		/**
		 *给儿子取名字 
		 * @param buff
		 * 
		 */		
		public function _6105(buff:D5ByteArray):void
		{
			
			var rest:int = buff.readByte();
			switch(rest)
			{
				case 0:
					//未知 
					RPGScene.my.msg('未知!');
					break;
				case 1:
					//成功
					((_scene as MyCityScene).Operation as HYOperation)._family=null;
					RPGScene.my.msg('成功!');
					break;
			}
			//重新获取 妻妾 儿子 列表
			SanguoGlobal.socket.RYcall(0x6101,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
//			SanguoGlobal.socket.RYcall(0x6100,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
		}
		public function _6115(buff:D5ByteArray):void
		{
			var res:int=buff.readByte();
			if(res>0){
				RPGScene.my.msg("更名成功");
				makeEvent(0x5001);
				SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}else{
				RPGScene.my.msg(Mather._0(res));
			}
		}
		/**
		 *侍寝 
		 * @param buff
		 * 
		 */
		public function _6106(buff:D5ByteArray):void
		{
			var rest:int = buff.readByte();
			var Romantic:int = buff.readUnsignedInt();
			if(rest==-1)
			{
				RPGScene.my.msg("快乐度不够100");
				return;
			}
			if(rest==1&&(_scene as MyCityScene).Operation as HYOperation!=null)
			{
				if(HYOperation.qinmiTotle==105&&RPGScene.my.scene!=null)
				{
					(RPGScene.my.scene as MyCityScene).onClickBuilding(BuildingID.Problem);
					return;
				}
				((_scene as MyCityScene).Operation as HYOperation).okToSQ();
				
			}
		}
		/**
		 *请求问题
		 * @param buff
		 * 
		 */
		public function _6107(buff:D5ByteArray):void
		{
			var problem:int = buff.readUnsignedInt();
			var NowRomantic:int = buff.readUnsignedInt();
			var problemNum:int = buff.readByte();
			if((_scene as MyCityScene).Operation==null)return;
		    if((_scene as MyCityScene).Operation as SQOpration==null)return;
			((_scene as MyCityScene).Operation as SQOpration).problemShow(problem,NowRomantic,problemNum);
		}
		/**
		 *回答问题
		 * @param buff
		 * 
		 */
		public function _6108(buff:D5ByteArray):void
		{
			var RomanticIsFull:int = buff.readByte();
			var NowRomantic:int = buff.readUnsignedInt();
			var problemNum:int = buff.readByte();
			var RightAnSwer:int = buff.readByte();
			var xingdongli:int = buff.readByte();
			if(RomanticIsFull==1||RomanticIsFull==3)
			{
//				Sanguo.my.msg("与美人度过一个美好的夜晚");
				((_scene as MyCityScene).Operation as SQOpration).YesOverSQ(xingdongli,RomanticIsFull);
				return;
			}
			if(problemNum==10)
			{
				
				((_scene as MyCityScene).Operation as SQOpration).NoOverSQ(0);
				return;
			}
			if(problemNum<10&&RomanticIsFull==2)
			{
				((_scene as MyCityScene).Operation as SQOpration).CallBackQustion(RightAnSwer)
//				SanguoGlobal.socket.RYcall(0x6107,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid,SanguoGlobal.Configer.nowNPCID);
				
			}
			
		}
		/**
		 *得到答案 
		 * @param buff
		 * 
		 */
		public function _6109(buff:D5ByteArray):void
		{
			var RomanticIsFull:int = buff.readByte();
			var NowRomantic:int = buff.readUnsignedInt();
			var problemNum:int = buff.readByte();
			var RightAnSwer:int = buff.readByte();
			
			//月老代答 消耗20元宝
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb - 20;
			RPGScene.my.UI.updateUserinfo();
			
			((_scene as MyCityScene).Operation as SQOpration).yuelaoQustion(RightAnSwer)
		}
		/**
		 * 刷妻妾
		 * @param buff
		 * 
		 */
		public function _6110(buff:D5ByteArray):void
		{
			var rest:int = buff.readByte();
			var meirenID:int = buff.readUnsignedInt();
			var meirenpinzhi:int = buff.readUnsignedInt();
			var uname:String = buff.readUTFBytes(20);
			
			if(rest<0)
			{
				RPGScene.my.msg(Mather._0(rest));
				return;
			}else if(rest==0){
				RPGScene.my.msg(Mather._0(-7));
				return;
			}else{
				if(rest==2) RPGScene.my.msg("没有找到美女");
				
				if(SanguoGlobal.Configer.depType==WorkID.QIQIE)
				{
					SanguoGlobal.userdata.useItemByID(WorkID.ITEM_QIQIE,SanguoGlobal.Configer.depNum);
					SanguoGlobal.Configer.depType = 0;
					SanguoGlobal.Configer.depNum = 0;
				}else SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb-20;
				
				RPGScene.my.UI.updateUserinfo();
//				if(SanguoGlobal.userdata.wifeTotle==0)
//				{
				 //SanguoGlobal.socket.RYcall(0x6111,SanguoGlobal.SERVER_USER,SanguoGlobal.Configer.Wedding,SanguoGlobal.userdata.uid);
//				 return;
//				}
				((_scene as MyCityScene).Operation as MJOperation).hasqiqie(rest,meirenID,meirenpinzhi,uname);
				
			}
//			if(rest!=0)
//			{
//				if(rest==2)
//				{
//					Sanguo.my.msg("没有找到美女");
//				}
//				SanguoGlobal.userdata._rmb=SanguoGlobal.userdata.rmb-20;
//				Sanguo.my.UI.updateUserinfo();
//				((_scene as MyCityScene).Operation as MJOperation).hasqiqie(rest,meirenID,meirenpinzhi,uname);
//			}else
//			{
//				Sanguo.my.msg(SanguoGlobal.Configer.wordkey(100)+"不足");
//			}
			
		}
		/**
		 *招妻妾 
		 * @param buff
		 * 
		 */		
		public function _6111(buff:D5ByteArray):void
		{
			var rest:int = buff.readByte();
			trace('招妻妾6111结果',rest)
			//成功就把界面清理掉
			if(rest==1)
			{
				if(SanguoGlobal.Configer.Wedding==1)
				{
					RPGScene.my.msg("成功迎娶");
					SanguoGlobal.Configer.Wedding=1;
					SanguoGlobal.userdata._wifeTotle=SanguoGlobal.userdata.wifeTotle+1;
					((_scene as MyCityScene).Operation as MJOperation).showTipMsg();
					MissionChecker.setKEY('_64',true);
				}
				
			}
			else if(rest==0)
			{
				RPGScene.my.msg("未知错误");
			}
			else if(rest==-1)
			{
				if(SanguoGlobal.userdata.office!=1)
				{
				 RPGScene.my.msg("妻妾列表满了");
				}
			}
			((_scene as MyCityScene).Operation as MJOperation).clenmeiren();
		}
		/**
		 *查看可招美人 
		 * @param buff
		 * 	
		 */
		public function _6112(buff:D5ByteArray):void
		{
			var rest:int = buff.readByte();
			var meirenID:int = buff.readUnsignedInt();
			var meirenpinzhi:int = buff.readUnsignedInt();
			var uname:String = buff.readUTFBytes(20);
			//有可招的妻妾
			if(rest==1)
			{
				((_scene as MyCityScene).Operation as MJOperation).hasqiqie(rest,meirenID,meirenpinzhi,uname);
			}
			//没有可招的妻妾
			if(rest==2)
			{
				((_scene as MyCityScene).Operation as MJOperation).hasqiqie_NO();
			}
		}

		/**
		 *查询新手引导状态 
		 * 0为开 
		 * 1为关
		 * @param buff
		 * 
		 */
//		private var cnt:uint=0;
		public function _6200(buff:D5ByteArray):void
		{
			var www:D5ByteArray=new D5ByteArray()
			www=buff;
			SanguoGlobal.Configer.NewPlayHelpNumber=www.readUnsignedInt();
			if(SysPanel.readRrimaryStatus)
			{
				SysPanel.readRrimaryStatus=false;
				var ob:*=WinBox.my.getWindow(SysPanel);
				if(ob!=null)
				{
					ob.addAssets();	
					return;
				}
				//设置音乐
				SanguoGlobal.bgMusic.path='asset/music/background/0.mp3';
				if(uint(SanguoGlobal.Configer.NewPlayHelpNumber|0xff7fffff)!=0xffffffff)//开启
				{
//					SysPanel.volume=1-(uint(SanguoGlobal.Configer.NewPlayHelpNumber>>26)&0x0000003f)/64;
					SanguoGlobal.bgMusic.play(SanguoGlobal.bgMusic.path);
					SanguoGlobal.bgMusic.setVolume(SysPanel.volume);
					SysPanel.muteFlag=false;			
				}
				else //关闭 
				{
					SoundButton.my.unable=false;
					FightScene.quite = false;
				}
				if(EstablishScene.establisFlag)
				{
					RPGScene.my.UI.addChild(new Msg_tip(8));
					EstablishScene.establisFlag=false;
				}
				if(SanguoGlobal.cd09flag==false)//国战城战历史记录
				{
//					SanguoGlobal.cd09count=1;
//					SanguoGlobal.Configer.CountryBattleRecoderList=new Array();
//					SanguoGlobal.Configer.Country_active_list=new Array();
//					SanguoGlobal.socket.RYcall(0xcd09,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.country,SanguoGlobal.cd09count,0,1);//国战
				}
//					SanguoGlobal.socket.RYcall(0xcd09,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.province,1,1,3);//城战
				//设置扇子
//				if(uint(SanguoGlobal.Configer.NewPlayHelpNumber|0xffdfffff)!=0xffffffff)//对应的开关不为1
//				{
//					if(HelpCenter.my.helpPoint!=null)
//					{
//						HelpCenter.my.helpPoint.visible=true;
//						SysPanel.guideFan=true;
//						HelpCenter.my.update();
//					}
//				}
//				else if(HelpCenter.my.helpPoint!=null)
//				{
//					SysPanel.guideFan=false;
//					HelpCenter.my.helpPoint.visible=false;
//				}
//				backload();
			}
			var _arr:Array=new Array();
			for(var i:int=0;i<buff.length;i++)
			{
				var bb:Array=new Array();
				for( var k:int=0;k<8;k++)
				{
					var cc:int=buff[i]%2;
					buff[i]=buff[i]/2
					bb.push(cc)
				}
				bb.reverse();
				for(var num:int=0;num<bb.length;num++)
				{
					_arr.push(bb[num]);
				}
			}
			_arr.reverse();
//			trace('_arr====>>',_arr);
			if(_arr[0]!=0) return;
//			Sanguo.my.msg('_arr[0]=='+_arr[0]);
//			皇宫
//			21酒馆任务
			if(WinBox.my.getWindow(JG_Renwu)!=null&&_arr[21]==0)
			{
				((_newWIN=WinBox.my.getWindow(JG_Renwu))as JG_Renwu)._NewPlayHelp();
				return;
			}
//			20武将 ——阵型
			if(WinBox.my.getWindow(SZ_Wujiang)!=null&&_arr[20]==0)
			{
				((_newWIN=WinBox.my.getWindow(SZ_Wujiang))as SZ_Wujiang)._NewPlayHelp();
				return;
			}
//			19装备升级
			if(WinBox.my.getWindow(Strengthen)!=null&&_arr[19]==0)
			{
				((_newWIN=WinBox.my.getWindow(Strengthen))as Strengthen)._NewPlayHelp();
				return;
			}
//			18神秘商人
			if(WinBox.my.getWindow(SecretBussy)!=null&&_arr[18]==0)
			{
				((_newWIN=WinBox.my.getWindow(SecretBussy))as SecretBussy)._NewPlayHelp();
				return;
			}
//			17副本
			if(WinBox.my.getWindow(FB_all)!=null&&_arr[17]==0)
			{
				((_newWIN=WinBox.my.getWindow(FB_all))as FB_all)._NewPlayHelp();
				return;
			}
//			16竞技场
			if(WinBox.my.getWindow(JJ_all)!=null&&_arr[16]==0)
			{
				((_newWIN=WinBox.my.getWindow(JJ_all))as JJ_all)._NewPlayHelp();
				return;
			}
//	     	12 争太守
			if(WinBox.my.getWindow(GD_Cansai)!=null&&(WinBox.my.getWindow(GD_Cansai) as GD_Cansai)._type==0&&_arr[12]==0)
			{
				((_newWIN=WinBox.my.getWindow(GD_Cansai))as GD_Cansai)._NewPlayHelp();
				return;
			}
//	       13争皇帝
			if(WinBox.my.getWindow(GD_Cansai)!=null&&(WinBox.my.getWindow(GD_Cansai) as GD_Cansai)._type==1&&_arr[13]==0)
			{
				((_newWIN=WinBox.my.getWindow(GD_Cansai))as GD_Cansai)._NewPlayHelp();
				return;
			}
			
			if(!(_scene as MyCityScene)) return;
			
//			1 皇宫
			if(((_scene as MyCityScene).Operation as HGOperation)!=null&&_arr[1]==0)
			{
				((_scene as MyCityScene).Operation as HGOperation)._NewPlayHelp();
				return;
			}
//			2 官邸
			if(((_scene as MyCityScene).Operation as GDOperation)!=null&&_arr[2]==0)
			{
				((_scene as MyCityScene).Operation as GDOperation)._NewPlayHelp();
				return;
			}
//			3 兵营
			if(((_scene as MyCityScene).Operation as BYOperation)!=null&&_arr[3]==0)
			{
				((_scene as MyCityScene).Operation as BYOperation)._NewPlayHelp();
				return;
			}
//			4 民居
			if(((_scene as MyCityScene).Operation as MJOperation)!=null&&_arr[4]==0)
			{
				((_scene as MyCityScene).Operation as MJOperation)._NewPlayHelp();
				return;
			}
//			5 酒馆
			if(((_scene as MyCityScene).Operation as JGOperation)!=null&&_arr[5]==0)
			{
				((_scene as MyCityScene).Operation as JGOperation)._NewPlayHelp();
				return;
			}
//			6 市场
			if(((_scene as MyCityScene).Operation as SCOperation)!=null&&_arr[6]==0)
			{
				((_scene as MyCityScene).Operation as SCOperation)._NewPlayHelp();
				return;
			}
//			7 农田
			if(((_scene as MyCityScene).Operation as NTOperation)!=null&&_arr[7]==0)
			{
				((_scene as MyCityScene).Operation as NTOperation)._NewPlayHelp();
				return;
			}
//			8 工坊
			if(((_scene as MyCityScene).Operation as GFOperation)!=null&&_arr[8]==0)
			{
				((_scene as MyCityScene).Operation as GFOperation)._NewPlayHelp();
				return;
			}
//			9 城墙
			if(((_scene as MyCityScene).Operation as CQOperation)!=null&&_arr[9]==0)
			{
				((_scene as MyCityScene).Operation as CQOperation)._NewPlayHelp();
				return;
			}
//			10 自宅
			if(((_scene as MyCityScene).Operation as SZOperation)!=null&&_arr[10]==0)
			{
				((_scene as MyCityScene).Operation as SZOperation)._NewPlayHelp();
				return;
			}
//			11妻妾
			if(((_scene as MyCityScene).Operation as HYOperation)!=null&&_arr[11]==0)
			{
				((_scene as MyCityScene).Operation as HYOperation)._NewPlayHelp();
				return;
			}
		}
		/**
		 * 修改状态成功失败
		 * @param buff
		 * 
		 */
		public function _6201(buff:D5ByteArray):void
		{
			var rest:int = buff.readByte();
			if(rest==1){
			var ob:*=WinBox.my.getWindow(SysPanel);
			if(ob!=null)
			{
				ob.updataStatus();	
			}
			return;
			}
			RPGScene.my.msg('未保存成功');
		}
		/**
		 * 查询用户位置
		 * @param buff
		 * 
		 */
		public function _6202(buff:D5ByteArray):void
		{
			var res:int = buff.readUnsignedInt();
			trace('======6202',res);
		}
		/**
		 * 查询用户位置
		 * @param buff
		 * 
		 */
		public function _6203(buff:D5ByteArray):void
		{
			var res:int = buff.readByte();
			trace('======6203',res);
		}
		/**
		 * 开启锁定的背包
		 */
		public function _6221(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			if(result<=0)
			{
				if(result==0) RPGScene.my.msg('开启失败!');
				else RPGScene.my.msg(Mather._0(result));
				return;
			}
			SanguoGlobal.userdata._packageUnlock = SanguoGlobal.userdata.packageUnlock + 1;

			var num:int=2*(SanguoGlobal.userdata.packageUnlock-20);
			if(num>100) num=100;
			SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb-num ;
			RPGScene.my.UI.updateUserinfo();
			makeEvent(0x6221,result);
		}
		
		/**
		 * 查询神秘商人
		 */
		public function _6222(buff:D5ByteArray):void
		{
			var cityid:uint = buff.readShort();
			
			var buildid:uint = buff.readShort();
			
		}
		
		/**
		 * QQ消费建立连接用
		 */
		public function _8000(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			if(!RPGScene.my.UI.linkdatalist.length) return;
			var $ary:Array = RPGScene.my.UI.linkdatalist.shift();
			RPGScene.my.UI.callFromAS($ary[0],$ary[1],$ary[2],$ary[3]);
		}
		
		/**
		 * Q点消费
		 */
		public function _8001(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			var type:int = buff.readUnsignedInt();
			var num:int = buff.readUnsignedInt();
			
			//Sanguo.my.UI.uiChatbox.addMsg('result:'+result+'|type'+type+'|num'+num+'\n',Sanguo.my.UI.uiChatbox.nameToid('系统'));
			
			//解锁
			WorkID.my.lock(type,false);
			
			if(result<0)
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}else if(result==0){
				RPGScene.my.msg('操作失败!');
				return;
			}
			
			RPGScene.my.UI.callFromAS(ComcodeSceneQQ.GETGOLD,SanguoGlobal.userdata.uid);
			
			var fun:Function = WorkID.my.getfun(type);
			
			if(fun!=null) fun();
			
			
			if(type==WorkID.QBTOGOLD)
			{
				SanguoGlobal.userdata._rmb = SanguoGlobal.userdata.rmb + num;
				RPGScene.my.UI.updateUserinfo();
			}
			
			if(type>=WorkID.QBTOGOLD_A&&type<=WorkID.QBTOGOLD_F)
			{
				SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}
			
//			switch(type)
//			{
//				case WorkID.ACTION:
//					
//					break;
//				case WorkID.BEIBAO:
//					SanguoGlobal.socket.RYcall(0x6221,SanguoGlobal.SERVER_USER,ary[0]);
//					break;
//				case WorkID.BUSSYBUY:
//					
//					break;
//				case WorkID.BUSSYRESET:
//					SanguoGlobal.socket.RYcall(0xc015,SanguoGlobal.SERVER_USER,ary[0],ary[1],ary[2],ary[3]);
//					break;
//				case WorkID.COOLDOWN:
//					break;
//				case WorkID.PEIYANG:
//					break;
//				case WorkID.QIANGXIU:
//					break;
//				case WorkID.QIQIE:
//					break;
//				case WorkID.SHUAJIANG:
//					break;
//				case WorkID.SHUAMA:
//					break;
//				case WorkID.SHUISHOU:
//					break;
//				case WorkID.TARGET:
//					break;
//				case WorkID.WJRESET:
//					break;
//				case WorkID.XIUXI:
//					break;
//				case WorkID.YUELAO:
//					break;
//				case WorkID.ZHENGBING:
//					break;
//				default:break;
//			}
//			
//			WorkID.my.addparam(type);
		}
		
		/**
		 * 查询黄钻信息
		 */
		public function _8002(buff:D5ByteArray):void
		{
			var is_yellow_vip:uint = buff.readUnsignedInt();
			var yellow_vip_level:uint = buff.readUnsignedInt();
			var is_year_vip:uint = buff.readUnsignedInt();
			
			SanguoGlobal.comdata._isyvip = is_yellow_vip?true:false;
			SanguoGlobal.comdata._yvip = yellow_vip_level;
			SanguoGlobal.comdata._isnvip = is_year_vip?true:false;
			
			RPGScene.my.UI.NewYellowWin();
			
			if(SanguoGlobal.userdata.nickName==SanguoGlobal.Configer.config.testname) RPGScene.my.UI.uiChatbox.addMsg('黄钻信息:\n'+'is_yellow_vip:'+is_yellow_vip+'|yellow_vip_level'+yellow_vip_level+'\n',RPGScene.my.UI.uiChatbox.nameToid('系统'));
		}
		
		/**
		 * 刷新元宝信息
		 */
		public function _8003(buff:D5ByteArray):void
		{
			var rmb:int = buff.readUnsignedInt();
			
			SanguoGlobal.comdata._rmb = rmb;
			
			SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			
			if(SanguoGlobal.userdata.nickName==SanguoGlobal.Configer.config.testname) RPGScene.my.UI.uiChatbox.addMsg(SanguoGlobal.Configer.wordkey(100)+'信息:\n'+'rmb:'+rmb+'\n',RPGScene.my.UI.uiChatbox.nameToid('系统'));
//			Sanguo.my.UI.updateUserinfo();
		}
		
		/**
		 * 邀请好友奖励
		 */
		public function _8004(buff:D5ByteArray):void
		{
			
		}
		
		/**
		 * (QQ)元宝消费
		 */
		public function _8005(buff:D5ByteArray):void
		{
			var result:int = buff.readUnsignedInt();
			var type:int = buff.readUnsignedInt();
			var num:int = buff.readUnsignedInt();
			
			
		}
		
		/**
		 *更新城市信息 
		 * 
		 */
		private function updateCity():void
		{
			var needSetup:Boolean = false;
			if(RPGScene.firstRun==-1)
			{
				Debug.trace('用户信息获取完毕');
				Debug.trace('开始加载城池模块');
				RPGScene.my.loadComplete = 4;
				RPGScene.my.changeScene(RPGScene.SCENE_MYCITY);
				SanguoGlobal.socket.RYcall(0x6011,SanguoGlobal.SERVER_USER); // 获取最新公告
				needSetup = true;
			}
			
			if((_scene as MyCityScene)!=null)
			{
                if(RPGScene.my.loadComplete<4)
				{
					RPGScene.my.loadComplete=4;
				}				
				(_scene as MyCityScene).startBuild(); 
			}else if((_scene as AreaScene)!=null){
				RPGScene.my.changeScene(RPGScene.SCENE_AREA,[SanguoGlobal.userdata.province,SanguoGlobal.userdata.citypos]);
			}
			//更新左上角用户基本信息
			_scene.sanguo.UI.updateUserinfo();
			_scene.sanguo.UI.updateCityinfo();
			
			RPGScene.firstRun=SanguoGlobal.userdata.cityLv;
			
			if(needSetup)
			{
				CDCenter.my.getSystemTime();
				CDCenter.my.getWarinfo();
			}
		}
//		private function updataAreaMap():void
//		{
//			_scene.sanguo.UI.updateUserinfo();
//			_scene.sanguo.UI.updateCityinfo();
//			
//			Sanguo.firstRun=SanguoGlobal.userdata.cityLv;
//			Sanguo.my.changeScene(Sanguo.SCENE_AREA,[SanguoGlobal.userdata.province,SanguoGlobal.userdata.citypos]);
//		}
		/**
		 *蛮夷来袭活动开启查询 
		 * @param buff
		 * 
		 */
		private function _b300(buff:D5ByteArray):void
		{
			var rest:int=buff.readByte();
			var bufCd:int=buff.readUnsignedInt();
			
		}
		/**
		 *蛮夷来袭发动攻击 
		 * @param buff
		 * 
		 */
		private function _b301(buff:D5ByteArray):void
		{
			var rest:int=buff.readByte();
			var BattleReport:String=buff.readUTFBytes(64);
			var jifen:int=buff.readShort();
			var num:int=buff.readByte();
			for(var i:int=0;i<num;i++)
			{
				var type:int=buff.readShort();
				var id:int=buff.readUnsignedInt();
				var number:int=buff.readShort();
			}
		}
		private function _b302(buff:D5ByteArray):void
		{
			var AllJifen:int=buff.readUnsignedInt();
			var Rank:int=buff.readUnsignedInt();
			var RankOfnumber:int =buff.readShort();
			var thisOfnumber:int =buff.readShort();
			for(var i:int=0;i<thisOfnumber;i++)
			{
				var UseId:int=buff.readUnsignedInt();
				var UseName:String=buff.readUTFBytes(30);
				var UseLvl:int=buff.readByte();
				var UseJifen:int=buff.readUnsignedInt();
			}
		}
		private function _b303(buff:D5ByteArray):void
		{
			var rest:int=buff.readByte();
			switch(rest)
			{
				case 0:
					RPGScene.my.msg("无需冷却");
					break;
				case 1:
					RPGScene.my.msg("操作成功");
					break;
			}
		}
		public function _b400(buff:D5ByteArray):void
		{
			RPGScene.my.closeWait();
			var arr:Vector.<Object> = new Vector.<Object>();
			for(var i:uint=0;i<2;i++)
			{
				var obj:Object = new Object();
				obj['id'] = buff.readInt();
				obj['type'] = buff.readByte();
				obj['uid'] = buff.readInt();
				obj['name'] = buff.readUTFBytes(30);
				
				obj['city_props']=buff.readInt();
				
				
				obj['nation_num']=buff.readShort();
				obj['d_name']=buff.readUTFBytes(30);
				
				obj['reward'] = buff.readUnsignedInt();
				obj['etype'] = buff.readByte();
				arr.push(obj);
				//trace("b400xxx==============>>",buff.length,obj.id,obj.type,obj.uid,"name:",obj.name,'sf:',obj.city_props,"sfa:",obj.nation_num,obj.d_name,obj.reward,obj.etype);
			}

			makeEvent(0xb400,arr);

			//(WinBox.my.getWindow(JG_Renwu) as JG_Renwu).setData1(arr);

		}
		
		/**
		 * 团队状态查询
		 */
		public function _b500(buff:D5ByteArray):void
		{
			var num:uint = buff.readByte();
			
			var auraList:Vector.<AuraData> = new Vector.<AuraData>;
			for(var v:uint=0;v<num;v++)
			{
				var auradata:AuraData = new AuraData();
				auradata.id = buff.readUnsignedInt();
				auradata.time = buff.readUnsignedInt();
				auradata.name = SanguoGlobal.Configer.itemConfig(auradata.id).equ_prop_name;
				//auradata.targetid = id;
				auraList.push(auradata);
			}
			SanguoGlobal.userdata._teamAuralist = auraList;
			
			if(RPGScene.firstRun==-1)
			{
				//临时刷新JJC相关信息
				SanguoGlobal.socket.RYcall(0xd021,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				return;
			}
		}
		
		/**
		 * 被 巡查/巡视 剩余时间
		 */
		public function _b620(buff:D5ByteArray):void
		{
			var taishou:int = buff.readInt();
			
			var huangdi:int = buff.readInt();
			
			if(taishou>0) CDCenter.my.update(CDCenter.TXUNSHI,taishou);
			if(huangdi>0) CDCenter.my.update(CDCenter.HXUNSHI,huangdi);
			
			if(RPGScene.firstRun==-1)
			{
				//团队状态查询
				SanguoGlobal.socket.RYcall(0xb500,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
				return;
			}
		}
		public function _6114(buff:D5ByteArray):void
		{
			var rest:int=buff.readByte();
			if(rest==1||rest==2)
			{
				if(WinBox.my.getWindow(Housekeeper)==null) return ;
				((_newWIN=WinBox.my.getWindow(Housekeeper))as Housekeeper).qiqieButton(rest);
			}
			
		}
		
		/**
		 * 迁国
		 */
		public function _7000(buff:D5ByteArray):void
		{
			var result:int = buff.readByte();
			
			(_scene as EstablishScene).enterGame();
			
		}
		
		/**
		 * 获取国家状态
		 */
		public function _7001(buff:D5ByteArray):void
		{
			var wei:int = buff.readByte();
			var shu:int = buff.readByte();
			var wu:int = buff.readByte();
			
			while(WorldCityScene.ctrydie.length)
			{
				WorldCityScene.ctrydie.splice(0,1);
			}
			
			WorldCityScene.ctrydie.push(0);
			WorldCityScene.ctrydie.push(wei);
			WorldCityScene.ctrydie.push(shu);
			WorldCityScene.ctrydie.push(wu);
			
			if(RPGScene.my.scene!=null && (RPGScene.my.scene as LoginScene)!=null) {
				(RPGScene.my.scene as LoginScene).connectLogin();
			}else{
				if(WorldCityScene.ctrydie[SanguoGlobal.userdata.country]==1)
				{
				connectLogin();
				}
			}
		}
		private var reconnect:int=3;
		private function connectLogin():void
		{
			LoginScene.socket = new YYSocket();
			LoginScene.socket.encoder = new RYEncoder();
			decoder = new RYDecoder();
			LoginScene.socket.decoder = decoder;
			LoginScene.socket.addEventListener(Event.CONNECT,onConnectLogin);
			LoginScene.socket.addEventListener(Event.CLOSE,onClose);
			LoginScene.socket.addEventListener(IOErrorEvent.IO_ERROR,onSecurity);
			LoginScene.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurity);
			Debug.trace('已经灭国,连接登录服务器x...1',SanguoGlobal.SERVER,SanguoGlobal.SERVER_LOGIN_PORT);
			SanguoGlobal.LoginInuse=true;
			LoginScene.socket.connect(SanguoGlobal.SERVER,SanguoGlobal.SERVER_LOGIN_PORT);
		}
		private function onSecurity(e:Event):void
		{
			reconnect--;
			if(reconnect<=0)
			{
				RPGScene.my.msg('无法连接到服务器，请稍后再试！');
				return;
			}
			trace('重连',reconnect);
			LoginScene.socket.connect(SanguoGlobal.SERVER,SanguoGlobal.SERVER_LOGIN_PORT);
		}
		
		
		private function onClose(e:Event):void
		{
			trace("链接已关闭");
		}
		private function onConnectLogin(e:Event):void
		{
				Debug.trace('已经灭国,连接登录服务器...2',SanguoGlobal.SERVER,SanguoGlobal.SERVER_LOGIN_PORT);
				LoginScene.socket.removeEventListener(Event.CONNECT,onConnectLogin);
				LoginScene.socket.comcode(SanguoGlobal.SERVER_LOGIN);
				var timer:Timer=new Timer(100,1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,login);
				timer.start();
		}
		private function login(e:TimerEvent):void
		{
			e.target.removeEventListener(TimerEvent.TIMER_COMPLETE,login);
			LoginScene.socket.RYcall(0x0006,SanguoGlobal.SERVER_LOGIN,RPGScene.my.flashvars.userid,RPGScene.my.flashvars.tstamp,RPGScene.my.flashvars.comcode,RPGScene.my.flashvars.ticket);
		}
		public function _7007(buff:D5ByteArray):void
		{
			var res:int=buff.readByte();
			if(res<0){
				RPGScene.my.msg(Mather._0(res));
			}else {
				RPGScene.my.msg("迁国成功！");
				SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			}
			var city_code:int=buff.readUnsignedInt();
			var city_id:int=buff.readUnsignedByte();
			var coutry_id:int=buff.readUnsignedByte();
			SanguoGlobal.userdata._citypos=city_code;
			SanguoGlobal.userdata._province=city_id;
			SanguoGlobal.userdata._posArea=city_id;
			SanguoGlobal.userdata._country=coutry_id;
			updateCity();
			SanguoGlobal.userdata.updatapackage();
//			if(Sanguo.my.scene is AreaScene)
//			{
//				updataAreaMap();
//			}
			trace("_7007======",res,city_code,coutry_id,city_id);
		}
		
		public function _b401(buff:D5ByteArray):void
		{
			RPGScene.my.closeWait();                                                                                                                    
			var result:int=buff.readByte();
			trace("CCCCCCCCCC========>>>>>>>>",result);
			if(result<0) 
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			makeEvent(0xb401);
			RPGScene.my.msg("发布成功");
		}

		public function _b402(buff:D5ByteArray):void
		{
			RPGScene.my.closeWait();
			var result:int=buff.readByte();
			trace("CCCCCCCCCx========>>>>>>>>",result);
			if(result<0) 
			{
				RPGScene.my.msg(Mather._0(result));
				return;
			}
			RPGScene.my.msg("任务完成");
			//更新用户信息
//			SanguoGlobal.socket.RYcall(0x0008,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.uid);
			makeEvent(0xb402);
		}
		/**
		 * 购买马匹
		 * 
		 */
		public function _f00b(buff:D5ByteArray):void
		{
			var buy:int = buff.readByte();
			if(buy < 0)
			{
				RPGScene.my.msg(Mather._0(buy));
				return;
			}
			else if(buy==0) 
			{
				RPGScene.my.msg('背包已满!');
				return;
			}
			if(buy==1&&SanguoGlobal.Configer.nowSelectitem!=null) 
			{
				_scene.showMsg("购买成功！");
				makeEvent(0xc00b);
				//				SanguoGlobal.userdata.updatapackage();
				//				SanguoGlobal.userdata.addItem(SanguoGlobal.Configer.nowItemdata);
			}
			SanguoGlobal.socket.RYcall(0xc010,SanguoGlobal.SERVER_USER,SanguoGlobal.userdata.province,SanguoGlobal.userdata.uid,2);
			SanguoGlobal.userdata.updatapackage();
			if(SanguoGlobal.Configer.BuyhorseID!=0&&SanguoGlobal.Configer.itemConfig(SanguoGlobal.Configer.BuyhorseID).equ_prop_type==3)
			{
				MissionChecker.setKEY('_51',true);
			}
			else if(SanguoGlobal.Configer.nowItemdata.id!=0&&SanguoGlobal.Configer.itemConfig(SanguoGlobal.Configer.nowItemdata.id).equ_prop_type==1)
			{
				MissionChecker.setKEY('_49',true);
				
			}
			if((_newWIN=WinBox.my.getWindow(JG_Majiu))as JG_Majiu!=null)
			{
				SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold-SanguoGlobal.Configer.itemConfig(SanguoGlobal.Configer.BuyhorseID).pay_silver;
			}
			//			{ 
			//				var temp:uint=(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Majiu).goumai.horseId;
			//				if(temp!=0) 
			//				{
			//					SanguoGlobal.userdata._gold=SanguoGlobal.userdata.gold-SanguoGlobal.Configer.itemConfig(temp).pay_silver;
			//					(((_scene as MyCityScene).Operation as JGOperation).win2 as JG_Majiu).goumai.horseId=0;
			//				}
			//				((_scene as MyCityScene).Operation as JGOperation).showMa2();
			//			}
			RPGScene.my.UI.updateUserinfo();
			RPGScene.my.UI.updateCityinfo();
			return;
		}
		
		/* -- Event Interface --*/
		
		private function makeEvent(cmd:uint,data:*=null):void
		{
			dispatchEvent(new SocketEvent(SocketEvent.COMPLATE,cmd,data));
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
		
	}
}

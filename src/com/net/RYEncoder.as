package com.net
{
	import com.D5Power.encoder.D5Encoder;
	import com.D5Power.utils.D5ByteArray;
	
	import flash.utils.ByteArray;
	import com._486G.utils.ErrorCenter;
	public class RYEncoder extends D5Encoder
	{
		public function RYEncoder()
		{
			super();
		}
		
		/**
		 * 登录
		 */
		public function _6(bytes:D5ByteArray,data:Array):void
		{
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[0]);
			for(var i:uint = buf.length;i<20;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			bytes.writeUnsignedInt(data[1]);
			
			buf.writeUTFBytes(data[2]);
			for(i = buf.length;i<10;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			bytes.writeUTFBytes(data[3]);
		}
		private var _7cnt:uint;
		/**
		 * 创建角色
		 */ 
		public function _7(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[1]);
			for(var i:uint = buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			
			bytes.writeByte(data[2]);
			
			bytes.writeShort(data[3]);
			
			bytes.writeShort(data[4]);
			
			bytes.writeUnsignedInt(data[5]);
			if(_7cnt>0){
				ErrorCenter.my.addErrorLog("error103"+data[1]+_7cnt);
			} 
			_7cnt++;
		}
		
		/**
		 * 用户详细信息
		 */ 
		public function _8(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _c(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[2]);
			for(var i:uint=buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			bytes.writeUTFBytes(data[3]);
		}
		
		public function _d(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[1]);
			for(var i:uint=buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			buf.writeUTFBytes(data[2]);
			for(i=buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			bytes.writeUTFBytes(data[3]);
		}
		
		public function _e(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[1]);
			for(var i:uint=buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			bytes.writeUTFBytes(data[2]);
			
		}
		
		public function _f(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _10(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeShort(data[1]);
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[2]);
			for(var i:uint=buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			bytes.writeUnsignedInt(data[3]);
			bytes.writeUnsignedInt(data[4]);
			bytes.writeByte(data[5]);
			bytes.writeByte(data[6]);
			bytes.writeByte(data[7]);
			
		}
		
		public function _12(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		
		public function _13(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _15(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _16(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _17(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _18(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUTFBytes(data[1]);
		}
		public function _19(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _1a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _1b(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeUnsignedInt(data[3]);
		}
		public function _aa00(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeShort(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _aa01(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeShort(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _a004(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeShort(data[2]);
			bytes.writeShort(data[3]);
		}
		
		public function _a005(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeShort(data[3]);
			bytes.writeShort(data[4]);
		}
		
		public function _a006(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeShort(data[2]);
			bytes.writeShort(data[3]);
		}
		/**
		 * 获取常务列表
		 * 4字节 用户ID
		 */
		public function _b001(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		/**
		 * 处理常务
		 * 4字节 用户ID
		 * 4字节 常务ID
		 * 4字节 处理方式编号
		 */
		public function _b002(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _b003(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _b004(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		} 
		
		public function _b005(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		} 
		
		public function _b006(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		
		public function _b007(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		
		public function _b008(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
		}
		
		public function _b009(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b00a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		
		public function _b00b(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b00c(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b00d(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b00e(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b00f(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b010(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b011(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b012(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b013(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b014(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b016(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b017(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b018(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b019(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _b021(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			
		}
		
		public function _b01a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _b01b(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _b01c(bytes:D5ByteArray,data:Array):void
		{
		   bytes.writeUnsignedInt(data[0]);
		   bytes.writeUnsignedInt(data[1]);
		   bytes.writeUnsignedInt(data[2]);
		   bytes.writeByte(data[3]);
		}
		public function _b01d(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _b01e(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _b01f(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b0f1(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b020(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _b022(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _b023(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _b032(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _b024(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _b025(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b026(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeShort(data[2]);
		}
		public function _b027(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _b028(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _b029(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _b02a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _b100(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b101(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b102(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b103(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b104(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b105(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b106(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b107(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b108(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b109(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b10a(bytes:D5ByteArray,data:Array):void
		{
 			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b10b(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b10c(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b10d(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b10e(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b10f(bytes:D5ByteArray,data:Array):void
		{
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[0]);
			for(var i:uint = buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
		}
		
		public function _b110(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _b111(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			
		}
		
		public function _b200(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			var buf:ByteArray = new ByteArray();
//			
			buf.writeUTFBytes(data[1]);
//			
			for(var i:uint=buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _b201(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeShort(data[2]);
			bytes.writeUnsignedInt(data[3]);
		}
		
		public function _b202(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeShort(data[3]);
			bytes.writeUnsignedInt(data[4]);
			
		}
		public function _b204(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			
		}
		public function _b205(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeShort(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _b206(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _b207(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _b208(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _bf07(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _bf08(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _b401(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeByte(data[3]);
		}
		public function _b402(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _b500(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b620(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _c000(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		
		public function _c001(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _c002(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _ce02(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _cf02(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _c003(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeShort(data[2]);
		}
		public function _ce03(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeShort(data[2]);
		}
		public function _cf03(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeShort(data[2]);
		}
		
		public function _c004(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			
		}
		public function _ce04(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _cf04(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _c005(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _ce05(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _cf05(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _c006(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _c007(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _c008(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		
		public function _c009(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeByte(data[3]);
		}
		
		public function _c109(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _ff00(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeByte(data[3]);
		}
		
		public function _ff01(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeUnsignedInt(data[3]);

		}	
		public function _ff02(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _c00a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeUnsignedInt(data[3]);
			bytes.writeShort(data[4]);
		}
		
		public function _c00b(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeShort(data[3]);
			bytes.writeByte(data[4]);
		}
		
		public function _c00c(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
			bytes.writeByte(data[4]);
		}
		
		public function _c00d(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _c00e(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		
		public function _c019(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _c00f(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _c010(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		
		public function _c011(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
			bytes.writeByte(data[4]);
		}
		
		public function _c012(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _c013(bytes:D5ByteArray,data:Array):void
		{
			//bytes.writeByte(data[0]);
			
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[1]);
			for(var i:uint; buf.length < 30; i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
		}
		
		public function _c014(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeUnsignedInt(data[3]);
			bytes.writeUnsignedInt(data[4]);
			bytes.writeShort(data[5]);
			bytes.writeShort(data[6]);
			bytes.writeShort(data[7]);
			bytes.writeShort(data[8]);
		}
		
		public function _c015(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
		}
		
		public function _c016(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeUnsignedInt(data[3]);
			bytes.writeUnsignedInt(data[4]);
			bytes.writeByte(data[5]);
		}
		
		public function _c017(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _c018(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _c020(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2].length);
			for(var i:uint=0;i<data[2].length;i++)
			{
				bytes.writeUnsignedInt(data[2][i][0]);
				bytes.writeUnsignedInt(data[2][i][1]);
			}
		}
		
		public function _c021(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _c022(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _c023(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _c024(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _c025(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _c030(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);	
		}
		public function _c031(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);	
		}
		public function _cc00(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _cd00(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeByte(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _cd01(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			var buf:ByteArray = new ByteArray();
			
			buf.writeUTFBytes(data[1]);
			for(var i:uint = buf.length;i<600;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			bytes.writeUnsignedInt(data[2]);
		}
		public function _cd02(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		
		public function _cd03(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			
		}
		public function _cd04(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			
		}
		public function _cd05(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _cd06(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _cd07(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);	
		}
		public function _cd08(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _cd09(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeShort(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeByte(data[3]);
		}
		public function _d000(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0])
			for(var i:uint = 1;i < 6;i++)
			{
				bytes.writeUnsignedInt(data[i]);
			}	
		}
		public function _d002(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeUnsignedInt(data[3]);
			bytes.writeUnsignedInt(data[4]);
			bytes.writeUnsignedInt(data[5]);
			
			var buf:ByteArray = new ByteArray();
			
			buf.writeUTFBytes(data[6]);
			for(var i:uint = buf.length;i<120;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
		}
		public function _d003(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeShort(data[2]);
			bytes.writeByte(data[3]);
		}
		public function _d004(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeShort(data[2]);
			bytes.writeByte(data[3]);
		}
		
		
		public function _d005(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _d006(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		
		public function _d007(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _d008(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeUnsignedInt(data[3]);
		}
		public function _d009(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _dccc(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _d010(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _d00a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _d00c(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);	
		}
		public function _d00d(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
			
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[3]);
			for(var i:uint = buf.length;i<120;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
		}
		public function _d00e(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _d00f(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _d020(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeUnsignedInt(data[3]);
		}
		public function _d021(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _d022(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _d023(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);	
		}
		public function _d024(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[3]);
			for(var i:uint = buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
		}
		public function _d040(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}	
		public function _d041(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _d042(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		
		public function _d050(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _d052(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _d053(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _d054(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _d056(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _d057(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _d090(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);	
		}
		public function _d091(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _d092(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _d093(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
		}
		public function _d094(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeUnsignedInt(data[3]);
		}
		public function _d095(bytes:D5ByteArray,data:Array):void
		{
			
		}
		public function _d096(bytes:D5ByteArray,data:Array):void
		{
			
		}
		public function _d097(bytes:D5ByteArray,data:Array):void
		{
			
		}
		public function _d098(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeByte(data[3]);
		}
		public function _d099(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _dbbb(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _d09a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
			
		}
		public function _d09b(bytes:D5ByteArray,data:Array):void
		{
		}
		public function _e000(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		
		public function _e001(bytes:D5ByteArray,data:Array):void
		{
//			if(SanguoGlobal.Configer.e001enable==false) return;
//			trace('e001已发送||',data[0]);
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
//			SanguoGlobal.Configer.e001enable=false;
		}
		
		public function _5000(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _5001(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			var buf:ByteArray = new ByteArray();
			trace("name======>>>",data[2],data[2].length);
			buf.writeUTFBytes(data[2]);
			trace("buflength",buf.length,buf);
			for(var i:uint=buf.length;i<=30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			trace("bytes",bytes.length);
			buf.clear();
		}

		public function _6001(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		
		public function _e002(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _6005(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[1]);
			for(var i:uint=buf.length;i<30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			buf.writeUTFBytes(data[2]);
			for(i=buf.length;i<50;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
			buf.writeUTFBytes(data[3]);
			for(i=buf.length;i<400;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
		}
		
		public function _6006(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _1111(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6007(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		
		public function _600a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			
			for(var i:uint=0;i<data[1];i++)
			{
				bytes.writeUnsignedInt(data[i+2]);
			}
		}
		
		public function _600c(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeByte(data[3]);
		}
		
		public function _600d(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6012(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6021(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6100(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6101(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6102(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
//			bytes.writeByte(data[2]);
		}
		public function _6103(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6104(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6105(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			var buf:ByteArray = new ByteArray();
			trace("name======>>>",data[2],data[2].length);
			buf.writeUTFBytes(data[2]);
			trace("buflength",buf.length);
			for(var i:uint=buf.length;i<=30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			trace("bytes",bytes.length);
			buf.clear();
			
		}
		public function _6115(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			var buf:ByteArray = new ByteArray();
			buf.writeUTFBytes(data[2]);
			for(var i:uint=buf.length;i<=30;i++) buf.writeByte(0);
			bytes.writeBytes(buf);
			buf.clear();
		}
		public function _6106(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6107(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6108(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
		}
		public function _6109(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
		}
		public function _6110(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		public function _6111(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeByte(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6200(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6201(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6202(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6203(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _6112(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6221(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6222(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b300(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b301(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b302(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeShort(data[1]);
			bytes.writeShort(data[2]);
		}
		public function _b400(bytes:D5ByteArray,data:Array):void
		{
			//Sanguo.my.wait();
			bytes.writeUnsignedInt(data[0]);
		}
		public function _b303(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6114(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _f00b(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeShort(data[3]);
			bytes.writeByte(data[4]);
		}
		//获取爵位
		public function _6300(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			trace("0x6300 sended!");
		}
		//皇帝封的爵位列表
		public function _6301(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);	
			trace("0x6301 sended!");
		}
        //皇帝封爵
		public function _6302(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);		
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
//		领工资
		public function _6303(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			trace("0x6303 sended!");
		}
		//手动升爵位
		public function _6304(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			trace("0x6304 sended!");
		}
		//得到最高威望非太守本国用户
		public function _6305(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
			trace("0x6305 sended!");
		}
		//兑换喜好品
		public function _6306(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
			bytes.writeByte(data[2].length/2);
			for(var i:uint=0;i<data[2].length;i++)
			{
				bytes.writeUnsignedInt(data[2][i]);
			}
		}
		public function _6307(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _6308(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		//得到每日目标列表
		public function _6320(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		//领取奖励
		public function _6321(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		//刷新奖励
		public function _6322(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeByte(data[1]);
		}
		//刷新奖励
		public function _6323(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _7000(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _7001(bytes:D5ByteArray,data:Array):void
		{
			
		}
		public function _7007(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		/**
		 * QQ消费建立连接
		 */
		public function _8000(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _9000(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeUnsignedInt(data[0]);
		}
		public function _9001(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeShort(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _9002(bytes:D5ByteArray,data:Array):void
		{
		    bytes.writeUnsignedInt(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
		}
		public function _9004(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeShort(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _9006(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeShort(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
		public function _9008(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeShort(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeByte(data[2]);
			bytes.writeUnsignedInt(data[3]);
		}
		public function _900a(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeShort(data[0]);
			bytes.writeUnsignedInt(data[1]);
			bytes.writeUnsignedInt(data[2]);
			bytes.writeByte(data[3]);
			bytes.writeByte(data[4]);
		}
		public function _900b(bytes:D5ByteArray,data:Array):void
		{
			bytes.writeShort(data[0]);
			bytes.writeUnsignedInt(data[1]);
		}
	}
}
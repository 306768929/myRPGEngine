package com.net
{
	import com.D5Power.encoder.D5Decoder;
	import com.D5Power.net.D5Socket;
	import com.D5Power.net.D5SocketBottomHandle;
	import com.D5Power.ns.NSD5Net;
	import com.D5Power.utils.D5ByteArray;
	import com._486G.utils.ErrorCenter;
	
	use namespace NSD5Net;
	public class YYSocketBottomHandle extends D5SocketBottomHandle
	{
		public function YYSocketBottomHandle(_socket:D5Socket)
		{
			super(_socket);
		}
		
		override protected function parseData():void
		{
			if(!headLoaded)
			{
				// 包头长度满足条件 解析包头
				if(socket.bytesAvailable >= D5Decoder.headLength)
				{
					//socket.endian = Endian.LITTLE_ENDIAN;
					/* ---- 读取通讯头（00 00 00 00）与本地运行无关，无需处理 ----*/
					var head:int = socket.readInt();

					/* ---- 读取命令码 ---- */				
					cmd = socket.readUnsignedShort().toString(16);

					/* ---- 读取数据长度 ---- */
					bodyLength = socket.readUnsignedInt()-D5Decoder.headLength;

					
					/* ---- 读取标志位 ---- */
					var sign:D5ByteArray = new D5ByteArray();
					sign.writeByte(socket.readUnsignedByte());
					isZip = sign.getBitAt(1);					
					
					headLoaded = true;
					buffer==null ? buffer=new D5ByteArray() : buffer.clear();
				}
			}
			
			//添加操作记录
//			ErrorCenter.my.addError('#101_'+cmd,1);
			
			//超时归零
			YYSocket.delayDir[cmd] = -1;
			YYSocket.params[cmd]="";
			
			// 包头已读取
			if(headLoaded)
			{
				if(bodyLength==0)
				{
					// 包头长度为0，直接解析
					if(_decoder.hasOwnProperty('_'+cmd)) _decoder['_'+cmd](buffer);
					resetStatus();
					if(socket.connected && socket.bytesAvailable!=0) parseData();
					return;
				}
				if(socket.bytesAvailable>=bodyLength)
				{
					socket.readBytes(buffer,0,bodyLength);
					D5ByteArray.nowProsess = cmd;
					
					if(isZip&&false)
					{
						//数据部分解密
						buffer = XXTEA.Decode(buffer);
					}
					
					// 开始解析
					if(_decoder.hasOwnProperty('_'+cmd)) _decoder['_'+cmd](buffer);
					resetStatus();
					if(socket.bytesAvailable!=0) parseData();
				}
			}
			
		}
		
	}
}
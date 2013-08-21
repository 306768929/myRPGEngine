/**
 * D5Power Studio FPower 2D MMORPG Engine
 * 第五动力FPower 2D 多人在线角色扮演类网页游戏引擎
 * 
 * copyright [c] 2010 by D5Power.com Allrights Reserved.
 */

package stuff
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	/**
	 * 资源池
	 * 
	 */ 
	public class ResourcePool
	{
		/**
		 * 资源池队列
		 */ 
		protected var pool:Dictionary;
		
		/**
		 * 生成资源池
		 */ 
		public function ResourcePool()
		{
			pool = new Dictionary();
		}
		/**
		 * 向资源池中增加对象
		 */ 
		public function addResource(key:String,obj:*):void
		{
			//trace(key,obj,'资源++++++++');
			if(pool[key]==null) pool[key]=obj;
		}
		/**
		 * 从资源池中获取对象
		 */ 
		public function getResource(key:String):*
		{
			return pool[key];
		}
		/**
		 * 更新资源池中的对象
		 */ 
		public function updateResource(key:String,obj:*):void
		{
			dispose(key);
			pool[key] = obj;
		}
		/**
		 * 向资源池中减少对象
		 */ 
		public function removeResource(key:String):void
		{
			if(pool[key]==null) return;
			dispose(key);
			delete pool[key];
		}
		/**
		 * 清除所有资源
		 */
		public function clear():void
		{
			for(var key:String in pool)
			{
				dispose(key);
				delete pool[key];
			}
		}
		
		private function dispose(key:String):void
		{
			if(pool[key] is Bitmap)
			{
				(pool[key] as Bitmap).bitmapData.dispose();
			}
			
			if(pool[key] is BitmapData)
			{
				(pool[key] as BitmapData).dispose();
			}
		}
	}
}
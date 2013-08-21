package CCUICoponent
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 镜像循环UI
	 */ 
	public class D5MirrorLoop extends D5Component
	{
		public static const TYPEID:uint = 3;
		public static const TYPEIDX:uint = 333;
		
		protected var _workMode:uint = 0;
		
		protected var _starter:Shape
		protected var _looper:Shape;
		protected var _ender:Shape;
		
		/**
		 * 整体尺寸
		 */ 
		protected var _size:uint;
		
		/**
		 * 工作模式X轴循环
		 */ 
		public static const XLOOP:uint = 0;
		/**
		 * 工作模式Y轴循环
		 */ 
		public static const YLOOP:uint = 1;
		
		public static function makeResource(b:BitmapData,mirrosize:uint,workmode:uint=0):Vector.<BitmapData>
		{
			var res:Vector.<BitmapData> = new Vector.<BitmapData>;
			
			var part1:BitmapData;
			var part2:BitmapData;
			switch(workmode)
			{
				case XLOOP:
					part1 = new BitmapData(mirrosize,b.height,true,0x00000000);
					part2 = new BitmapData(b.width-mirrosize,b.height,true,0x00000000);
					
					part1.copyPixels(b,new Rectangle(0,0,part1.width,part1.height),new Point(),null,null,true);
					part2.copyPixels(b,new Rectangle(part1.width,0,part2.width,part2.height),new Point(),null,null,true);
					break;
				
				case YLOOP:
					part1 = new BitmapData(b.width,mirrosize,true,0x00000000);
					part2 = new BitmapData(b.width,b.height-mirrosize,true,0x00000000);
					
					part1.copyPixels(b,new Rectangle(0,0,part1.width,part1.height),new Point(),null,null,true);
					part2.copyPixels(b,new Rectangle(0,part1.height,part2.width,part2.height),new Point(),null,null,true);
					break;
				
				default:
					throw new Error("Not supported loop mode.");
					break;
			}
			res.push(part1);
			res.push(part2);
			
			return res;
		}
		
		/**
		 * @param	resource	源素材
		 * @param	size	循环尺寸
		 * @param	workmode	循环模式
		 */ 
		public function D5MirrorLoop(resource:Vector.<BitmapData>,size:uint,workmode:uint=0)
		{
			_size = size
			_workMode=workmode;
			super(resource);
		}
		
		/**
		 * 绘制
		 */ 
		public function draw(size:uint):void
		{
			if(_size==size || size==0) return;
			_size = size;
			setup();
		}
		
		override protected function setup():void
		{
			if(_size==0) return;
			if(!_starter)
			{
				_starter = new Shape();
				_looper = new Shape();
				_ender = new Shape();
				
				_starter.graphics.beginBitmapFill(_resource[0],null,false);
				_starter.graphics.drawRect(0,0,_resource[0].width,_resource[0].height);
				
				addChild(_starter);
				addChild(_looper);
				addChild(_ender);
			}else{
				_looper.graphics.clear();
			}
			
			switch(_workMode)
			{
				case XLOOP:
					
					_looper.graphics.beginBitmapFill(_resource[1]);
					_looper.graphics.drawRect(0,0,_size-_resource[0].width*2,_resource[1].height);
					
					if(_ender.width==0)
					{
						_ender.graphics.beginBitmapFill(_resource[0],new Matrix(-1,0,0,1,_resource[0].width),false);
						_ender.graphics.drawRect(0,0,_resource[0].width,_resource[0].height);
					}
					
					_looper.x = _starter.width;
					_ender.x = _looper.x+_looper.width;
					
					break;
				
				case YLOOP:
					
					_looper.graphics.beginBitmapFill(_resource[1]);
					_looper.graphics.drawRect(0,0,_resource[0].width,_size-_resource[0].height*2);
					
					if(_ender.width==0)
					{
						_ender.graphics.beginBitmapFill(_resource[0],new Matrix(1,0,0,-1,0,_resource[0].height),false);
						_ender.graphics.drawRect(0,0,_resource[0].width,_resource[0].height);
					}
					
					_looper.y = _starter.height;
					_ender.y = _looper.y+_looper.height;
					break;
				
				default:
					
					throw new Error("Not supported loop mode.");
					break;
			}
			
			
			
			super.setup();
		}
	}
}
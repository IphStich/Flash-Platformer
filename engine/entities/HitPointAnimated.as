package iphstich.platformer.engine.entities 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import iphstich.platformer.engine.HitData;
	
	/**
	 * ...
	 * @author IphStich
	 */
	public class HitPointAnimated extends MovieClip
	{
		public var label:String;
		public var index:int;
		
		public var cx:Number;
		public var cy:Number;
		
		public function HitPointAnimated() 
		{
			super();
			
			visible = false;
			
			var str:Array = this.name.split("_");
			label = str[0];
			index = int(str[1]);
		}
		
		public static function SORT_BY_INDEX (a:HitPointAnimated, b:HitPointAnimated) : int
		{
			if (a.index < b.index) return -1;
			if (a.index > b.index) return 1;
			
			return 0;
		}
		
		public function calculatePosition () : void
		{
			var oldX:Number;
			var oldY:Number;
			var newX:Number = x;
			var newY:Number = y;
			
			var m:Matrix;
			
			var target:DisplayObject;
			target = this;
			
			while (!(target is Entity))
			{
				target = target.parent;
				
				m = target.transform.matrix;
				
				oldX = newX;
				oldY = newY;
				
				newX = oldX * m.a + oldY * m.c + m.tx;
				newY = oldX * m.b + oldY * m.d + m.ty;
			}
			
			cx = newX;
			cy = newY;
		}
	}
}
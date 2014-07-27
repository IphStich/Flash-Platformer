package iphstich.platformer.engine
{
	import flash.display.DisplayObject;
	import iphstich.platformer.engine.entities.HitPoint;
	
	public class HitData
	{
		public static const TYPE_SURFACE:int = 1;
		public static const TYPE_OTHER:int = 2;
		public static const TYPE_TOP:int = 3;
		public static const TYPE_LEFT:int = 4;
		public static const TYPE_RIGHT:int = 5;
		public static const TYPE_BOTTOM:int = 6;
		public static const TYPE_INTERNAL:int = 7;
		
		private static var instances:Vector.<HitData>;
		private static var place:int = -1;
		public static function hit (hit:DisplayObject, x:Number, y:Number, time:Number=0, type:int=TYPE_OTHER) : HitData
		{
			if (instances == null) instances = new Vector.<HitData>(50);
			
			if (place == -1) {
				return new HitData(hit, x, y, time, type);
				
			} else {
				var inst:HitData = instances[place--];
				
				inst.hit 	= hit;
				inst.x 		= x;
				inst.y 		= y;
				inst.t 		= time;
				inst.type 	= type;
				inst.point 	= null;
				
				return inst;
			}
		}
		public static function old (target:HitData)
		{
			if (place >= instances.length) {
				instances.push(target);
				++place;
			} else
				instances[++place] = target;
		}
		
		public static function SORT_BY_T (a:HitData, b:HitData) : Number
		{
			if (a.t == -1 && b.t == -1) return 0;
			if (a.t == -1) return 1;
			if (b.t == -1) return -1;
			
			if (a.t < b.t) return -1;
			if (a.t > b.t) return 1;
			return 0;
		}
		
		public var hit:DisplayObject;
		public var x:Number;
		public var y:Number;
		public var t:Number;
		public var type:int;
		public var point:HitPoint;
		
		public function HitData (hit:DisplayObject, x:Number, y:Number, time:Number, type:int)
		{
			this.hit 	= hit;
			this.x 		= x;
			this.y 		= y;
			this.t 		= time;
			this.type 	= type
			this.point 	= null;
		}
		
		public function toString():String
		{
			return "hit[ ( " + x + " , " + y + " , " + t + " ) " + hit + "]";
		}
		
		public function destroy () : void
		{
			old(this);
		}
	}
}
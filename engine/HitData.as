package iphstich.platformer.engine
{
	import flash.display.DisplayObject;
	import iphstich.platformer.engine.entities.HitPoint;
	
	public class HitData
	{
		private static var instances:Vector.<HitData>;
		private static var place:int = -1;
		public static function hit (hit:DisplayObject, x:Number, y:Number, time:Number=0) : HitData
		{
			if (instances == null) instances = new Vector.<HitData>(50);
			
			if (place == -1) {
				return new HitData(hit, x, y);
				
			} else {
				var inst:HitData = instances[place--];
				inst.hit = hit;
				inst.x = x;
				inst.y = y;
				//inst.point = null;
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
		
		public var hit:DisplayObject;
		public var x:Number;
		public var y:Number;
		//public var point:HitPoint;
		
		public function HitData(hit:DisplayObject, x:Number, y:Number)
		{
			this.hit 	= hit;
			this.x 		= x;
			this.y 		= y;
			//this.point 	= null;
		}
		
		public function toString():String
		{
			return "hit[ ( " + x + " , " + y + " ) " + hit + "]";
		}
		
		public function destroy () : void
		{
			old(this);
		}
	}
}
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
			var hd:HitData;
			
			if (instances == null) instances = new Vector.<HitData>(50);
			
			if (place == -1) {
				hd = new HitData();
			} else {
				hd = instances[place--];
			}
			
			hd.hit = hit;
			hd.x = x;
			hd.y = y;
			hd.t = time;
			hd.type = type;
			
			return hd;
		}
		public static function old (target:HitData)
		{
			//var i = instances.indexOf(target);
			//if (i <= place && i != -1)
				//throw Error("DOUBLE OLD " + i + " "  + place + oldRecords[i] + "\n\n");
			
			target.reset();
			
			if (place >= instances.length) {
				//oldRecords.push (Error("").getStackTrace());
				instances.push(target);
				++place;
			} else {
				//oldRecords[place+1] = (Error("").getStackTrace());
				instances[++place] = target;
			}
		}
		
		//static var oldRecords:Array = new Array();
		
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
		
		public function HitData ()
		{
			this.reset();
		}
		
		public function toString():String
		{
			return "hit[ ( " + x + " , " + y + " , " + t + " ) " + hit + "]";
		}
		
		public function destroy () : void
		{
			old(this);
		}
		
		public function reset () : void
		{
			hit = null;
			x = 0;
			y = 0;
			t = 0;
			type = 0;
			point = null;
		}
	}
}
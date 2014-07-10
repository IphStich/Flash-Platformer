package iphstich.platformer.engine.entities
{
	import Math;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.HitData;
	
	public class HitPoint
	{
		//public var engine:Engine;
		public var x:Number;
		public var y:Number;
		public var size:Number;
		public var parent:Entity;
		public var hitList:Vector.<Class>;
		
		public function HitPoint(xOffset:Number, yOffset:Number, you:Entity, radius:Number=1)
		{
			x 		= xOffset;
			y 		= yOffset;
			parent 	= you;
			size	= radius;
		}
		
		private var lastCheckTime:Number
		private var lastCheckKeyTime:Number;
		private var lastCheckResult:Vector.<HitData>
		public function getHitPath () : Vector.<HitData>
		{
			// No collision if the parent isn't moving
			if (parent.x == parent.px && parent.y == parent.py)
			{
				clearResultVector();
				return lastCheckResult;
			}
			
			var i:int;
			var hd:HitData;
			var engine:Engine = parent.level.engine;
			
			// Prevents the check from happening multiple times in one frame
			//if ((lastCheckTime == engine.time) /*&& (lastCheckKeyTime == parent.kt)*/) return lastCheckResult;
			//lastCheckTime = engine.time;
			
			clearResultVector();
			
			// Do the collision trace
			parent.level.testHitPath
				( lastCheckResult
				, x + parent.x
				, y + parent.y
				, x + parent.px
				, y + parent.py
			);
			
			for (i=lastCheckResult.length-1; i>=0; --i)
			{
				// set point to this....
				lastCheckResult[i].point = this;
				
				// remove referrences to parent
				if (lastCheckResult[i].hit == parent) {
					lastCheckResult.splice(i, 1)[0].destroy();
				}
			}
			
			return lastCheckResult;
		}
		
		private function clearResultVector ()
		{
			if (lastCheckResult != null) while (lastCheckResult.length > 0) lastCheckResult.pop().destroy();
			else lastCheckResult = new Vector.<HitData>();
		}
	}

}
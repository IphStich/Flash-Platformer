package iphstich.platformer.engine.entities
{
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.HitData;
	
	public class HitPoint
	{
		public var engine:Engine;
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
		public function getHitPath():Vector.<HitData>
		{
			var i:uint;
			
			// prevents the check from happening multiple times in one frame
			if ((lastCheckTime == engine.time) && (lastCheckKeyTime == parent.kt)) return lastCheckResult;
			lastCheckTime = engine.time;
			lastCheckKeyTime = parent.kt;
			
			var lf:Number = engine.lastFrame;
			if (lf < lastCheckKeyTime) lf = lastCheckKeyTime;
			
			if (lastCheckResult != null) while (lastCheckResult.length > 0) lastCheckResult.pop().destroy();
			else lastCheckResult = new Vector.<HitData>();
			
			if (engine.tickStyle == Engine.TICK_CALCULATED)
			{
				parent.level.testHitPath
					( lastCheckResult
					, parent.getX(lf) + x
					, parent.getY(lf) + y
					, parent.getX(lastCheckTime) + x
					, parent.getY(lastCheckTime) + y
					, size
					, lf
					, lastCheckTime
					, -1
					, hitList
				);
			}
			else
			{
				parent.level.testHitPath
					( lastCheckResult
					, parent.x
					, parent.y
					, parent.kx
					, parent.ky
				);
			}
			
			for (i=0; i<lastCheckResult.length; ++i)
				if (lastCheckResult[i].hit == parent) {
					lastCheckResult.splice(i, 1)[0].destroy();
				}
			
			return lastCheckResult;
		}
	}

}
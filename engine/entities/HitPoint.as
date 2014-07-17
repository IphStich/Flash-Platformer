package iphstich.platformer.engine.entities
{
	import flash.geom.Matrix;
	import flash.geom.Point;
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
			var i:int;
			var hd:HitData;
			
			clearResultVector();
			
			// Do the collision trace
			parent.level.testHitPath
				( lastCheckResult
				, oldX()
				, oldY()
				, newX()
				, newY()
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
		
		public function oldX () : Number
		{
			var m:Matrix = parent.oldTransform;
			return x * m.a + y * m.c + m.tx;
		}
		
		public function oldY () : Number
		{
			var m:Matrix = parent.oldTransform;
			return x * m.b + y * m.d + m.ty;
		}
		
		public function newX () : Number
		{
			var m:Matrix = parent.newTransform;
			return x * m.a + y * m.c + m.tx;
		}
		
		public function newY () : Number
		{
			var m:Matrix = parent.newTransform;
			return x * m.b + y * m.d + m.ty;
		}
		
		public function getHitPathBetweenPoints (other:HitPoint) : Vector.<HitData>
		{
			var results:Vector.<HitData> = new Vector.<HitData>();
			
			// do actual trace test
			parent.level.testHitPath
				( results
				, this.newX()
				, this.newY()
				, other.newX()
				, other.newY()
			);
			
			
			var i:int;
			var hd:HitData;
			for (i=results.length-1; i>=0; --i)
			{
				hd = results[i];
				hd.t = -1; // set t values to -1 (meaning "indefinitely last")
				hd.point = this;
			}
			
			return results;
		}
		
		private function clearResultVector ()
		{
			if (lastCheckResult != null) while (lastCheckResult.length > 0) lastCheckResult.pop().destroy();
			else lastCheckResult = new Vector.<HitData>();
		}
	}

}
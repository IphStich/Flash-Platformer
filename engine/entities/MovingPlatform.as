package iphstich.platformer.engine.entities 
{
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.parts.Block;
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.platformer.engine.levels.parts.Platform;
	/**
	 * ...
	 * @author IphStich
	 */
	public class MovingPlatform extends Entity
	{
		public var platform:Part;
		
		public function MovingPlatform() 
		{
			super();
			
			collisionPoints.pop();
			
			platform = new Platform();
			//platform = new Block();
			setDimensions(x, y, x + scaleX * 100, y + scaleY * 100);
		}
		
		override public function tickThink(style:uint, delta:Number):void 
		{
			super.tickThink(style, delta);
			
			//vx = Math.random() * 400 - 200;
			
			//moveBy(vx * delta, 0);
			//adjustPlatform();
		}
		
		public function setDimensions (l:Number, t:Number, r:Number, b:Number) : void
		{
			//baseLeft = l;
			//baseTop = t;
			//baseRight = r;
			//baseBottom = b;
			platform.setDimensions(l, t, r, b);
		}
		
		override public function hitTestPath(x1:Number, y1:Number, x2:Number, y2:Number):HitData 
		{
			return platform.hitTestPath(x1, y1, x2, y2);
		}
		
		protected function moveBy (x:Number, y:Number) : void
		{
			moveAttachedBy(x, y);
			
			platform.left += x;
			platform.right += x;
			platform.top += y;
			platform.bottom += y;
		}
		
		protected function moveAttachedBy (x:Number, y:Number) : void
		{
			var e:Entity;
			for each (e in platform.attachedEntities)
			{
				e.x += x;
				e.px += x;
				e.y += y;
				e.py += y;
			}
		}
		
		//private function adjustPlatform () : void
		//{
			//platform.setDimensions
				//( baseLeft + dispX
				//, baseTop + dispY
				//, baseRight + dispX
				//, baseBottom + dispY
			//);
		//}
	}
}
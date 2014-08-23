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
		
		private var movedX:Number = 0;
		private var movedY:Number = 0;
		
		public function MovingPlatform() 
		{
			super();
			
			collisionPoints.pop();
			
			movedX = x;
			movedY = y;
			
			platform = new Platform();
			//platform = new Block();
			setDimensions(0, 0, scaleX * 100, scaleY * 100);
		}
		
		public function setDimensions (l:Number, t:Number, r:Number, b:Number) : void
		{
			platform.setDimensions(movedX + l, movedY + t, movedX + r, movedY + b);
		}
		
		override public function hitTestPath(x1:Number, y1:Number, x2:Number, y2:Number):HitData 
		{
			return platform.hitTestPath(x1, y1, x2, y2);
		}
		
		protected function moveBy (x:Number, y:Number) : void
		{
			movedX += x;
			movedY += y;
			
			// move attached
			var e:Entity;
			for each (e in platform.attachedEntities)
			{
				e.x += x;
				e.px += x;
				e.y += y;
				e.py += y;
			}
			
			// move platform
			platform.left += x;
			platform.right += x;
			platform.top += y;
			platform.bottom += y;
		}
	}
}
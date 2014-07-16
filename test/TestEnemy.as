package iphstich.platformer.test
{
	import Math;
	
	import iphstich.platformer.engine.entities.WalkingEntity;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.platformer.engine.Engine;
	
	/**
	 * The TestEnemy simply walks back and forth along whatever platform it lands on.
	 */
	public class TestEnemy extends WalkingEntity
	{
		public function TestEnemy()
		{
			super();
			
			setSize (30, 30);
		}
		
		//override public function tickThink (style:uint, delta:Number) : void
		//{
			//if (surface != null)
			//{
				//if (Math.abs(vx) != 250)
				//{
					//vx = 250;
				//}
			//}
		//}
		
		override protected function land (data:HitData) : void
		{
			super.land(data);
			
			vx = 250 * ((vx >= 0) ? 1 : -1)
		}
		
		override protected function hitEdge (side:Number) : void
		{
			px = side;
			vx *= -1;
		}
		
		override protected function hitWall(direction:int, data:HitData):void
		{
			var vx:Number = this.vx;
			super.hitWall (direction, data);
			this.vx = -1 * vx;
		}
	}
}
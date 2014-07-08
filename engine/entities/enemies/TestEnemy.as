package iphstich.platformer.engine.entities.enemies
{
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
		
		override public function tickThink (style:uint, delta:Number) : void
		{
			if (surface != null)
			{
				if (vx == 0)
				{
					vx = 250;
				}
			}
		}
		
		override protected function hitEdge(side:Number, time:Number):void
		{
			vx *= -1;
		}
		
		override protected function hitWall(direction:String, data:HitData):void
		{
			super.hitWall (direction, data);
			
			// reverse direciton
			vx *= -1;
		}
	}
}
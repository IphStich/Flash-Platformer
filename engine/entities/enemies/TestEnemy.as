package iphstich.platformer.engine.entities.enemies
{
	import iphstich.platformer.engine.entities.WalkingEntity;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.platformer.engine.Engine;
	
	public class TestEnemy extends WalkingEntity
	{
		public function TestEnemy()
		{
			super();
			
			setSize (30, 30);
		}
		
		override protected function makeDecisions() : void
		{
			if (surface != null)
			{
				if (getVX(Engine.time) == 0) {
					setCourse( { vx: 250 }, Engine.time );
				}
			}
		}
		
		override protected function hitEdge(side:Number, time:Number):void
		{
			setCourse({vx: -getVX(time) }, time);
		}
		
		override protected function hitWall(direction:String, data:HitData):void
		{
			//this.alpha = (this.alpha == 1) ? 0.25 : 1;
			
			var wall:Part = data.hit as Part;
			if (direction == "left") {
				this.setCourse( { vx: -getVX(data.time), ax: 0, cx: NaN, kx: wall.right - hitBox.left + 1.001 }, data.time );
			} else if (direction == "right") {
				this.setCourse( { vx: -getVX(data.time), ax: 0, cx: NaN, kx: wall.left - hitBox.right - 1.001 }, data.time );
			}
			
			// the default behaviour is identical to when it hits the edge of a platform
			//var side:Number = (direction == "right") ? wall.left : wall.right;
			//hitEdge(getTimeX(side));
		}
	}
}
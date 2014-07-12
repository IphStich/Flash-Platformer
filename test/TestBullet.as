package iphstich.platformer.test
{
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.entities.projectiles.Bullet;
	/**
	 * ...
	 * @author IphStich
	 */
	public class TestBullet extends Bullet
	{
		public function TestBullet() 
		{
			super();
			
			team = 1;
		}
		
		override public function shoot(lev:Level, startX:Number, startY:Number, speedX:Number, speedY:Number, time:Number):void
		{
			super.shoot(lev, startX, startY, speedX, speedY, time);
			ax = -speedX * 3/2
		}
		
		override public function tickMove (delta:Number):void
		{
			super.tickMove(delta);
			
			// explode at the max distance
			if (ax * vx >= 0)
				explode(null);
		}
	}
}
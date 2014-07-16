package iphstich.platformer.test 
{
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.Camera;
	/**
	 * ...
	 * @author IphStich
	 */
	public class TestCamera extends Camera
	{
		public var player:Player;
		
		override public function updateCameraProperties (delta:Number) : void
		{
			if (player == null || player.level != level) {
				player = (level.getEntityByType(Player) as Player);
			}
			
			var targetX:Number = player.x;
			var targetY:Number = (player.y - player.getHeight()/2);
			
			targetX += player.vx * 1.5;
			targetY += player.vy / 2;
			
			viewX = (viewX + targetX * delta) / (1+delta);
			viewY = (viewY + targetY * delta) / (1+delta);
			
			if (viewX >= level.left && viewX <= level.right
				&& viewY >= level.top && viewY <= level.bottom)
			{
				restrictViewToLevel();
			}
		}
	}
}
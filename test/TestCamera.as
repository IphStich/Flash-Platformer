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
		
		private var shiftX:Number = 0;
		private var shiftY:Number = 0;
		
		override public function updateCameraProperties (delta:Number) : void
		{
			if (player == null || player.level != level) {
				player = (level.getEntityByType(Player) as Player);
			}
			
			var targetX:Number = 0;
			var targetY:Number = 0; //(player.y - player.getHeight()/2);
			
			targetX += player.facing * 200 / scale();
			targetY += player.vy / 2 / scale();
			
			delta *= scale() * 3 / 4;
			
			shiftX = (shiftX + targetX * delta) / (1+delta);
			shiftY = (shiftY + targetY * delta) / (1+delta);
			
			viewX = player.x + shiftX;
			viewY = (player.y - player.getHeight()/2) + shiftY;
			
			if (player.x >= level.left && player.x <= level.right
				&& player.y >= level.top && player.y <= level.bottom)
			{
				restrictViewToLevel();
			}
		}
		
		//override protected function scale():Number 
		//{
			//return 2;
		//}
	}
}
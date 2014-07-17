package iphstich.platformer.engine 
{
	import iphstich.library.CustomMath;
	import flash.geom.Rectangle;
	import iphstich.platformer.engine.levels.Level;
	/**
	 * ...
	 * @author IphStich
	 */
	public class Camera 
	{
		public var engine:Engine;
		public var viewport:Rectangle;
		
		protected var level:Level;
		
		protected var viewX:Number = 0;
		protected var viewY:Number = 0;
		
		public function Camera() 
		{
			
		}
		
		public function start ()
		{
			this.viewport = engine.viewport;
		}
		
		public function tick (delta:Number) : void
		{
			level = engine.level;
			
			updateCameraProperties(delta);
			
			level.x = -viewX;
			level.y = -viewY;
			
			engine.view.scaleX = scale();
			engine.view.scaleY = engine.view.scaleX;
		}
		
		public function updateCameraProperties (delta:Number) : void
		{
			viewX = (level.left + level.right) / 2;
			viewY = (level.top + level.bottom) / 2;
		}
		
		protected function restrictViewToLevel () : void
		{
			viewX = CustomMath.capBetween(viewX, level.left + viewport.width/2 / scale(), level.right - viewport.width/2 / scale());
			viewY = CustomMath.capBetween(viewY, level.top + viewport.height/2 / scale(), level.bottom - viewport.height/2 / scale());
		}
		
		protected function scale () : Number
		{
			return 1;
		}
	}
}
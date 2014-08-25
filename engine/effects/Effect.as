package iphstich.platformer.engine.effects 
{
	import flash.events.Event;
	import iphstich.platformer.engine.Renderable;
	/**
	 * ...
	 * @author IphStich
	 */
	public class Effect extends Renderable
	{
		public function Effect() 
		{
			super()
			
			this.addEventListener(Event.EXIT_FRAME, efh);
		}
		
		private function efh (e:Event = null)
		{
			if ((totalFrames > 1) && (currentFrame == totalFrames))
			{
				EffectsManager.endEffect(this);
			}
		}
	}
}
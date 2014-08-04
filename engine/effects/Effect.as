package iphstich.platformer.engine.effects 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	/**
	 * ...
	 * @author IphStich
	 */
	public class Effect extends MovieClip
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
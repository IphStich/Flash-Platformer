package iphstich.platformer.engine.levels.interactables
{
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.HitBox;
	
	public class Interactable extends HitBox
	{
		public function Interactable()
		{
			super();
			snapDimensions();
		}
		
		public function activate (caller:Entity, time:Number) : void
		{
			trace("ACTIVATE!")
		}
	}
}
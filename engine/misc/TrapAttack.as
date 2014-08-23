package iphstich.platformer.engine.misc 
{
	import iphstich.platformer.engine.entities.Entity;
	/**
	 * ...
	 * @author IphStich
	 */
	public class TrapAttack 
	{
		public var DAMAGE:Number = 1;
		public var owner:Entity;
		
		public function TrapAttack (owner:Entity)
		{
			this.owner = owner;
		}
	}
}
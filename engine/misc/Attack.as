package iphstich.platformer.engine.misc 
{
	import iphstich.platformer.engine.entities.Character;
	/**
	 * ...
	 * @author IphStich
	 */
	public class Attack 
	{
		public var DAMAGE:Number = 5;
		public var owner:Character;
		
		public function Attack (owner:Character) 
		{
			this.owner = owner;
		}
	}
}
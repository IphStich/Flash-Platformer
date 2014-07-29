package iphstich.platformer.engine.entities 
{
	import iphstich.platformer.engine.misc.TrapAttack;
	/**
	 * ...
	 * @author IphStich
	 */
	public class Trap extends Entity
	{
		protected var trapAttack:TrapAttack;
		
		public function Trap() 
		{
			super();
			
			trapAttack = new TrapAttack(this);
		}
		
		protected function hit (other:Entity)
		{
			other.hitBy(trapAttack);
		}
	}
}
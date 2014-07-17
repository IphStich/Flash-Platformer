package iphstich.platformer.engine.entities.bosses
{
	import iphstich.platformer.engine.entities.WalkingCharacter;
	import iphstich.platformer.engine.levels.Level;
	
	/**
	 * ...
	 * @author
	 */
	public class Boss extends WalkingCharacter
	{
		public var pattern:String;
		
		public function Boss()
		{
			super();
		}
		
		override public function spawn(x:Number, y:Number, time:Number, lev:Level):void 
		{
			super.spawn(x, y, time, lev);
			
			pattern = "spawn";
		}
	}
}
package iphstich.platformer.engine.levels.interactables
{
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.levels.interactables.Interactable;
	import iphstich.platformer.engine.entities.Entity;
	//import iphstich.platformer.engine.entities.Player;
	import iphstich.platformer.engine.Engine;
	
	public class Door extends Interactable
	{
		public var local:String;
		public var next:String;
		public var target:String;
		
		public function Door()
		{
			super();
			
			// interpret name for data
			var ns:Array = name.split("_");
			if (ns.length < 3) throw Error("Incorrect number of arguments for the Door. Please seperate arguments with an underscore. Expected no less than 3, got " + ns.length);
			local 	= ns[0];
			next 	= ns[1];
			target 	= ns[2];
		}
		
		override public function activate (caller:Entity, time:Number) : void
		{
			if (next.length > 0) //caller is Player && 
			{
				// get and set the next level
				var nextLevel:Level = Level.getLevel( next )
				//Engine.instance.setLevel( nextLevel );
				
				// move the player to the next level
				var targetDoor:Door = nextLevel.getDoor( target );
				caller.spawn
					( (targetDoor.left + targetDoor.right) / 2
					, targetDoor.bottom
					, time
					, nextLevel
				);
			}
		}
	}
}
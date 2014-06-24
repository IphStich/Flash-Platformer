package iphstich.platformer.engine.levels.parts
{
	import iphstich.platformer.engine.levels.parts.Part;
	
	public class Block extends Part
	{
		public function Block()
		{
			super();
			slope = 0;
		}
		
		override public function checkConnection(other:Part) : int
		{
			if (other.top != this.top) return 0;
			if ((other.left != this.right) && (other.right != this.left)) return 0;
			
			return 1;
		}
	}
}
package iphstich.platformer.engine.levels.misc
{
	import flash.geom.Point;
	import iphstich.platformer.engine.HitBox;
	
	/**
	 * ...
	 * @author  IphStich
	 */
	public class Area extends HitBox
	{
		public function Area()
		{
			super();
		}
		
		public function get center () : Point
		{
			return new Point(x + width / 2, y + height / 2);
		}
	}
}
package iphstich.platformer.engine 
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author IphStich
	 */
	public class Renderable extends MovieClip
	{
		// the Entity's render depth priority. Higher numbers means it appears in front of other Entities
		public var depthPriority:Number = 0;
	}
}
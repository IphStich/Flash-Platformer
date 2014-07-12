package iphstich.platformer.engine 
{
	
	/**
	 * ...
	 * @author IphStich
	 */
	public interface ICollidable 
	{
		function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData;
	}
	
}
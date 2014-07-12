package iphstich.platformer.engine 
{
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author IphStich
	 */
	public interface ICollidable 
	{
		function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData;
		
		function isWithinRadius (x:Number, y:Number, r:Number) : Boolean;
		
		function getRadialCheckPoints (fromX:Number, fromY:Number) : Vector.<Point>;
	}
	
}
package iphstich.platformer.engine.levels.misc 
{
	import iphstich.platformer.engine.HitBox;
	import iphstich.platformer.engine.HitData;
	/**
	 * ...
	 * @author IphStich
	 */
	public class Trigger extends HitBox
	{
		public var params:Array;
		public var label:String;
		public var canBeActivated:Boolean = true;
		
		public function Trigger() 
		{
			super()
			
			snapDimensions();
			
			this.canHitInternal = true;
			
			params = name.split("_");
			label = params[0];
		}
		
		override public function hitTestPath(x1:Number, y1:Number, x2:Number, y2:Number):HitData 
		{
			if (!canBeActivated) return null;
			
			return super.hitTestPath(x1, y1, x2, y2);
		}
	}
}
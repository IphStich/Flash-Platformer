package iphstich.platformer.engine.levels.parts
{
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.levels.parts.Part;
	
	public class Block extends Part
	{
		override public function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData
		{
			var hd:HitData = super.hitTestPath (x1, y1, x2, y2);
			
			if (hd != null)
			{
				if (hd.type == HitData.TYPE_TOP)
					hd.type = HitData.TYPE_SURFACE;
			}
			
			return hd;
		}
	}
}
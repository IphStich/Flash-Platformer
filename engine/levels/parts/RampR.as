package iphstich.platformer.engine.levels.parts
{
	import iphstich.library.CustomMath;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.parts.Part;
	
	public class RampR extends Part
	{
		public function RampR()
		{
			super();
			slope = -(bottom - top) / (right - left);
		}
		
		override public function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData
		{
			var c:Number;
			
			if (x1 < left && x2 < left) return null;
			if (y1 < top && y2 < top) return null;
			if (x1 > right && x2 > right) return null;
			if (y1 > bottom && y2 > bottom) return null;
			
			// bottom
			if (y1 > bottom)
			{
				c = x1 + (bottom - y1) / (y2 - y1) * (x2 - x1);
				if (c >= left && c <= right)
					return HitData.hit(this, c, bottom, 0, HitData.TYPE_BOTTOM);
				//else
					//return null;
			}
			
			// right
			if (x1 > right)
			{
				c = y1 + (right - x1) / (x2 - x1) * (y2 - y1);
				if (c >= top && c <= bottom)
					return HitData.hit(this, right, c, 0, HitData.TYPE_RIGHT);
				//else
					//return null;
			}
			
			// slope
			if (y1 < getTopAt(x1) && y2 >= getTopAt(x2))
			{
				if (x1 != x2)
				{
					var m2:Number = (y2 - y1) / (x2 - x1);
					var b2:Number = y1 - m2 * x1;
					var xi:Number = (b2 - bottom) / (slope - m2);
					
					return HitData.hit(this, xi, getTopAt(xi), 0, HitData.TYPE_SURFACE);
				}
				else
				{
					return HitData.hit(this, x1, getTopAt(x1), 0, HitData.TYPE_SURFACE);
				}
			}
			
			return null;
		}
	}
}
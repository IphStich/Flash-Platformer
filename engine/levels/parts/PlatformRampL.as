package iphstich.platformer.engine.levels.parts 
{
	import iphstich.platformer.engine.HitData;
	/**
	 * ...
	 * @author IphStich
	 */
	public class PlatformRampL extends Platform
	{
		override public function setDimensions(l:Number, t:Number, r:Number, b:Number):void 
		{
			super.setDimensions(l, t, r, b);
			
			slope = (bottom - top) / (right - left);
		}
		
		override public function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData
		{
			if (x1 < left && x2 < left) return null;
			if (y1 < top && y2 < top) return null;
			if (x1 > right && x2 > right) return null;
			if (y1 > bottom && y2 > bottom) return null;
			
			// slope
			if (y1 < getTopAt(x1) && y2 >= getTopAt(x2))
			{
				if (x1 != x2)
				{
					var m2:Number = (y2 - y1) / (x2 - x1);
					var b2:Number = y1 - m2 * x1;
					var xi:Number = (b2 - top) / (slope - m2);
					
					return HitData.hit(this, xi, getTopAt(xi), 0, HitData.TYPE_SURFACE);
				}
				else
				{
					return HitData.hit(this, x1, getTopAt(x1), 0, HitData.TYPE_SURFACE);
				}
			}
			
			return null;
		}
		
		//override public function getRadialCheckPoints (fromX:Number, fromY:Number) : Vector.<Point>
		//{
			//var ret:Vector.<Point> = new Vector.<Point>();
			//
			//if (fromX < left) ret.push (new Point(left, top));
			//else if (fromX > right) ret.push(new Point(right, top));
			//else ret.push(new Point(fromX, top));
			//
			////ret.push(new Point((left + right) / 2, y + (top + bottom) / 2));
			//return ret;
		//}
		
		//override public function isWithinRadius (x:Number, y:Number, r:Number) : Boolean
		//{
			//if (y > top) return false;
			//
			//if (x >= left && x <= right)
			//{
				//return ((top - y) <= r);
			//}
			//var cx:Number;
			//
			//if (x < left) cx = left;
			//else // if (x > right)
				//cx = right;
			//
			//var cy:Number = (y - top);
			//cx -= x;
			//
			//cx *= cx;
			//cy *= cy;
			//
			//if (cx + cy <= r * r) return true;
			//else return false;
		//}
	}
}
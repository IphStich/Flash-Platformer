package iphstich.platformer.engine.levels.parts 
{
	import flash.geom.Point;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.parts.Part;
	
	/**
	 * ...
	 * @author IphStich
	 */
	public class Platform extends Part
	{
		override public function checkConnection ( other:Part ) : int
		{
			if (other.bottom == this.top) return 1;
			
			if (other.top != this.top) return 0;
			if ((other.left != this.right) && (other.right != this.left)) return 0;
			
			return 1;
		}
		
		override public function getTopAt (x:Number) : Number
		{
			return top;
		}
		
		override public function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData
		{
			// collision only works when going down onto the surface/top
			
			if (y1 > top) return null;
			if (y2 < top) return null;
			if (x1 < left && x2 < left) return null;
			if (x1 > right && x2 > right) return null;
			
			var c:Number;
			c = x1 + (top - y1) / (y2 - y1) * (x2 - x1);
			if (c >= left && c <= right)
				return HitData.hit (this, c, top, 0, HitData.TYPE_SURFACE);
			else
				return null;
		}
		
		override public function getRadialCheckPoints (fromX:Number, fromY:Number) : Vector.<Point>
		{
			var ret:Vector.<Point> = new Vector.<Point>();
			
			if (fromX < left) ret.push (new Point(left, top));
			else if (fromX > right) ret.push(new Point(right, top));
			else ret.push(fromX, top);
			
			//ret.push(new Point((left + right) / 2, y + (top + bottom) / 2));
			return ret;
		}
		
		override public function isWithinRadius (x:Number, y:Number, r:Number) : Boolean
		{
			if (y > top) return false;
			
			if (x >= left && x <= right)
			{
				return ((top - y) <= r);
			}
			var cx:Number;
			
			if (x < left) cx = left;
			else // if (x > right)
				cx = right;
			
			var cy:Number = (y - top);
			cx -= x;
			
			cx *= cx;
			cy *= cy;
			
			if (cx + cy <= r * r) return true;
			else return false;
		}
	}
}
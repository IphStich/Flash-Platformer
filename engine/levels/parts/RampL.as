package iphstich.platformer.engine.levels.parts
{
	import iphstich.library.CustomMath;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.parts.Part;
	
	public class RampL extends Part
	{
		public function RampL()
		{
			super();
			slope = (bottom - top) / (right - left);
		}
		
		override public function hitTest(x:Number, y:Number, radius:Number):Boolean
		{
			if (super.hitTest(x, y, radius) == false) return false;
			
			if (x >= left && y <= bottom) {
				//y = surface.bottom + (X) * .slope
				//(Ax1+ Bx1 + C)^2 / (A^2 + B^2) <= radius^2
				var D:Number = (slope * (x - left)) - y + top;
				if (Math.abs(D) * D / (1 + slope * slope) >= radius * radius) return false
			}
			
			return true;
		}
		
		override public function checkConnection (other:Part) : int
		{
			if ((other.right == this.left) && (other.top == this.top))
			{
				return 1;
			}
			if ( (other.top == this.bottom) && ((this.right >= other.left) && (this.right <= other.right)) )
			{
				return 2;
			}
			if ((other is RampR) && this.bottom == other.bottom && this.right == other.left)
			{
				return 2;
			}
			//if (other.top != this.top) return 0;
			//if ((other.left != this.right) || (other.right != this.left)) return 0;
			
			return 0;
		}
		
		override public function getTopAt (x:Number) : Number
		{
			return top + (x - left) * slope;
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
			}
			
			// left
			if (x1 < left)
			{
				c = y1 + (left - x1) / (x2 - x1) * (y2 - y1);
				if (c >= top && c <= bottom)
					return HitData.hit(this, left, c, 0, HitData.TYPE_LEFT);
			}
			
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
	}
}
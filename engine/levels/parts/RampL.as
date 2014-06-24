package iphstich.platformer.engine.levels.parts
{
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.library.CustomMath;
	
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
		
		override public function checkConnection(other:Part) : int
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
	}
}
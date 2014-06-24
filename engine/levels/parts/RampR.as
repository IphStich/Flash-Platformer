package iphstich.platformer.engine.levels.parts
{
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.library.CustomMath;
	
	public class RampR extends Part
	{
		public function RampR()
		{
			super();
			slope = -(bottom - top) / (right - left);
		}
		
		override public function hitTest(x:Number, y:Number, radius:Number):Boolean
		{
			if (super.hitTest(x, y, radius) == false) return false;
			
			if (x <= right && y <= bottom) {
				//(Ax1+ Bx1 + C)^2 / (A^2 + B^2) <= radius^2
				var D:Number = slope * (x - left) - y + bottom
				if (Math.abs(D) * D / (1 + slope * slope) >= radius * radius) return false
			}
			
			return true;
		}
		
		override public function checkConnection(other:Part) : int
		{
			if ((other.left == this.right) && (other.top == this.top))
			{
				return 1;
			}
			if ( (other.top == this.bottom) && ((this.left >= other.left) && (this.left <= other.right)) )
			{
				return 2;
			}
			//if (other.top != this.top) return 0;
			//if ((other.left != this.right) || (other.right != this.left)) return 0;
			
			return 0;
		}
	}
}
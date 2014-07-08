package iphstich.platformer.engine
{
	import flash.display.MovieClip;
	import iphstich.platformer.Main;
	
	public class HitBox extends MovieClip
	{
		public var top:Number;
		public var left:Number;
		public var right:Number;
		public var bottom:Number;
		
		/**
		 * args can use:
			 * nothing: uses default size
			 * 4 numbers: (left, top, right, bottom)
		 * @param	... args
		 */
		public function HitBox(... args)
		{
			super();
			
			if (args.length == 0)
			{
				// interpret the box's size and location
				setDimensions(x, y, x + scaleX * 100, y + scaleY * 100);
			}
			else if (args.length == 4)
			{
				// create a new box based on passed arguments
				setDimensions(args[0], args[1], args[2], args[3]);
				
				graphics.beginFill(0x888888, 0.2);
				graphics.drawRect(0, 0, 100, 100);
				//this.visible = false;
			}
			
			//this.visible = false;
		}
		
		public function setDimensions(l:Number, t:Number, r:Number, b:Number):void
		{
			left = l;
			top = t;
			right = r;
			bottom = b;
			
			x = left;
			y = top;
			scaleX = (right - left) / 100;
			scaleY = (bottom - top) / 100;
		}
		
		public function snapDimensions():void
		{
			setDimensions
				( closest(left)
				, closest(top)
				, closest(right)
				, closest(bottom)
			);
		}
		
		private function closest (num:Number):Number
		{
			num /= Main.GRID_SIZE;
			num = Math.round(num);
			num *= Main.GRID_SIZE;
			//if (num < 0) num -= Main.GRID_SIZE - 0.001;
			//var sep:Number = num % Main.GRID_SIZE;
			//num -= sep;
			//if (sep >= Main.GRID_SIZE / 2) num += Main.GRID_SIZE;
			return num;
		}
		
		public function hitTest(x:Number, y:Number, radius:Number):Boolean
		{
			var LEFT:Boolean = false;
			var RIGHT:Boolean = false;
			var UP:Boolean = false;
			var DOWN:Boolean = false;
			
			// calculate direction
			if (x < left) LEFT = true;
			if (x > right) RIGHT = true;
			if (y < top) UP = true;
			if (y > bottom) DOWN = true
			
			// check for inside
			if (!(UP || DOWN || LEFT || RIGHT)) return true;
			
			// if radius == 0 && not inside, then hitTest failed
			if (radius == 0) return false;
			
			// calculate distance
			var dx:Number = 0;
			var dy:Number = 0;
			if (LEFT) dx = x - left;
			if (RIGHT) dx = x - right;
			if (UP) dy = y - top;
			if (DOWN) dy = y - bottom;
			
			if (dx * dx + dy * dy > radius * radius) return false
			
			return true;
		}
		
		public function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData
		{
			var c:Number;
			
			// Checks if collision is even possible
			if (x1 < left && x2 < left) return null;
			if (x1 > right && x2 > right) return null;
			if (y1 < top && y2 < top) return null;
			if (y1 > bottom && y2 > bottom) return null;
			
			// top
			if (y1 < top)
			{
				c = x1 + (top - y1) / (y2 - y1) * (x2 - x1);
				if (c >= left && c <= right)
					return HitData.hit(this, c, top);
				else
					return null;
			}
			
			// bottom
			if (y1 > bottom)
			{
				c = x1 + (bottom - y1) / (y2 - y1) * (x2 - x1);
				if (c >= left && c <= right)
					return HitData.hit(this, c, bottom);
				else
					return null;
			}
			
			// left
			if (x1 < left)
			{
				c = y1 + (left - x1) / (x2 - x1) * (y2 - y1);
				if (c >= top && c <= bottom)
					return HitData.hit(this, left, c);
				else
					return null;
			}
			
			// right
			if (x1 > right)
			{
				c = y1 + (right - x1) / (x2 - x1) * (y2 - y1);
				if (c >= top && c <= bottom)
					return HitData.hit(this, right, c);
				else
					return null;
			}
			return null;
		}
	}
}
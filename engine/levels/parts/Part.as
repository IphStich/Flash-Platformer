package iphstich.platformer.engine.levels.parts
{
	import flash.utils.getQualifiedClassName;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.entities.WalkingCharacter;
	import iphstich.platformer.engine.HitBox;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.ICollidable;
	
	public class Part extends HitBox
	{
		public var connections:Vector.<Part> = new Vector.<Part>();
		public var slope:Number = 0;
		protected var numC:int;
		
		public function Part()
		{
			super();
			
			// snap the bounds to the grid
			snapDimensions();
		}
		
		/**
		 * Checks whether or not the two parts "connect". Only one of the two parts needs to have this return 1.
		 *  0 : not really
		 *  1 : yes, absolutely
		 * @param	other
		 * @return
		 */
		public function checkConnection ( other:Part ) : int
		{
			//throw new Error( "Error. No default connection check behaviour defined for " + getQualifiedClassName(this) );
			//return -1;
			
			if (this.slope == 0)
			{
				if (other.slope == 0)
				{
					if (other.top == this.top)
					{
						if ((other.left == this.right) || (other.right == this.left))
						{
							return 1;
						}
					}
				}
				
				else if (other.slope < 0)
				{
					if (other.right == this.left)
					{
						if (other.top == this.top)
						{
							return 1;
						}
					}
					
					else if (other.bottom == this.top)
					{
						if ((other.left >= this.left) && (other.left <= this.right))
						{
							return 1;
						}
					}
				}
				
				else if (other.slope > 0)
				{
					if (other.left == this.right)
					{
						if (other.top == this.top)
						{
							return 1;
						}
					}
					
					else if (other.bottom == this.top)
					{
						if ((other.right >= this.left) && (other.right <= this.right))
						{
							return 1;
						}
					}
				}
			}
			
			else if (this.slope < 0)
			{
				if (other.left == this.right)
				{
					if (other.slope >= 0)
					{
						if (other.top == this.top)
						{
							return 1;
						}
					}
					
					else if (other.slope < 0)
					{
						if (other.bottom == this.top)
						{
							return 1;
						}
					}
				}
				
				else if (other.slope > 0)
				{
					if (other.right == this.left)
					{
						return 1;
					}
				}
			}
			
			else if (this.slope > 0)
			{
				if (other.slope > 0)
				{
					if (other.left == this.right)
					{
						if (other.top == this.bottom)
						{
							return 1;
						}
					}
				}
			}
			
			return 0;
		}
		
		public function connect (con:Part) : void
		{
			if (connections.indexOf(con) == -1)
				connections.push(con);
			
			numC = connections.length;
		}
		
		public function getNext(obj:WalkingCharacter):Part
		{
			var ret:Part = null;
			var i:uint;
			
			var x:Number = obj.px;
			var y:Number = obj.py;
			
			if ((x >= this.left) && (x <= this.right)) ret = this;
			
			var con:Part;
			for (i = 0; i < numC; ++i) {
				con = connections[i];
				if ((x >= con.left)
					&& (x <= con.right))
				{
					if (ret == null) ret = con;
					if (ret.top >= con.top) ret = con;
				}
			}
			
			if (ret == null)
				if ((x + obj.getBaseRight() >= this.left) && (x + obj.getBaseLeft() <= this.right)) ret = this;
			
			return ret;
		}
		
		public function show(other:Part):void
		{
			//if ( this.checkConnection(other) + other.checkConnection(this) >= 2 )
			if (this.checkConnection(other) || other.checkConnection(this))
			{
				this.connect(other);
				other.connect(this);
			}
		}
		
		public function getTopAt (x:Number) : Number
		{
			if (slope == 0)
			{
				return top;
			}
			
			if (slope < 0)
			{
				return bottom + (x - left) * slope;
			}
			
			if (slope > 0)
			{
				return top + (x - left) * slope;
			}
			
			return NaN;
		}
		
		public function slopeSpeed (entity:Entity) : Number
		{
			if (slope == 0)
			{
				return 1;
			}
			else
			{
				return 1 / (slope * slope / 1.5 + 1);
			}
		}
	}
}
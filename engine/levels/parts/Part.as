package iphstich.platformer.engine.levels.parts
{
	import flash.utils.getQualifiedClassName;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.entities.WalkingEntity;
	import iphstich.platformer.engine.HitBox;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.ICollidable;
	
	public class Part extends HitBox
	{
		public var connections:Vector.<Part>
		public var slope:Number;
		
		public function Part()
		{
			super();
			
			// snap the bounds to the grid
			snapDimensions();
			
			// set default properties
			connections 	= new Vector.<Part>();
		}
		
		/**
		 * Checks whether or not the two parts "connect".
		 * -1 : never
		 *  0 : not really
		 *  1 : sure, why not
		 *  2 : YES!
		 * @param	other
		 * @return
		 */
		public function checkConnection ( other:Part ) : int
		{
			throw new Error( "Error. No default connection check behaviour defined for " + getQualifiedClassName(this) );
			return -1;
		}
		
		public function connect (con:Part) : void
		{
			if (connections.indexOf(con) == -1)
				connections.push(con);
		}
		
		public function getNext(obj:WalkingEntity):Part
		{
			var ret:Part = null;
			var i:uint;
			var numC:uint = connections.length;
			
			var x:Number = obj.px;
			var y:Number = obj.py;
			
			if ((x + obj.getBaseRight() >= this.left) && (x + obj.getBaseLeft() <= this.right)) ret = this;
			
			var con:Part;
			for (i = 0; i < numC; ++i) {
				con = connections[i];
				if ((x + obj.getBaseRight() >= con.left)
					&& (obj.x + obj.getBaseLeft() <= con.right))
				{
					if (ret == null) ret = con;
					if (ret.top > con.top) ret = con;
				}
			}
			return ret;
		}
		
		public function show(other:Part):void
		{
			if ( this.checkConnection(other) + other.checkConnection(this) >= 2 )
			{
				this.connect(other);
				other.connect(this);
			}
		}
		
		public function getTopAt (x:Number) : Number
		{
			throw Error ("No top function set for " + getQualifiedClassName(this));
		}
	}
}
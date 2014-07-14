package iphstich.platformer.engine.entities
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import iphstich.platformer.engine.ICollidable;
	import Math;
	import flash.utils.getQualifiedClassName;
	import iphstich.library.CustomMath;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.HitBox;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.interactables.Interactable;
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.levels.parts.*;
	import iphstich.platformer.engine.entities.HitPoint;
	import iphstich.library.Util;
	
	public class Entity extends MovieClip implements ICollidable
	{
		// current position (pre-tick)
		//public var x:Number = 0;
		//public var y:Number = 0;
		
		// current velocity
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		// current acceleration
		public var ax:Number = 0;
		public var ay:Number = 0;
		
		// predicted position (post-tick)
		public var px:Number = 0;
		public var py:Number = 0;
		
		// capped velocity
		public var cx:Number = NaN;
		public var cy:Number = NaN;
		
		// rotation
		public var canRotate:Boolean = false;
		public var r:Number = 0; // rotation in radians
		public var pr:Number = 0; // predicted rotation
		public var vr:Number = 0; // rotation velocity
		public var ar:Number = 0; // rotational acceleration
		
		// Transformation Matrices
		public var oldTransform:Matrix = new Matrix();
		public var newTransform:Matrix = new Matrix();
		
		protected var collided:Boolean;
		protected var collisionPoints:Vector.<HitPoint>
		protected var hitCenter:HitPoint;
		
		public var level:Level;
		public var engine:Engine;
		
		public var alive:Boolean = false;
		public var hitBox:HitBox;
		public var team:int;
		
		public function Entity()
		{
			super();
			
			team 		= -1;
			hitBox 		= new HitBox( -10, -10, 10, 10);
			hitBox.canHitInternal = true;
			collisionPoints 	= new Vector.<HitPoint>();
			addChild(hitBox)
			hitCenter = new HitPoint(0, 0, this);
			collisionPoints.push(hitCenter);
			
			
			var i:int;
			var child:DisplayObject;
			for (i=numChildren-1; i>=0; --i)
			{
				child = this.getChildAt(i);
				if (child is HitPointMC) {
					removeChild(child);
					collisionPoints.push(new HitPoint(child.x, child.y, this));
				}
				//for each (var c:DisplayObject in this.children
			}
		}
		
		//-----------------------------------------------------------//
		
		public function tickThink (style:uint, delta:Number) : void
		{
			
		}
		
		public function tickMove (delta:Number):void
		{
			// Apply acceleration
			vx += ax * delta;
			vy += ay * delta;
			
			// Cap X and Y velocities
			if (!isNaN(cx))
			{
				vx = CustomMath.capBetween(vx, -cx, cx);
			}
			if (!isNaN(cy))
			{
				vy = CustomMath.capBetween(vy, -cy, cy);
			}
			
			// Calculate the 'end'
			px = x + vx * delta;
			py = y + vy * delta;
			
			
			// Rotation...
			if (canRotate)
			{
				vr += ar * delta;
				pr = r + vr * delta;
			}
		}
		
		public function tickCollide (delta:Number) : void
		{
			var hd:HitData;
			var count:int = 0;
			
			if (!alive) return;
			
			while (true)
			{
				collided = false;
				
				refreshCollisions();
				
				for each (hd in collisions) {
					collide (hd);
					if (!alive) return;
					if (collided) break;
				}
				
				if (count++ > 2) break;
				if (collided) continue;
				break;
			}
		}
		
		public function tickEnd (delta:Number) : void
		{
			// Move to predicted location
			x = px;
			y = py;
			
			// Rotation...
			if (canRotate)
			{
				r = pr;
				rotation = r / Math.PI * 180;
			}
		}
		
		protected var collisions:Vector.<HitData>;
		protected function refreshCollisions ()
		{
			refreshRotaionMatrices();
			
			var i:int;
			var p:HitPoint;
			var check:Vector.<HitData>;
			
			// clear or create vector
			if (collisions == null) collisions = new Vector.<HitData>();
			else { for (i=collisions.length; i>0; --i) collisions.pop().destroy(); }
			
			// get all collisions
			for (i=collisionPoints.length-1; i>=0; --i)
			{
				p = collisionPoints[i];
				check = p.getHitPath();
				while (check.length > 0) collisions.push( check.pop() );
			}
			
			// sort them by t
			collisions.sort(HitData.SORT_BY_T);
		}
		
		protected function refreshRotaionMatrices () : void
		{
			oldTransform.identity();
			newTransform.identity();
			
			oldTransform.rotate(r);
			newTransform.rotate(pr);
			
			oldTransform.translate(x, y);
			newTransform.translate(px, py);
		}
		
		protected function collide (data:HitData):void
		{
			throw Error("Error. No default behavior for collision defined for class " + getQualifiedClassName(this));
		}
		
		//-----------------------------------------------------------------------//
		
		public function hitTest(x:Number, y:Number, radius:Number, time:Number=-1):Boolean
		{
			return false;
			//// dead entities cannot be hit
			//if (alive == false) return false;
			//
			//if (time == -1) time = engine.time;
			//
			//return this.hitBox.hitTest(x - getX(time), y - getY(time), radius);
		}
		
		public function hitTestPath (x1:Number, y1:Number, x2:Number, y2:Number) : HitData
		{
			if (!alive) return null;
			
			// first test with current position
			var hd:HitData = hitBox.hitTestPath(x1 - x, y1 - y, x2 - x, y2 - y);
			if (hd != null) {
				hd.hit = this;
				hd.x += x;
				hd.y += y;
				return hd;
			}
			
			// if that fails, test with predicted position
			hd = hitBox.hitTestPath(x1 - px, y1 - py, x2 - px, y2 - py);
			if (hd != null) {
				hd.hit = this;
				hd.x += x;
				hd.y += y;
			}
			return hd;
		}
		
		public function isWithinRadius (x1:Number, y1:Number, r:Number) : Boolean
		{
			if (hitBox.isWithinRadius(x1 - x, y1 - y, r)) {
				return true;
			} else if (hitBox.isWithinRadius(x1 - px, y1 - py, r)) {
				return true;
			} else {
				return false;
			}
		}
		
		public function getRadialCheckPoints (fromX:Number, fromY:Number) : Vector.<Point>
		{
			var ret:Vector.<Point> = new Vector.<Point>();
			ret.push(new Point(x + (hitBox.left + hitBox.right) / 2, y + (hitBox.top + hitBox.bottom) / 2));
			return ret;
		}
		
		public function removedFromLevel (lev:Level) : void
		{
			if (level == lev)
			{
				level = null;
				this.destroy();
			}
		}
		
		public function spawn (x:Number, y:Number, time:Number, lev:Level) : void
		{
			alive 	= true;
			level 	= lev;
			
			// add to level and set defaults
			this.level.addEntity(this);
			this.x = x;
			this.y = y;
			//this.setP(
				//{ kt: time
				//, kx: x
				//, ky: y
			//});
		}
		
		public function addedToLevel (lev:Level) : void
		{
			level = lev;
			engine = level.engine;
		}
		
		public function applyImpulse (x:Number, y:Number) : void
		{
			vx = x;
			vy = y;
		}
		
		public function death () : void
		{
			alive = false;
			this.level.removeEntity(this);
		}
		
		public function clear () : void
		{
			this.destroy();
		}
		
		public function destroy () : void
		{
			// garbage collection
			if (level != null) level.removeEntity(this);
			level = null;
			removeChild(hitBox);
			hitBox = null;
			while (collisionPoints.length > 0) collisionPoints.pop();
		}
		
		override public function toString():String
		{
			return super.toString() + Util.getMemoryLocation(this);
		}
	}
}
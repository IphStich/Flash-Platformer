package iphstich.platformer.engine.entities
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	import Math;
	
	import iphstich.library.CustomMath;
	import iphstich.library.Util;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.HitBox;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.ICollidable;
	import iphstich.platformer.engine.levels.interactables.Interactable;
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.levels.misc.Trigger;
	import iphstich.platformer.engine.levels.parts.*;
	import iphstich.platformer.engine.entities.HitPoint;
	
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
		
		public var alive:Boolean = false;
		public var hitBox:HitBox;
		public var team:int;
		
		protected var DestroyOnClear:Boolean = true;
		
		public function Entity()
		{
			super();
			
			stop();
			
			team 		= -1;
			hitBox 		= new HitBox( -10, -10, 10, 10);
			hitBox.canHitInternal = true;
			collisionPoints 	= new Vector.<HitPoint>();
			addChildAt(hitBox, 0)
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
				
				if (count++ > 10) { trace("saved from crash"); break; }
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
			
			if (level == null) trace("WARNING: NO Level", getQualifiedClassName(this))
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
			var trigger:Trigger = data.hit as Trigger;
			if (trigger != null) if (trigger.canBeActivated)
			{
				level.activateTrigger(trigger, this);
			}
		}
		
		protected function otherCollide (label:String, data:HitData) : void
		{
			throw Error("Error. No default behavior for other collision defined for class " + getQualifiedClassName(this));
		}
		
		//-----------------------------------------------------------------------//
		
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
				//this.clear();
			}
		}
		
		public function spawn (x:Number, y:Number, lev:Level) : void
		{
			alive 	= true;
			vx = 0;
			ax = 0;
			vy = 0;
			ay = 0;
			r = 0;
			ar = 0;
			vr = 0;
			px = x;
			py = y;
			
			
			if (level != lev)
			{
				// remove from old level
				if (level != null) level.removeEntity(this);
				
				// add to new level
				level = lev;
				level.addEntity(this);
			}
			
			// add to level and set defaults
			this.x = x;
			this.y = y;
		}
		
		public function addedToLevel (lev:Level) : void
		{
			level = lev;
		}
		
		public function applyImpulse (x:Number, y:Number) : void
		{
			vx = x;
			vy = y;
		}
		
		public function death () : void
		{
			alive = false;
			clear();
		}
		
		public function clear () : void
		{
			if (DestroyOnClear) this.destroy();
			else if (level != null) level.removeEntity(this);
		}
		
		public function destroy () : void
		{
			stop();
			if (level != null) level.removeEntity(this);
			// garbage collection
			removeChild(hitBox);
			hitBox = null;
			while (collisionPoints.length > 0) collisionPoints.pop();
		}
		
		override public function toString():String
		{
			return super.toString() + Util.getMemoryLocation(this);
		}
		
		public function animatedCollision (target:MovieClip, label:String) : void
		{
			var list:Vector.<HitPointAnimated> = new Vector.<HitPointAnimated>();
			
			var hpa:HitPointAnimated;
			var a:HitPointAnimated, b:HitPointAnimated;
			var results:Vector.<HitData> = new Vector.<HitData>(); //, check:Vector.<HitData>
			var hd:HitData;
			
			// get the collision points we should use
			var i:int;
			for (i=target.numChildren-1; i>=0; --i)
			{
				hpa = target.getChildAt(i) as HitPointAnimated;
				if (hpa != null) if (hpa.label == label)
				{
					list.push(hpa);
				}
			}
			
			//if (list.length <= 1) throw Error("Unable to find 2 or more appropriate collision points")
			
			list.sort(HitPointAnimated.SORT_BY_INDEX);
			
			for each (a in list) a.calculatePosition();
			
			// perform the actual collision check
			var j:int = list.length;
			for (i=0; i<=j-2; ++i)
			{
				a = list[i];
				b = list[i+1];
				
				level.testHitPath (results, a.cx, a.cy, b.cx, b.cy);
			}
			
			// and check results for deuplicates and references to self
			for (i=results.length-1; i>=0; --i)
			{
				hd = results[i];
				
				if (hd.hit == this) // <-- self check
				{
					results.splice(i, 1);
					hd.destroy();
					continue;
				}
				
				for (j=i-1; j>=0; --j) // <-- duplicate check
				{
					if (results[j].hit == hd.hit)
					{
						results.splice(i, 1);
						hd.destroy();
						break;
					}
				}
			}
			
			// perform collision logic
			for each (hd in results)
				otherCollide(label, hd);
			
			// discard the hit data results
			while ((hd = results.pop()) != null) hd.destroy();
		}
		
		public function hitBy (other:*) : void
		{
			
		}
	}
}
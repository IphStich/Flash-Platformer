package iphstich.platformer.engine.entities
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
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
	
	public class Entity extends MovieClip
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
			collisionPoints 	= new Vector.<HitPoint>();
			addChild(hitBox)
			hitCenter = new HitPoint(0, 0, this);
			collisionPoints.push(hitCenter);
		}
		
		//-----------------------------------------------------------//
		
		public function tickThink (style:uint, delta:Number) : void
		{
			
		}
		
		public function tickMove (delta:Number):void
		{
			var p:HitPoint;
			var obj:HitData;
			var i:uint, j:uint;
			var hit:Vector.<HitData>;
			
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
			
			px = x + vx * delta;
			py = y + vy * delta;
			
			// Don't do collisions?
			if (collisionPoints == null) return;
			if (collisionPoints.length == 0) return;
			
			// Check for collisions
			//var preCheck:Number = kt;
			//var p:HitPoint;
			collided = false;
			for (i=0; i<collisionPoints.length; ++i) {
				p = collisionPoints[i];
			//for each (var p:HitPoint in collisionPoints) {
				hit = p.getHitPath();
				for (j = 0; j < hit.length; ++j) {
					obj = hit[j];
					if (obj.hit is Interactable) continue;
					if (obj.hit == Level.OUTSIDE_LEVEL) {
						//trace("auto desu"); //, this, engine.time, vectorsToString()
						//this.death();
						//return;
					}
					if (obj.hit != this) {
						collide(p, obj);
						if (collided) return;
					}
					if (alive == false) return;
				}
			}
			
			
			//if (style == Engine.TICK_CALCULATED)
			//{
				//var i:int, j:int
				//var f:Function = null;
				//
				//// cap X and Y velocities
				//if (!isNaN(cx)) {
					//if (engine.time >= cxt) {
						////trace("cap X")
						//f = cxf;
						//setCourse
							//( { cx: NaN, vx: cx, ax: 0 }
							//, cxt
							//);
						//if (f != null) {
							//f(cxt);
						//}
					//}
				//}
				//if (!isNaN(cy)) {
					//if (engine.time >= cyt) {
						////trace("cap Y", getValue("vy", cyt), cy)
						//f = cyf;
						//setCourse
							//( { cy: NaN, vy: cy, ay: 0 }
							//, cyt
							//);
						//if (f != null) {
							//f(cyt)
						//}
					//}
				//}
				//
				//// Calculate the position
				//x = getX(engine.time);
				//y = getY(engine.time);
				//
				//// Don't do collisions?
				//if (collisionPoints == null) return;
				//if (collisionPoints.length == 0) return;
				//
				//// Check for collisions
				//var preCheck:Number = kt;
				//var p:HitPoint;
				//for (i=0; i<collisionPoints.length; ++i) {
					//p = collisionPoints[i];
				////for each (var p:HitPoint in collisionPoints) {
					//var hit:Vector.<HitData> = p.getHitPath();
					//for (j = 0; j < hit.length; ++j) {
						//var obj:HitData = hit[j];
						//if (obj.hit is Interactable) continue;
						//if (obj.hit == Level.OUTSIDE_LEVEL) {
							//trace("auto desu", this, engine.time, vectorsToString());
							//this.death();
							//return;
						//}
						//if (obj.hit != this) {
							//collide(p, obj);
						//}
						//if (alive == false || kt != preCheck) return;
					//}
				//}
			//}
			//else
			//{
				//// Apply acceleration
				//vx += ax * delta;
				//vy += ay * delta;
				//
				//// Cap X and Y velocities
				//if (!isNaN(cx))
				//{
					//vx = CustomMath.capBetween(vx, -cx, cx);
				//}
				//if (!isNaN(cy))
				//{
					//vy = CustomMath.capBetween(vy, -cy, cy);
				//}
				//
				//kx = x + vx * delta;
				//ky = y + vy * delta;
				//
				//// Don't do collisions?
				//if (collisionPoints == null) return;
				//if (collisionPoints.length == 0) return;
				//
				//// Check for collisions
				////var preCheck:Number = kt;
				////var p:HitPoint;
				//for (i=0; i<collisionPoints.length; ++i) {
					//p = collisionPoints[i];
				////for each (var p:HitPoint in collisionPoints) {
					//hit = p.getHitPath();
					//for (j = 0; j < hit.length; ++j) {
						//obj = hit[j];
						//if (obj.hit is Interactable) continue;
						//if (obj.hit == Level.OUTSIDE_LEVEL) {
							//trace("auto desu", this, engine.time, vectorsToString());
							//this.death();
							//return;
						//}
						//if (obj.hit != this) {
							//collide(p, obj);
						//}
						//if (alive == false || kt != preCheck) return;
					//}
				//}
				//
				//// If no blocking collisions: move
				//x = kx;
				//y = ky;
			//}
		}
		
		protected function collide(point:HitPoint, data:HitData):void
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
		
		public function death () : void
		{
			alive = false;
			this.level.removeEntity(this);
			this.destroy();
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
			
			for each (var p:HitPoint in collisionPoints)
				p.engine = level.engine;
		}
		
		public function applyImpulse (x:Number, y:Number, time:Number) : void
		{
			vx = x;
			vy = y;
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
	}
}
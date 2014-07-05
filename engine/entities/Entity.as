package iphstich.platformer.engine.entities
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
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
		protected var vx:Number = 0; // velocity x
		protected var vy:Number = 0; // velocity y
		protected var kx:Number = 0; // start X
		protected var ky:Number = 0; // start Y
		public var kt:Number = 0; // start time
		protected var ax:Number = 0; // acceleration X
		protected var ay:Number = 0; // acceleration Y
		protected var cx:Number = NaN; // cap X velocity
		protected var cy:Number = NaN; // cap Y velocity
		protected var cxt:Number = NaN; // cap X estimated time
		protected var cyt:Number = NaN; // cap Y estimated time
		protected var cxf:Function = null; // cap X function
		protected var cyf:Function = null; // cpa Y function
		
		protected var collisionPoints:Vector.<HitPoint>
		protected var hitCenter:HitPoint;
		
		public var level:Level;
		public var engine:Engine;
		
		public var alive:Boolean = true;
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
		
		public function tickMove (style:uint, delta:Number):void
		{
			var i:int, j:int
			var f:Function = null;
			
			// cap X and Y velocities
			if (!isNaN(cx)) {
				if (engine.time >= cxt) {
					//trace("cap X")
					f = cxf;
					setCourse
						( { cx: NaN, vx: cx, ax: 0 }
						, cxt
						);
					if (f != null) {
						f(cxt);
					}
				}
			}
			if (!isNaN(cy)) {
				if (engine.time >= cyt) {
					//trace("cap Y", getValue("vy", cyt), cy)
					f = cyf;
					setCourse
						( { cy: NaN, vy: cy, ay: 0 }
						, cyt
						);
					if (f != null) {
						f(cyt)
					}
				}
			}
			
			// Calculate the position
			x = getX(engine.time);
			y = getY(engine.time);
			
			// Don't do collisions?
			if (collisionPoints == null) return;
			if (collisionPoints.length == 0) return;
			
			// Check for collisions
			var preCheck:Number = kt;
			var p:HitPoint;
			for (i=0; i<collisionPoints.length; ++i) {
				p = collisionPoints[i];
			//for each (var p:HitPoint in collisionPoints) {
				var hit:Vector.<HitData> = p.getHitPath();
				for (j = 0; j < hit.length; ++j) {
					var obj:HitData = hit[j];
					if (obj.hit is Interactable) continue;
					if (obj.hit == Level.OUTSIDE_LEVEL) {
						trace("auto desu", this, engine.time, vectorsToString());
						this.death();
						return;
					}
					if (obj.hit != this) {
						collide(p, obj);
					}
					if (alive == false || kt != preCheck) return;
				}
			}
		}
		
		public function tickThink (style:uint, delta:Number) : void
		{
			
		}
		
		protected function collide(point:HitPoint, data:HitData):void
		{
			throw Error("Error. No default behavior for collision defined for class " + getQualifiedClassName(this));
		}
		
		public function setP(props:Object):void
		{
			var allowedList:Array = new Array("cy", "cx", "cxf", "cyf", "cxt", "cyt", "surface");
			for (var p:* in props)
			{
				if (isNaN(props[p])) if (allowedList.indexOf(p) == -1) throw new Error(p + " = NaN");
				//if (p == "cx" && props[p] == 0) trace(new Error().getStackTrace());
				this[p] = props[p]
			}
		}
		
		public function setCourse(props:Object, time:Number):void
		{
			// if new x or y velocities were passed, and no new caps, clear caps
			if (props.vx != undefined && props.cx == undefined) props.cxt = NaN;
			if (props.vy != undefined && props.cy == undefined) props.cyt = NaN;
			
			// if new x or y velocities, and no new accelerations, clear accelerations
			//if (props.vx != undefined && props.ax == undefined) props.ax = 0;
			//if (props.vy != undefined && props.ay == undefined) props.ax = 0;
			
			//this.alpha = (this.alpha == 1) ? 0.25 : 1;
			if (props.kx == undefined) props.kx = getX(time);
			if (props.ky == undefined) props.ky = getY(time);
			if (props.vx == undefined) props.vx = getVX(time);
			if (props.vy == undefined) props.vy = getVY(time);
			props.kt = time;
			
			if (time < 1 && engine.time > 2) throw new Error("time = " + time + " (< 1)\n" + vectorsToString());
			if (kx < this.level.left) throw new Error("X outside" + vectorsToString());
			if (ky < this.level.top) throw new Error("Y outside" + vectorsToString());
			
			//this.kx = kx; this.ky = ky; this.vx = vx; this.vy = vy; this.kt = kt;
			setP(props);
			
			// update cap times
			if (!isNaN(cx)) cxt = getTimeVX(cx);
			if (!isNaN(cy)) cyt = getTimeVY(cy);
			//if (!isNaN(cx) && cxt < time && !isNaN(cxt)) throw new Error("time = " + cxt + " < " + time + "\n" + vectorsToString());
			
			// if new caps were passed, and not new cap functions, clear cap funcitons
			if (props.cx != undefined && props.cxf == undefined) cxf = null;
			if (props.cy != undefined && props.cyf == undefined) cyf = null;
		}
		
		//-----------------------------------------------------------------------//
		
		public function getX (time:Number) : Number
		{
			if (time < kt) time = kt;
			var dt:Number = time - kt;
			return kx + vx * dt + ax * dt * dt / 2;
		}
		public function getY (time:Number) : Number
		{
			if (time < kt) time = kt;
			var dt:Number = time - kt;
			return ky + vy * dt + ay * dt * dt / 2;
		}
		public function getVX (time:Number) : Number
		{
			if (time < kt) time = kt;
			return vx + ax * (time - kt);
		}
		public function getVY (time:Number) : Number
		{
			if (time < kt) time = kt;
			return vy + ay * (time - kt);
		}
		public function getAX (time:Number) : Number
		{
			if (time < kt) time = kt;
			return ax;
		}
		public function getAY (time:Number) : Number
		{
			if (time < kt) time = kt;
			return ay;
		}
		
		public function getTimeVX (value:Number) : Number
		{
			return (value - vx) / ax + kt;
		}
		public function getTimeVY (value:Number) : Number
		{
			return (value - vy) / ay + kt;
		}
		public function getTimeX (value:Number) : Number
		{
			return CustomMath.solveQuadratic(ax / 2, vx, -(value - kx)) + kt;
		}
		public function getTimeY (value:Number) : Number
		{
			return CustomMath.solveQuadratic(ay / 2, vy, -(value - ky)) + kt;
		}
		public function vectorsToString () : String
		{
			var props:Array = new Array("kx", "ky", "vx", "vy", "ax", "ay", "kt", "cx", "cy");
			var ret:String = "";
			ret += "{" + props[0] + ": " + this[props[0]];
			for (var i:uint = 1; i<props.length; ++i)
			{
				ret += ", " + props[i] + ": " + this[props[i]];
			}
			ret += "}";
			return ret;
		}
		
		//-----------------------------------------------------------------------//
		
		public function hitTest(x:Number, y:Number, radius:Number, time:Number=-1):Boolean
		{
			// dead entities cannot be hit
			if (alive == false) return false;
			
			if (time == -1) time = engine.time;
			
			return this.hitBox.hitTest(x - getX(time), y - getY(time), radius);
		}
		
		public function death () : void
		{
			alive = false;
			this.level.removeEntity(this);
			this.destroy();
		}
		
		public function spawn (x:Number, y:Number, time:Number, lev:Level) : void
		{
			level = lev;
			
			// add to level and set defaults
			this.level.addEntity(this);
			this.setP(
				{ kt: time
				, kx: x
				, ky: y
			});
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
			this.setCourse({vx: x, vy: y}, time);
		}
		
		public function clear () : void
		{
			this.destroy();
		}
		
		public function destroy () : void
		{
			// garbage collection
			if (level != null) level.removeEntity(this);
			removeChild(hitBox);
			hitBox = null;
			while (collisionPoints.length > 0) collisionPoints.pop();
		}
	}
}
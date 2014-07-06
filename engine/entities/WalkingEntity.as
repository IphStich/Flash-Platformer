package iphstich.platformer.engine.entities
{
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.entities.Character;
	import iphstich.platformer.engine.HitData;
	//import iphstich.mcs.engine.entities.Entity;
	import iphstich.platformer.engine.entities.HitPoint;
	import iphstich.platformer.engine.levels.parts.*;
	import iphstich.platformer.engine.levels.Level;
	
	public class WalkingEntity extends Character
	{
		public var surface:Part;
		protected var leftPoint:HitPoint;
		protected var rightPoint:HitPoint;
		protected var leftBase:HitPoint;
		protected var rightBase:HitPoint;
		protected var headLeft:HitPoint;
		protected var headRight:HitPoint;
		protected var upperLeft:HitPoint;
		protected var upperRight:HitPoint;
		protected var heading:Number = 0;
		protected var groundPoints:Vector.<HitPoint>;
		protected var airPoints:Vector.<HitPoint>;
		
		public function WalkingEntity()
		{
			super();
			
			leftBase = new HitPoint(10, 0, this);
			rightBase = new HitPoint( 10, 0, this);
			leftPoint = new HitPoint( -20, -15, this);
			rightPoint = new HitPoint( 20, -15, this);
			headLeft = new HitPoint(0, 0, this);
			headRight = new HitPoint(0, 0, this);
			upperLeft = new HitPoint(0, 0, this);
			upperRight = new HitPoint(0, 0, this);
			//collisionPoints.push(leftBase, rightBase, leftPoint, rightPoint);
			//collisionPoints.splice(collisionPoints.indexOf(hitCenter), 1);
			collisionPoints = null;
			hitCenter = null;
			groundPoints = new Vector.<HitPoint>();
			groundPoints.push(leftBase, rightBase, leftPoint, rightPoint);
			airPoints = new Vector.<HitPoint>();
			airPoints.push(leftBase, rightBase, leftPoint, rightPoint, headLeft, headRight, upperLeft, upperRight);
		}
		
		override public function addedToLevel (lev:Level) : void
		{
			level = lev;
			engine = level.engine;
			
			var p:HitPoint;
			for each (p in airPoints)
				p.engine = level.engine;
			for each (p in groundPoints)
				p.engine = level.engine;
		}
		
		private var hasFlyingHitPoints : Boolean = false;
		protected function addFlyingHitPoints() : void
		{
			collisionPoints = airPoints;
			//if (hasFlyingHitPoints) return;
			//collisionPoints.push ( headLeft, headRight, upperLeft, upperRight );
			//hasFlyingHitPoints = true;
		}
		
		protected function removeFlyingHitPoints() : void
		{
			collisionPoints = groundPoints;
			//var i:int;
			//if (!hasFlyingHitPoints) return;
			//var removeList:Array = new Array (headLeft, headRight, upperLeft, upperRight);
			//i = removeList.length - 1;
			//for (i = i; i>=0; --i)
			//{
				//collisionPoints.splice(collisionPoints.indexOf(removeList[i]), 1);
			//}
			//hasFlyingHitPoints = false;
		}
		
		override public function tickMove (style:uint, delta:Number):void
		{
			super.tickMove (style, delta);
			
			// If on a ground
			if (surface != null)
			{
				var ns:Part = this.surface.getNext(this)
				var side:Number;
				if (ns == null) {
					// calculate when they hit the edge of the platform
					side = (getX(engine.time) <= surface.left) ? surface.left : surface.right;
					if (side == surface.left) side -= this.getBaseRight();
					if (side == surface.right) side -= this.getBaseLeft();
					var t:Number = getTimeX(side);
					// perform the hit edge
					hitEdge ( side, t );
				} else if (ns != surface) {
					//side = (getVX(Engine.time) < 0) ? ns.right : ns.left;
					//this.setCourse({kx: side }, getTimeX(side))
					this.surface = ns;
				}
			}
		}
		
		override protected function collide(point:HitPoint, data:HitData):void
		{
			var target:DisplayObject = data.hit;
			if (target == surface) return;
			if (surface != null) if (surface.connections.indexOf(target) >= 0) return;
			
			if (target is Part) {
				if ((point == leftPoint && !(target is RampL)) || point == upperLeft)
				{
					this.hitWall("left", data);
				}
				else if ((point == rightPoint && !(target is RampR)) || point == upperRight)
				{
					this.hitWall("right", data);
				}
				else if ((point==hitCenter || point==rightBase || point==leftBase) && (true)) { //getVY(data.time) >= 0
					if ((point==leftBase) && (target is RampL)) return;
					if ((point==rightBase) && (target is RampR)) return;
					land(data);
				}
				else if ((point == headLeft || point == headRight))
				{
					this.hitHead(data);
				}
			}
		}
		
		override public function getY (time:Number) : Number
		{
			if (surface == null) return super.getY(time);
			
			if (surface is Block) {
				return surface.top;
			} else if (surface is RampR) {
				return surface.bottom + (getX(time) - surface.left) * (surface as RampR).slope
			} else if (surface is RampL) {
				return surface.top + (getX(time) - surface.left) * (surface as RampL).slope
			}
			trace("returning NaN: watch out!");
			return NaN;
		}
		
		protected function hitEdge (side:Number, time:Number) : void
		{
			throw Error("Error. No default behavior for edge hitting defined for class " + getQualifiedClassName(this))
		}
		
		protected function hitWall (direction:String, data:HitData) : void
		{
			//throw Error("Error. No default behavior for wall hitting defined for class " + getQualifiedClassName(this))
			var wall:Part = data.hit as Part;
			if (direction == "left") {
				this.setCourse( { vx: 0, ax: 0, cx: NaN, kx: wall.right - hitBox.left + 1.001 }, data.time );
			} else if (direction == "right") {
				this.setCourse( { vx: 0, ax: 0, cx: NaN, kx: wall.left - hitBox.right - 1.001 }, data.time );
			}
			this.heading = 0;
		}
		
		protected function hitHead (data:HitData) : void
		{
			this.setCourse(
				{ vy: 0
				, ky: 1 + getHeight() + (data.hit as Part).bottom
			}, data.time);
		}
		
		protected function land (data:HitData) : void
		{
			setCourse( { surface: (data.hit as Part), vy: 0, cy: NaN, ay: 0 }, data.time);
			ky = getY(data.time);
			y = ky;
		}
		
		override public function spawn (x:Number, y:Number, time:Number, lev:Level) : void
		{
			super.spawn(x, y, time, lev);
			
			// check for ground
			this.surface = null;
			var ground:Vector.<HitData> = new Vector.<HitData>();
			this.level.testHit(ground, x, y, 0, -1);
			for each (var h:HitData in ground) {
				if (h.hit is Part) {
					this.surface = h.hit as Part;
					break;
				}
			}
			
			if (this.surface == null) this.fall(time);
			else removeFlyingHitPoints();
		}
		
		public function fall(time:Number):void
		{
			addFlyingHitPoints();
			setCourse( { vy: 0, ay: GRAVITY, cy: JUMP_VELOCITY }, time );
			surface = null;
		}
		
		public function setSize (width:Number, height:Number) : void
		{
			// calculate half width & height
			var hWidth:Number = width / 2;
			var hHeight:Number = height / 2
			
			// adjust lower points
			leftBase.x = -hWidth * 1/4;
			rightBase.x = hWidth * 1/4;
			leftPoint.x = -hWidth;
			leftPoint.y = -height * 1/4;
			rightPoint.x = hWidth;
			rightPoint.y = -height * 1/4;
			
			// adjust upper points
			headLeft.x = -hWidth * 1/4;
			headLeft.y = -height;
			headRight.x = hWidth * 1/4;
			headRight.y = -height;
			upperLeft.x = -hWidth;
			upperLeft.y = -height * 3/4;
			upperRight.x = hWidth;
			upperRight.y = -height * 3/4;
			
			// adjust hit box
			hitBox.setDimensions
				( -hWidth
				, -height
				, hWidth
				, 0
			);
		}
		
		override public function applyImpulse (x:Number, y:Number, time:Number) : void
		{
			super.applyImpulse(x, y, time);
		}
		
		public function getBaseLeft () : Number
		{
			return leftBase.x;
		}
		public function getBaseRight () : Number
		{
			return rightBase.x;
		}
		
		public function getHeight () : Number
		{
			return -headLeft.y;
		}
		
		override public function setCourse(props:Object, time:Number):void
		{
			// check if this entity is walking on a surface
			var hasSurf:Boolean = (surface != null);
			
			super.setCourse(props, time);
			
			// remove from surface if on one
			if (surface != null && vy < 0) {
				surface = null;
				ky -= 2;
			}
			
			// if -was- walking on surface, and now isn't
			if (hasSurf && (surface == null) ) {
				addFlyingHitPoints();
			}
			// if -wasn't- walking on surface, and now is
			if (!hasSurf && (surface != null) ) {
				removeFlyingHitPoints();
			}
		}
	}
}
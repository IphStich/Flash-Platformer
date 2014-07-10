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
	import flash.utils.getTimer;
	
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
			groundPoints.push(leftPoint, rightPoint, leftBase, rightBase);
			airPoints = new Vector.<HitPoint>();
			airPoints.push(headLeft, headRight, leftBase, rightBase, leftPoint, rightPoint, upperLeft, upperRight);
		}
		
		private var hasFlyingHitPoints : Boolean = false;
		protected function addFlyingHitPoints() : void
		{
			collisionPoints = airPoints;
		}
		
		protected function removeFlyingHitPoints() : void
		{
			collisionPoints = groundPoints;
		}
		
		override public function tickMove (delta:Number):void
		{
			super.tickMove (delta);
			
			// If on a ground
			if (surface != null)
			{
				var ns:Part = this.surface.getNext(this)
				var side:Number;
				if (ns == null) {
					// calculate when they hit the edge of the platform
					//side = (getX(engine.time) <= surface.left) ? surface.left : surface.right;
					side = (px <= surface.left) ? surface.left : surface.right;
					if (side == surface.left) side -= this.getBaseRight();
					if (side == surface.right) side -= this.getBaseLeft();
					var t:Number = 0//getTimeX(side);
					// perform the hit edge
					hitEdge ( side, t );
				} else if (ns != surface) {
					//side = (getVX(Engine.time) < 0) ? ns.right : ns.left;
					//this.setCourse({kx: side }, getTimeX(side))
					this.surface = ns;
				}
			}
			
			if (surface != null)
			{
				py = surface.getTopAt (px);
			}
		}
		
		override protected function collide (data:HitData) : void
		{
			var target:DisplayObject = data.hit;
			var point:HitPoint = data.point;
			
			// if target is surface, do nothing
			if (target == surface) return;
			
			// if target is connected to surface, do nothing
			if (surface != null) if (surface.connections.indexOf(target) >= 0) return;
			
			if (target is Part) {
				if (data.type == HitData.TYPE_SURFACE)
				{
					if ((point==leftBase) && (target is RampL)) return;
					if ((point==rightBase) && (target is RampR)) return;
					
					if (point==hitCenter || point==rightBase || point==leftBase)
						land(data);
					
					// force off the edge of platforms if not 'clean'
					if (point == leftPoint)
						hitWall(-1, data);
					if (point == rightPoint)
						hitWall(1, data);
				}
				else if (point == leftPoint  || point == upperLeft)
				{
					this.hitWall(-1, data);
				}
				else if (point == rightPoint  || point == upperRight)
				{
					this.hitWall(1, data);
				}
				else if (point == headLeft || point == headRight)
				{
					this.hitHead(data);
				}
			}
		}
		
		protected function hitEdge (side:Number, time:Number) : void
		{
			fall();
		}
		
		protected function hitWall (direction:int, data:HitData) : void
		{
			var wall:Part = data.hit as Part;
			
			if (wall is RampL && direction == -1) return;
			if (wall is RampR && direction == 1) return;
			
			collided = true;
			
			if (direction == -1) {
				vx = 0;
				px = wall.right - hitBox.left + 0.1;
			} else if (direction == 1) {
				vx = 0;
				px = wall.left - hitBox.right - 0.1;
			}
			this.heading = direction;
		}
		
		protected function hitHead (data:HitData) : void
		{
			collided = true;
			
			fall();
			py = 0.001 + getHeight() + data.y;
		}
		
		protected function land (data:HitData) : void
		{
			collided = true;
			
			removeFlyingHitPoints();
			surface = data.hit as Part;
			vy = 0;
			ay = 0;
			cy = NaN;
			py = surface.getTopAt(px);
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
		
		public function fall(time:Number=0):void
		{
			addFlyingHitPoints();
			vy = 0;
			ay = GRAVITY;
			cy = JUMP_VELOCITY;
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
	}
}
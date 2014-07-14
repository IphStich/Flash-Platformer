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
		
		protected var topLeft:HitPoint;
		protected var topRight:HitPoint;
		protected var lowerLeft:HitPoint;
		protected var lowerRight:HitPoint;
		protected var baseLeft:HitPoint;
		protected var baseRight:HitPoint;
		
		public function WalkingEntity()
		{
			super();
			
			topLeft 	= new HitPoint(-1, -1, this);
			topRight 	= new HitPoint(1, -1, this);
			lowerLeft 	= new HitPoint(-1, 0, this);
			lowerRight 	= new HitPoint(1, 0, this);
			baseLeft 	= new HitPoint(-1, 1, this);
			baseRight 	= new HitPoint(1, 1, this);
			
			collisionPoints.pop();
			hitCenter = null;
			collisionPoints.push(topLeft, topRight, lowerLeft, lowerRight, baseLeft, baseRight);
		}
		
		protected function gotoAirMode () : void
		{
			surface = null;
		}
		
		protected function gotoSurfaceMode (inSurface:Part) : void
		{
			surface = inSurface
		}
		
		override public function tickMove (delta:Number):void
		{
			super.tickMove (delta);
			
			// If on a ground
			if (surface != null)
			{
				px = x + vx * delta * surface.slopeSpeed(this);
				
				// check for new surface (ns)
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
			
			if (target is Part)
			{
				var tPart = target as Part;
				
				// landing
				if (point == baseLeft || point == baseRight)
				{
					land(data);
					return;
				}
				
				// if not 'landing', and is a platform, do nothing
				if (target is Platform) return;
				
				// force off the edge of platforms if not 'clean'
				if (data.type == HitData.TYPE_SURFACE)
				{
					if (point == lowerLeft) {
						hitWall(-1, data);
						return;
					}
					if (point == lowerRight) {
						hitWall(1, data);
						return;
					}
				}
				
				// hitting a wall
				if (data.type == HitData.TYPE_LEFT)
				{
					hitWall(1, data);
					return;
				}
				if (data.type == HitData.TYPE_RIGHT)
				{
					hitWall(-1, data);
					return;
				}
				
				// hitting a roof
				if (data.type == HitData.TYPE_BOTTOM)
				{
					hitHead(data);
					return;
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
			
			gotoSurfaceMode(data.hit as Part);
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
			else gotoSurfaceMode(surface);
		}
		
		public function fall(time:Number=0):void
		{
			gotoAirMode();
			vy = 0;
			ay = GRAVITY;
			cy = JUMP_VELOCITY;
		}
		
		public function setSize (width:Number, height:Number) : void
		{
			// calculate half width & height
			var h_width:Number = width / 2;
			var h_height:Number = height / 2
			
			topLeft.x = -h_width;
			topLeft.y = -height;
			topRight.x = h_width;
			topRight.y = -height;
			
			lowerLeft.x = -h_width;
			lowerLeft.y = -height / 4;
			lowerRight.x = h_width;
			lowerRight.y = -height / 4;
			
			baseLeft.x = -h_width / 4;
			baseLeft.y = 0;
			baseRight.x = h_width / 4;
			baseRight.y = 0;
			
			// adjust hit box
			hitBox.setDimensions
				( -h_width
				, -height
				, h_width
				, 0
			);
		}
		
		override public function applyImpulse (x:Number, y:Number) : void
		{
			super.applyImpulse(x, y);
			
			if (vy < 0 && surface != null) gotoAirMode();
		}
		
		public function getBaseLeft () : Number
		{
			return baseLeft.x;
		}
		public function getBaseRight () : Number
		{
			return baseRight.x;
		}
		
		public function getHeight () : Number
		{
			return -topLeft.y;
		}
	}
}
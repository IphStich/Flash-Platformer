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
		
		protected var targetSpeed:Number = 0;
		
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
			ay = GRAVITY;
			cy = JUMP_VELOCITY;
			surface = null;
		}
		
		protected function gotoSurfaceMode (inSurface:Part) : void
		{
			ay = 0;
			cy = NaN;
			surface = inSurface
		}
		
		override public function tickThink (style:uint, delta:Number) : void 
		{
			if (HORIZ_ACC != 0)
			{
				// calculate acceleration potential
				ax = HORIZ_ACC;
				if (surface == null) ax = HORIZ_ACC_AIR;
				if (surface == null && targetSpeed == 0) ax = HORIZ_ACC_FEATHER;
				if (vx == targetSpeed) ax = 0;
				
				// adjust acceleration if too close to target speed
				if (Math.abs(vx - targetSpeed) < ax * delta) ax = Math.abs(vx - targetSpeed) / delta;
				
				// adjust acceleration based on speed
				ax *= (vx - targetSpeed < 0) ? 1 : -1;
			}
			else
			{
				vx = targetSpeed;
			}
			
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
				
				if (ns == null)
				{
					var side:Number = (px <= surface.left)
						? surface.left - getBaseRight()
						: surface.right - getBaseLeft();
					hitEdge ( side );
				}
				else if (ns != surface)
				{
					this.surface = ns;
				}
			}
			
			if (surface != null)
			{
				py = surface.getTopAt (px);
			}
		}
		
		override protected function refreshCollisions ()
		{
			super.refreshCollisions();
			
			var check:Vector.<HitData>;
			
			check = topLeft.getHitPathBetweenPoints(topRight);
			while (check.length > 0) collisions.push(check.pop());
			
			check = lowerLeft.getHitPathBetweenPoints(topLeft);
			while (check.length > 0) collisions.push(check.pop());
			
			check = lowerRight.getHitPathBetweenPoints(topRight);
			while (check.length > 0) collisions.push(check.pop());
			
			check = lowerLeft.getHitPathBetweenPoints(lowerRight);
			var hd:HitData;
			while (check.length > 0)
			{
				hd = check.pop();
				if (hd.x > px) hd.point = lowerRight;
				collisions.push(hd);
			}
			
			collisions.sort(HitData.SORT_BY_T);
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
				
				// force off the edge of Parts if not 'clean'
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
		
		protected function hitEdge (side:Number) : void
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
		
		override public function spawn (x:Number, y:Number, lev:Level) : void
		{
			super.spawn(x, y, lev);
			
			this.surface = null;
			
			// check for ground
			var ground:Vector.<HitData> = new Vector.<HitData>();
			this.level.testHitPath(ground, x, y - getHeight(), x, y + 10);
			for each (var h:HitData in ground) {
				if (h.hit is Part) {
					this.surface = h.hit as Part;
					break;
				}
			}
			
			if (this.surface == null) this.fall();
			else gotoSurfaceMode(surface);
		}
		
		public function fall():void
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
		
		protected function doJump () : void
		{
			gotoAirMode();
			vy = -JUMP_VELOCITY;
			ay = GRAVITY;
			cy = JUMP_VELOCITY;
		}
	}
}
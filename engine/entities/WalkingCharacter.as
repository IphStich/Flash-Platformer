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
	
	public class WalkingCharacter extends Character
	{
		//public var surface:Part;
		private var _surface:Part;
		public function get surface () : Part { return _surface; }
		public function set surface (inp:Part) {
			if (_surface != null) _surface.unattach(this);
			_surface = inp;
			if (_surface != null) _surface.attach(this);
		}
		
		protected var topLeft:HitPoint;
		protected var topRight:HitPoint;
		protected var lowerLeft:HitPoint;
		protected var lowerRight:HitPoint;
		protected var baseLeft:HitPoint;
		protected var baseRight:HitPoint;
		
		protected var targetSpeed:Number = NaN;
		
		public function WalkingCharacter()
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
		
		override public function tickMove (delta:Number):void
		{
			if (!isNaN(targetSpeed))
			{
				if (HORIZ_ACC == 0)
				{
					vx = targetSpeed;
				}
				else
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
			}
			
			super.tickMove (delta);
			
			if (surface != null)
				px = x + vx * delta * surface.slopeSpeed(this);
			
			updateSurface();
		}
		
		protected final function updateSurface ()
		{
			// If on a ground
			if (surface != null)
			{
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
		
		override public function tickEnd(delta:Number):void 
		{
			if (surface != null)
			{
				py = surface.getTopAt(px);
			}
			
			super.tickEnd(delta);
		}
		
		override protected function refreshCollisions ()
		{
			updateSurface();
			
			super.refreshCollisions();
			
			//return;
			
			var check:Vector.<HitData>;
			var hd:HitData;
			
			// top box
			if (py < y)
			{
				check = topLeft.getHitPathBetweenPoints(topRight);
				while (check.length > 0) 
				{
					hd = check.pop();
					
					if (!(hd.hit is Part)) {
						hd.destroy();
						continue;
					}
					
					hd.y = (hd.hit as Part).bottom;
					
					//if (y < hd.y) {
						//hd.destroy();
						//continue;
					//}
					
					hd.t = -1;
					hd.point = topRight;
					hd.type = HitData.TYPE_BOTTOM;
					collisions.push(hd);
				}
			}
			
			// left box
			if (px < x)
			{
				check = lowerLeft.getHitPathBetweenPoints(topLeft);
				while (check.length > 0) 
				{
					hd = check.pop();
					
					if (!(hd.hit is Part)) {
						hd.destroy();
						continue;
					}
					
					hd.x = (hd.hit as Part).right;
					
					//if (x < hd.x) {
						//hd.destroy();
						//continue;
					//}
					
					hd.t = -1;
					hd.point = lowerLeft;
					hd.type = HitData.TYPE_RIGHT;
					collisions.push(hd);
				}
			}
			
			
			// right box
			if (px > x)
			{
				check = lowerRight.getHitPathBetweenPoints(topRight);
				while (check.length > 0) 
				{
					hd = check.pop();
					
					if (!(hd.hit is Part)) {
						hd.destroy();
						continue;
					}
					
					hd.x = (hd.hit as Part).left;
					
					//if (x > hd.x) {
						//hd.destroy();
						//continue;
					//}
					
					hd.t = -1;
					hd.point = lowerRight;
					hd.type = HitData.TYPE_LEFT;
					collisions.push(hd);
				}
			}
			
			// bottom
			if (py > y)
			{
				check = lowerLeft.getHitPathBetweenPoints(lowerRight);
				while (check.length > 0)
				{
					hd = check.pop();
					
					if (!(hd.hit is Part)) {
						hd.destroy();
						continue;
					}
					
					//if (y > hd.y) {
						//hd.destroy();
						//continue;
					//}
					
					if (hd.x > px) hd.point = lowerRight;
					collisions.push(hd);
				}
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
			if (surface != null) {
				if (data.point == lowerLeft || data.point == lowerRight || data.point == baseLeft || data.point == baseRight) {
					if (surface.connections.indexOf(target) >= 0) {
						return;
					}
				}
			}
			
			if (target is Part)
			{
				var tPart = target as Part;
				
				// landing
				// Occurs no matter what the base points collide with
				if (point == baseLeft || point == baseRight)
				{
					land(data);
					return;
				}
				
				// if not 'landing', and is a platform, do nothing
				if (target is Platform) return;
				
				if (data.type == HitData.TYPE_SURFACE)
				{
					
					// force off the edge of Parts if not 'clean'
					if (px >= tPart.right && tPart.slope <= 0) {
						hitWall(-1, data);
						return;
					}
					if (px <= tPart.left && tPart.slope >= 0) {
						hitWall(1, data);
						return;
					}
				}
				//else if (data.point == baseLeft || data.point == baseRight)
				//{
					//return;
				//}
				
				// hitting a wall
				if (data.type == HitData.TYPE_LEFT)
				{
					if (data.point == topLeft || data.point == lowerLeft) return;
					if (data.point == lowerRight && tPart.slope < 0) return;
					
					hitWall(1, data);
					return;
				}
				if (data.type == HitData.TYPE_RIGHT)
				{
					if (data.point == topRight || data.point == lowerRight) return;
					if (data.point == lowerLeft && tPart.slope > 0) return;
					
					hitWall(-1, data);
					return;
				}
				
				// hitting a roof
				if (data.type == HitData.TYPE_BOTTOM)
				{
					//if (px > tPart.right)
					//{
						//hitWall(-1, data);
						//return;
					//}
					//else if (px < tPart.left)
					//{
						//hitWall(1, data);
						//return;
					//}
					
					hitHead(data);
					return;
				}
			}
			
			
			super.collide(data);
		}
		
		protected function hitEdge (side:Number) : void
		{
			fall();
		}
		
		protected function hitWall (direction:int, data:HitData) : void
		{
			var wall:Part = data.hit as Part;
			
			collided = true;
			
			if (direction == -1) {
				vx = 0;
				px = wall.right - hitBox.left + 0.1;
				x = px;
			} else if (direction == 1) {
				vx = 0;
				px = wall.left - hitBox.right - 0.1;
				x = px;
			}
		}
		
		protected function hitHead (data:HitData) : void
		{
			collided = true;
			
			//vy = 0;
			py = 0.1 + getHeight() + data.y;
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
			if (surface)
			{
				vx *= surface.slopeSpeed(this);
				vy = vx * surface.slope;
			}
			else
			{
				vy = 0;
			}
			gotoAirMode();
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
			
			ax = 0;
			
			if (vy != 0 && surface != null) gotoAirMode();
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
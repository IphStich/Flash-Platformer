package iphstich.platformer.engine.entities.projectiles
{
	import classes.screens.EnterCodeScreen;
	import flash.display.DisplayObject;
	import iphstich.platformer.engine.entities.Character;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.entities.HitPoint;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.platformer.engine.Engine;
	
	public class Bullet extends Entity
	{
		private const EXPLOSION_SIZE:Number = 30;
		public var DAMAGE:Number = 5;
		
		protected var facing:int;
		
		public function Bullet()
		{
			super();
			team = 1;
			hitCenter.hitList = new Vector.<Class>();
			hitCenter.hitList.push(Entity, Part);
		}
		
		public function shoot (lev:Level, startX:Number, startY:Number, speedX:Number, speedY:Number) : void
		{
			spawn(startX, startY, lev);
			
			vx = speedX;
			vy = speedY;
			facing = (speedX < 0) ? -1 : 1;
			
			this.scaleX = facing;
		}
		
		override protected function collide (data:HitData) : void
		{
			// ignore Entities of the same team
			if (data.hit is Entity) if ((data.hit as Entity).team == team) return;
			
			explode(data);
		}
		
		protected function explode (data:HitData = null) : void
		{
			if (EXPLOSION_SIZE == 0)
			{
				hit(data);
			}
			else
			{
				// get the explosion coordinates
				var cx:Number, cy:Number;
				if (data != null) {
					cx = data.x;
					cy = data.y;
				} else {
					cx = px;
					cy = py;
				}
				
				// find everything the explosion hits
				var hits:Vector.<HitData> = new Vector.<HitData>();
				level.testHitRadial (hits, cx, cy, EXPLOSION_SIZE, new <Class>[Part]);
				
				// fun the hit routine for every hit object
				var hd:HitData;
				while ((hd = hits.pop()) != null)
				{
					hit(hd);
					hd.destroy();
				}
			}
			
			death();
		}
		
		protected function hit (data:HitData) : void
		{
			if (data == null) return;
			
			var target:Entity = data.hit as Entity;
			if (target != null)
			{
				if (target.team != this.team)
				{
					target.hitBy(this);
				}
			}
		}
	}
}
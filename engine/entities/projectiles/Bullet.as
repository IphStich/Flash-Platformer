package iphstich.platformer.engine.entities.projectiles
{
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
		private const DAMAGE:Number = 5;
		
		protected var facing:String;
		
		public function Bullet()
		{
			super();
			team = 1;
			hitCenter.hitList = new Vector.<Class>();
			hitCenter.hitList.push(Entity, Part);
		}
		
		public function shoot (startX:Number, startY:Number, speedX:Number, speedY:Number, time:Number) : void
		{
			//facing = (speedX < 0) ? "left" : "right";
			//
			//this.scaleX = (speedX > 0) ? 1 : -1;
			//
			//movement.initial (time, startX, startY, speedX, speedY);
		}
		
		//override protected function collide (point:HitPoint, data:HitData) : void
		//{
			//// ignore Entities of the same team
			////trace(target)
			//if (data.hit is Entity) if ((data.hit as Entity).team == team) return;
			//
			//explode(data);
		//}
		
		protected function explode (data:HitData) : void
		{
			//var time:Number = data.time;
			//var i:int, d:DisplayObject, c:Character;
			//var hits:Vector.<HitData> = this.level.testHit(new Vector.<HitData>(), getX(time), getY(time), EXPLOSION_SIZE, time);
			//
			//for (i=hits.length-1; i>= 0; --i)
			//{
				//d = hits[i].hit;
				//if (d is Character)
				//{
					//this.hit (time, d as Character);
				//}
			//}
			//
			//death();
		}
		
		protected function hit (time:Number, target:Character) : void
		{
			//if (target.team == this.team) return;
			//
			//target.dealDamage(this.DAMAGE);
			//target.applyImpulse
				//( (facing == "left") ? -200 : 200
				//, -600
				//, time
			//);
		}
	}
}
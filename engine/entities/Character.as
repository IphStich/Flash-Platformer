package iphstich.platformer.engine.entities
{
	import flash.utils.getQualifiedClassName;
	import iphstich.platformer.engine.entities.Entity;
	
	public class Character extends Entity
	{
		public var JUMP_HEIGHT:Number = 120 + 9;
		public var JUMP_ARC_TIME:Number = 1.1//1.15;
		public var JUMP_ARC_DISTANCE:Number = 330 + 20;
		public var TIME_TO_MAX_SPEED:Number = 0.15;
		public var AIR_ACC_PENALTY:Number = 0.5;
		public var AIR_ACC_FEATHER:Number = 0.1;
		
		public var MAX_HORIZ_SPEED:Number = JUMP_ARC_DISTANCE / JUMP_ARC_TIME;
		public var HORIZ_ACC:Number = MAX_HORIZ_SPEED / TIME_TO_MAX_SPEED;
		public var HORIZ_ACC_AIR:Number = HORIZ_ACC * AIR_ACC_PENALTY;
		public var HORIZ_ACC_FEATHER:Number = HORIZ_ACC * AIR_ACC_FEATHER;
		public var GRAVITY:Number = 2 * JUMP_HEIGHT / JUMP_ARC_TIME / JUMP_ARC_TIME * 4;
		public var JUMP_VELOCITY:Number = GRAVITY * JUMP_ARC_TIME / 2;
		
		public var currentAction:String = "stand"
		public var currentFacing:String = "right"
		
		public var health:Number;
		
		private var _facing:int;
		public function get facing () : int { return _facing; }
		public function set facing (inp:int) { _facing = inp; scaleX = inp; }
		
		public function Character()
		{
			super();
			
			health 	= 100;
			facing 	= 1;
		}
		
		public function dealDamage (damage:Number) : void
		{
			health -= damage;
		}
		
		/**
		 * action / facing
		 * @param	anim
		 */
		protected function playAnim (anim:String = "") : void
		{
			//if (anim == "") return;
			//var act:Array = anim.split(" ")
			//if (act[0].length > 0) currentAction = act[0];
			//if (act.length > 1) if (act[1].length > 0) currentFacing = act[1];
		}
		
		public function updateMoveVariables () : void
		{
			MAX_HORIZ_SPEED 	= JUMP_ARC_DISTANCE / JUMP_ARC_TIME;
			HORIZ_ACC 			= MAX_HORIZ_SPEED / TIME_TO_MAX_SPEED;
			HORIZ_ACC_AIR 		= HORIZ_ACC * AIR_ACC_PENALTY;
			HORIZ_ACC_FEATHER 	= HORIZ_ACC * AIR_ACC_FEATHER;
			GRAVITY 			= 2 * JUMP_HEIGHT / JUMP_ARC_TIME / JUMP_ARC_TIME * 4;
			JUMP_VELOCITY 		= GRAVITY * JUMP_ARC_TIME / 2;
		}
	}
}
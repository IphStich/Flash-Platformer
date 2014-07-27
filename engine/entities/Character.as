package iphstich.platformer.engine.entities
{
	import flash.utils.getQualifiedClassName;
	import iphstich.platformer.engine.entities.Entity;
	
	public class Character extends Entity
	{
		protected var JUMP_HEIGHT:Number = 0;
		protected var JUMP_ARC_TIME:Number = 0;
		protected var JUMP_ARC_DISTANCE:Number = 0;
		protected var TIME_TO_MAX_SPEED:Number = 0;
		protected var AIR_ACC_PENALTY:Number = 0;
		protected var AIR_ACC_FEATHER:Number = 0;
		
		protected var MAX_HORIZ_SPEED:Number = 0;
		protected var HORIZ_ACC:Number = 0;
		protected var HORIZ_ACC_GROUND:Number = 0;
		protected var HORIZ_ACC_AIR:Number = 0;
		protected var HORIZ_ACC_FEATHER:Number = 0;
		protected var GRAVITY:Number = 0;
		protected var JUMP_VELOCITY:Number = 0;
		
		public var currentAction:String = ""
		
		public var health:Number;
		
		private var _facing:int;
		public function get facing () : int { return _facing; }
		public function set facing (inp:int) { _facing = inp; }
		
		public function Character()
		{
			super();
			
			health 	= 100;
			facing 	= 1;
			
			setDefaultMoveVariables();
		}
		
		override public function tickEnd(delta:Number):void 
		{
			super.tickEnd(delta);
			
			playAnim (animationLogic());
		}
		
		public function dealDamage (damage:Number) : void
		{
			health -= damage;
		}
		
		protected function setDefaultMoveVariables() : void
		{
			JUMP_HEIGHT = 120 + 9;
			JUMP_ARC_TIME = 1.1;
			JUMP_ARC_DISTANCE = 330 + 20;
			TIME_TO_MAX_SPEED = 0.15;
			AIR_ACC_PENALTY = 0.5;
			AIR_ACC_FEATHER = 0.1;
			
			calculateMoveVariables();
		}
		
		protected function calculateMoveVariables () : void
		{
			MAX_HORIZ_SPEED 	= JUMP_ARC_DISTANCE / JUMP_ARC_TIME;
			HORIZ_ACC_GROUND 	= MAX_HORIZ_SPEED / TIME_TO_MAX_SPEED;
			HORIZ_ACC_AIR 		= HORIZ_ACC * AIR_ACC_PENALTY;
			HORIZ_ACC_FEATHER 	= HORIZ_ACC * AIR_ACC_FEATHER;
			GRAVITY 			= 2 * JUMP_HEIGHT / JUMP_ARC_TIME / JUMP_ARC_TIME * 4;
			JUMP_VELOCITY 		= GRAVITY * JUMP_ARC_TIME / 2;
			
			HORIZ_ACC 			= HORIZ_ACC_GROUND;
		}
		
		protected function playAnim (anim:String) : void
		{
			if (anim == "")
				gotoAndStop(1);
			else if (currentLabel != anim)
				gotoAndStop(anim);
		}
		
		protected function animationLogic () : String
		{
			return "";
		}
	}
}
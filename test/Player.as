package iphstich.platformer.test {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.globalization.LocaleID;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import iphstich.library.Controls;
	import iphstich.library.CustomMath;
	import iphstich.platformer.engine.levels.parts.Platform;
	import iphstich.platformer.test.TestWeapon;
	//import iphstich.mcs.engine.weapons.WeapCloud;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.entities.WalkingCharacter;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.interactables.Interactable;
	import iphstich.platformer.engine.weapons.Weapon;
	//import iphstich.ponycreator.PonyCreator;
	//import iphstich.mcs.gui.Chat;
	
	public class Player extends WalkingCharacter
	{
		public static var instance:Player;
		public static var freezeControls:Boolean = false;
		
		public var equipedWeapon:Weapon;
		//public var pc:PonyCreator;
		
		protected var SPRINT_SPEED:Number;
		
		public function Player()
		{
			super();
			
			if (instance != null) throw new Error("The Player class has already been instanciated.");
			instance = this;
			
			// load the Pony Creator instance
			//pc = new PonyCreator();
			//pc.addEventListener(PonyCreator.EVENT_LOADED, pcLoaded);
			//addChild(pc)
			
			// bind the controls
			Controls.addKeys
				( "jump",	Keyboard.SPACE
				, "jump",	Keyboard.K
				, "jump",	Keyboard.Z
				
				, "attack",	Keyboard.J
				, "attack",	Keyboard.X
				
				, "left",	Keyboard.A
				, "left",	Keyboard.LEFT
				
				, "right",	Keyboard.D
				, "right",	Keyboard.RIGHT
				
				, "down", Keyboard.DOWN
				, "down", Keyboard.S
				
				, "sprint", Keyboard.L
				, "sprint", Keyboard.SHIFT
				, "sprint", Keyboard.C
				
				//, "interact", Keyboard.S
				//, "interact", Keyboard.DOWN
				//, "dash",	Keyboard.SHIFT
				//, "dash",	Keyboard.L
			);
			
			// set default properties
			team 					= 0;
			equipedWeapon 			= new TestWeapon();
			equipedWeapon.host 		= this;
			setSize (40, 45);
			
			setDefaultMoveVariables();
		}
		
		
		
		override public function clear () : void
		{
			level.removeEntity(this);
		}
		
		override protected function land (data:HitData) : void
		{
			// ignore platforms if the down key is help down
			if (data.hit is Platform && Controls.down("down"))
			{
				return;
			}
			
			super.land(data);
		}
		
		//override protected function makeDecisions():void
		override public function tickThink (style:uint, delta:Number) : void
		{
			
			if (!controlsFrozen())
			{
				
				var heading:int = 0;
				//var targetSpeed:Number = 0;
				
				
				
				// calculate heading & target speed
				if (Controls.down("left")) heading = -1;
				if (Controls.down("right")) heading += 1;
				targetSpeed = heading * ((isSprinting()) ? SPRINT_SPEED : MAX_HORIZ_SPEED);
				
				// set facing...
				if (heading != 0) facing = heading;
				
				
				// fall through platform
				if (Controls.pressed("down") && surface is Platform)
				{
					gotoAirMode();
					y += 1;
				}
				
				// jumping
				if (Controls.pressed("jump") && canJump())
				{
					doJump();
				}
				
				// controlled jumping
				if (Controls.released("jump") && canSoftenJump())
				{
					vy *= 2 / 4;
				}
				
				// weapons
				if (equipedWeapon != null) {
					var st:uint = Controls.button("attack");
					if (st & Controls.KEY_UP)		equipedWeapon.triggerUp();
					if (st & Controls.KEY_RELEASED)	equipedWeapon.triggerRelease();
					if (st & Controls.KEY_DOWN)		equipedWeapon.triggerDown();
					if (st & Controls.KEY_PRESSED)	equipedWeapon.triggerPull();
				}
				
			}
			
			else
			
			{
				targetSpeed = 0;
			}
			
			
			super.tickThink(style, delta);
		} //makeDecisions
		
		override protected function calculateMoveVariables():void 
		{
			JUMP_HEIGHT = 160 + 9;
			JUMP_ARC_TIME = 1.1;
			JUMP_ARC_DISTANCE = 330 + 20;
			TIME_TO_MAX_SPEED = 0.15;
			AIR_ACC_PENALTY = 0.5;
			AIR_ACC_FEATHER = 0.1;
			
			super.calculateMoveVariables();
			
			SPRINT_SPEED = MAX_HORIZ_SPEED * 1.75;
		}
		
		protected function controlsFrozen() : Boolean
		{
			return false;
		}
		
		protected function canJump() : Boolean
		{
			return true;
		}
		
		protected function isSprinting () : Boolean
		{
			return (Controls.down("sprint"));
		}
		
		protected function canSoftenJump () : Boolean
		{
			return vy < 0;
		}
	}
}
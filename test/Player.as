package iphstich.platformer.test {
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
	import iphstich.platformer.engine.entities.WalkingEntity;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.interactables.Interactable;
	import iphstich.platformer.engine.weapons.Weapon;
	//import iphstich.ponycreator.PonyCreator;
	//import iphstich.mcs.gui.Chat;
	
	public class Player extends WalkingEntity
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
				
				, "shoot",	Keyboard.J
				, "shoot",	Keyboard.X
				
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
		
		//protected function endDashLength (time:Number) : void
		//{
			//trace("END DASH!");
			//currentAction = "walk";
			//playAnim();
		//}
		
		//override public function fall (time:Number=0) : void
		//{
			//super.fall(time);
			//
			//if (currentAction == "walk")
				//playAnim("leap")
			//else
				//playAnim("hop")
		//}
		
		//override protected function hitEdge(side:Number, time:Number):void
		//{
			//fall(time);
		//}
		
		override protected function land (data:HitData) : void
		{
			// ignore platforms if the down key is help down
			if (data.hit is Platform && Controls.down("down"))
			{
				return;
			}
			
			super.land(data);
			
			//var d:Boolean = currentFacing == "right";
			//var m:Boolean = currentAction == "leap";
			//
			//playAnim((m ? "walk " : "stand ") + currentFacing);
			//
			//if (ax) {
				//setCourse( { cx: cx, ax: HORIZ_ACC * (d ? 1 : -1) * (m ? 1 : -1) }, data.time );
			//}
		}
		
		//override protected function makeDecisions():void
		override public function tickThink (style:uint, delta:Number) : void
		{
			var heading:int = 0;
			//var targetSpeed:Number = 0;
			
			// this function is all about controls, so if they are frozen return and do nothing
			if (controlsFrozen()) return;
			
			//cx = MAX_HORIZ_SPEED;
			
			
			
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
				vy /= 2;
			}
			
			// weapons
			if (equipedWeapon != null) {
				var st:uint = Controls.button("shoot");
				if (st & Controls.KEY_UP)		equipedWeapon.triggerUp();
				if (st & Controls.KEY_RELEASED)	equipedWeapon.triggerRelease();
				if (st & Controls.KEY_DOWN)		equipedWeapon.triggerDown();
				if (st & Controls.KEY_PRESSED)	equipedWeapon.triggerPull();
			}
			
			
			
			super.tickThink(style, delta);
		} //makeDecisions
		
		//private function pcLoaded (e:Event) : void
		//{
			//pc.content.scaleX = -1 * PC_SCALE;
			//pc.content.scaleY = PC_SCALE;
			//this.dispatchEvent(e);
		//}
		//public static const PC_SCALE = 1 / 8;
		
		//override protected function playAnim (anim:String = "") : void
		//{
			//super.playAnim(anim);
			//
			//////return;
			////
			////switch (currentAction)
			////{
				////case "stand":
					////pc.animateTo( pc.convertPoseCode("000000000000000000000000000000000000000000000000"), getTimer(), getTimer() + 250);
					////break;
				////case "walk":
					////pc.animateTo( pc.convertPoseCode("000000000070000335000000000316000000032000336025"), getTimer(), getTimer() + 250);
					////break;
				////case "leap":
					////pc.animateTo( pc.convertPoseCode("000000000086000000091000000317000000324011332036"), getTimer(), getTimer() + 250);
					////break;
				////case "hop":
					////pc.animateTo( pc.convertPoseCode("000257073339295050000000336314000340327045321000"), getTimer(), getTimer() + 250);
					////break;
				////case "dash":
					////pc.animateTo( pc.convertPoseCode("000294262088333351038276310023313339019344336333"), getTimer(), getTimer() + 250);
					////break;
				////default:
					////throw new Error("Unrecognised animation \"" + currentAction + "\"");
			////}
			////
			////switch (currentFacing)
			////{
				////case "left":
					////pc.scaleX = -1;
					////break;
				////case "right":
					////pc.scaleX = 1;
					////break;
				////default:
					////throw new Error("Unrecognised facing \"" + currentFacing + "\"");
			////}
		//} //playAnim
		
		public function setDefaultMoveVariables() : void
		{
			JUMP_HEIGHT = 120 + 9;
			JUMP_ARC_TIME = 1.1;
			JUMP_ARC_DISTANCE = 330 + 20;
			TIME_TO_MAX_SPEED = 0.15;
			AIR_ACC_PENALTY = 0.5;
			AIR_ACC_FEATHER = 0.1;
			
			updateMoveVariables();
			
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
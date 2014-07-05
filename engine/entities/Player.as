package iphstich.platformer.engine.entities
{
	import flash.events.Event;
	import flash.globalization.LocaleID;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import iphstich.library.Controls;
	import iphstich.library.CustomMath;
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
				
				//, "interact", Keyboard.S
				//, "interact", Keyboard.DOWN
				//, "dash",	Keyboard.SHIFT
				//, "dash",	Keyboard.L
			);
			
			// set default properties
			team 					= 1;
			//equipedWeapon 			= new WeapCloud();
			//equipedWeapon.host 		= this;
			setSize (40, 45);
		}
		
		
		
		override public function clear () : void
		{
			level.removeEntity(this);
		}
		
		protected function endDashLength (time:Number) : void
		{
			trace("END DASH!");
			currentAction = "walk";
			playAnim();
		}
		
		override public function fall (time:Number) : void
		{
			super.fall(time);
			
			if (currentAction == "walk")
				playAnim("leap")
			else
				playAnim("hop")
		}
		
		override protected function hitEdge(side:Number, time:Number):void
		{
			fall(time);
		}
		
		override protected function land (data:HitData) : void
		{
			super.land(data);
			
			var d:Boolean = currentFacing == "right";
			var m:Boolean = currentAction == "leap";
			
			playAnim((m ? "walk " : "stand ") + currentFacing);
			
			if (ax) {
				setCourse( { cx: cx, ax: HORIZ_ACC * (d ? 1 : -1) * (m ? 1 : -1) }, data.time );
			}
		}
		
		override protected function makeDecisions():void
		{
			// this function is all about controls, so if they are frozen return and do nothing
			if (controlsFrozen()) return;
			
			var pressTime:Number = (engine.time * 3 + engine.lastFrame) / 4
			var newHeading:Number = Number.NaN;
			
			// work out which direction the player wants to go
			if (Controls.pressed("right")) newHeading = 1;
			if (Controls.pressed("left")) newHeading = -1;
			if (Controls.down("right") && heading == 0) newHeading = 1;
			if (Controls.down("left") && heading == 0) newHeading = -1;
			if (Controls.released("right") && heading == 1) newHeading = 0;
			if (Controls.released("left") && heading == -1) newHeading = 0;
			
			// change facing (ie which direction the character is looking)
			if (newHeading != heading && !isNaN(newHeading))
			{
				if (newHeading == -1) currentFacing = "left";
				if (newHeading == 1) currentFacing = "right";
				playAnim();
			}
			
			// handle direction and movement changes
			if (!isNaN(newHeading))
			{
				if (currentAction == "dash")
				{
					
				}
				else
				{ // normal movement logic
					heading = newHeading;
					
					if (getVX(pressTime) != MAX_HORIZ_SPEED * heading) // isn't moving at target speed
					{
						if (heading == 0)
						{ // stop
							setCourse( { cx: 0, ax: -CustomMath.normalize( getVX(pressTime) ) * (surface ? HORIZ_ACC : HORIZ_ACC_FEATHER) }, pressTime);
							currentAction = (surface ? "stand" : "hop");
							playAnim();
						}
						else if (ax != heading * (surface ? HORIZ_ACC : HORIZ_ACC_AIR) || cx != heading * MAX_HORIZ_SPEED) // isn't accelerating
						{
							setCourse(
								{ ax: heading * (surface ? HORIZ_ACC : HORIZ_ACC_AIR) // <- start moving
								, cx: heading * MAX_HORIZ_SPEED // <- cap speed
								}
							, pressTime);
							currentAction = (surface ? "walk" : "leap");
							playAnim();
						}
					}
				}
			}
			
			// dash
			if (Controls.pressed("dash"))
			{
				//TODO: some stuff here, like clean up a bit
				const DASH_DISTANCE = 400;
				const DASH_TIME = 0.2;
				const DASH_SPEED = 800;
				const DASH_SLOW = 1800;
				fall(pressTime);
				setCourse(
					{ vx: heading * DASH_SPEED
					, ax: -heading * DASH_SLOW
					, cx: heading * MAX_HORIZ_SPEED
					, cxf: endDashLength
					}
				, pressTime);
				currentAction = "dash";
				playAnim();
			}
			
			// jump
			if (Controls.pressed("jump"))
			{
				// start jump
				if (surface != null) {
					setCourse( { ky:getY(pressTime)-3, vy: -JUMP_VELOCITY, ay: GRAVITY, cy: JUMP_VELOCITY, ax: CustomMath.normalize(ax) * HORIZ_ACC_AIR }, pressTime );
					if (currentAction == "walk")
						playAnim("leap")
					else if (currentAction == "stand")
						playAnim("hop")
					//surface = null;
				} else {
					
				}
			}
			if (Controls.released("jump"))
			{
				// precision jumping
				var gvy = getVY(pressTime)
				if (surface == null && gvy < 0) {
					setCourse( { vy: gvy / 2 }, pressTime);
				}
			}
			
			// interact
			if (Controls.pressed("interact"))
			{
				var check:Vector.<HitData>;
				check = hitCenter.getHitPath();
				for each (var hd:HitData in check)
				{
					if (hd.hit is Interactable)
					{
						(hd.hit as Interactable).activate(this, pressTime);
					}
				}
			}
			
			// weapons
			if (equipedWeapon != null) {
				var st:uint = Controls.button("shoot");
				if (st & Controls.KEY_UP)		equipedWeapon.triggerUp(pressTime);
				if (st & Controls.KEY_RELEASED)	equipedWeapon.triggerRelease(pressTime);
				if (st & Controls.KEY_DOWN)		equipedWeapon.triggerDown(pressTime);
				if (st & Controls.KEY_PRESSED)	equipedWeapon.triggerPull(pressTime);
			}
		} //makeDecisions
		
		//private function pcLoaded (e:Event) : void
		//{
			//pc.content.scaleX = -1 * PC_SCALE;
			//pc.content.scaleY = PC_SCALE;
			//this.dispatchEvent(e);
		//}
		//public static const PC_SCALE = 1 / 8;
		
		override protected function playAnim (anim:String = "") : void
		{
			super.playAnim(anim);
			
			////return;
			//
			//switch (currentAction)
			//{
				//case "stand":
					//pc.animateTo( pc.convertPoseCode("000000000000000000000000000000000000000000000000"), getTimer(), getTimer() + 250);
					//break;
				//case "walk":
					//pc.animateTo( pc.convertPoseCode("000000000070000335000000000316000000032000336025"), getTimer(), getTimer() + 250);
					//break;
				//case "leap":
					//pc.animateTo( pc.convertPoseCode("000000000086000000091000000317000000324011332036"), getTimer(), getTimer() + 250);
					//break;
				//case "hop":
					//pc.animateTo( pc.convertPoseCode("000257073339295050000000336314000340327045321000"), getTimer(), getTimer() + 250);
					//break;
				//case "dash":
					//pc.animateTo( pc.convertPoseCode("000294262088333351038276310023313339019344336333"), getTimer(), getTimer() + 250);
					//break;
				//default:
					//throw new Error("Unrecognised animation \"" + currentAction + "\"");
			//}
			//
			//switch (currentFacing)
			//{
				//case "left":
					//pc.scaleX = -1;
					//break;
				//case "right":
					//pc.scaleX = 1;
					//break;
				//default:
					//throw new Error("Unrecognised facing \"" + currentFacing + "\"");
			//}
		} //playAnim
		
		public function setDefaultMoveVariables() : void
		{
			JUMP_HEIGHT = 120 + 9;
			JUMP_ARC_TIME = 1.1;
			JUMP_ARC_DISTANCE = 330 + 20;
			TIME_TO_MAX_SPEED = 0.15;
			AIR_ACC_PENALTY = 0.5;
			AIR_ACC_FEATHER = 0.1;
			
			updateMoveVariables();
		}
		
		public function controlsFrozen() : Boolean
		{
			//if (Chat.inChat) return true;
			
			return false;
		}
	}
}
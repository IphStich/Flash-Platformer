package iphstich.platformer.engine
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	//import iphstich.mcs.engine.entities.Player;
	import iphstich.platformer.engine.entities.enemies.TestEnemy;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.levels.interactables.Door;
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.platformer.Main;
	import iphstich.library.CustomMath;
	
	public class Engine
	{
		public static const STATUS_IDLE:uint = 0;
		public static const STATUS_START:uint = 1;
		
		public var lastFrame:Number;
		//public static var instance:Engine;
		public var time:Number;
		
		
		
		//private var dummy:MovieClip;
		private var status:int;
		private var stage:MovieClip;
		private var level:Level;
		
		public var view:MovieClip;
		public var viewport:Rectangle;
		
		
		
		public function Engine (stage:MovieClip)
		{
			//instance = this;
			
			this.stage 	= stage;
			status 		= STATUS_IDLE;
			lastFrame 	= getTimer() / 1000;
			time 		= lastFrame;
			//dummy 		= new MovieClip();
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, -10);
			
			view = new MovieClip();
			stage.addChild(view);
			
			//this.setLevel(Level.getLevel("testLevel"));
		}
		
		public function setLevel (lev:Level) : void
		{
			// deal with the old level
			if (level != null) {
				level.clear();
				view.removeChild(level);
			}
			
			// deal with the new level
			level = lev;
			if (level != null) {
				view.addChild(lev);
				level.start(this);
			}
		}
		
		public function setViewport (vp:Rectangle) : void
		{
			viewport = vp;
			
			view.x = viewport.x + viewport.width / 2;
			//view.x = viewport. / 2;
			view.y = viewport.y + viewport.height / 2;
		}
		
		public function start () : void
		{
			if (status == STATUS_START) {
				throw new Error("The engine is already started");
			}
			
			if (level == null) {
				throw new Error("Cannot start the engine without a level");
			}
			
			lastFrame 	= getTimer() / 1000;
			time 		= getTimer() / 1000;
			
			// start the engine
			status = STATUS_START
			enterFrameHandler();
		}
		
		public function startGame_hiohio () : void
		{
			//spawnHero();
			
			start();
		}
		
		private function spawnHero () : void
		{
			// move player to the spawn
			//var d:Door = level.getDoor("spawn1");
			//var pl:Player = Player.instance;
			//pl.spawn
				//( (d.right + d.left) / 2
				//, d.bottom
				//, time
				//, level
			//);
		}
		
		private function enterFrameHandler(e:Event = null):void
		{
			time = getTimer() / 1000;
			//trace(time)
			if (status > 0)
			{
				level.tick();
				
				level.x = level.width / -2;
				level.y = level.height / -2;
				
				
				// move screen
				//level.x += -Player.instance.x;
				//level.y += -Player.instance.y;
				//level.x /= 2;
				//level.y /= 2;
				
				// keep screen inside level
				//if (-level.x - Main.SCREEN_WIDTH / 2 / view.scaleX < level.left) level.x = -level.left - Main.SCREEN_WIDTH / 2 / view.scaleX;
				//if (-level.x + Main.SCREEN_WIDTH / 2 / view.scaleX > level.right) level.x = -level.right + Main.SCREEN_WIDTH / 2 / view.scaleX;
				//if (-level.y - Main.SCREEN_HEIGHT / 2 / view.scaleY < level.top) level.y = -level.top - Main.SCREEN_HEIGHT / 2 / view.scaleY;
				//if (-level.y + Main.SCREEN_HEIGHT / 2 / view.scaleY > level.bottom) level.y = -level.bottom + Main.SCREEN_HEIGHT / 2 / view.scaleY;
			}
			lastFrame = time;
		}
	}
}
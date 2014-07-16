package iphstich.platformer.engine
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	//import iphstich.mcs.engine.entities.Player;
	import iphstich.platformer.test.TestEnemy;
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
		
		public static const TICK_DISTINCT:uint = 1; 	// take framerate into account and tick a fixed number of times each second, this results in a fixed deltatime each tick
		//												// can create 'random' jumps in lag, but produces a consistant result
		
		public static const TICK_DELTA:uint = 2; 		// ignore framerate and tick each frame regardless, using delta-time
		// 												// probably the best option, this is what the majority of multiplayer games out there use
		
		//public static const TICK_CALCULATED:uint = 3;	// isntead of using deltatime, simply calculate vectoral movement and tick based on predictions
		////												// this probably uses the most processing power
		
		public var lastFrame:Number;
		//public static var instance:Engine;
		public var time:Number;
		
		
		
		//private var dummy:MovieClip;
		private var status:int;
		public var tickStyle:uint = 0;
		private var tickDelta:Number;
		private var stage:MovieClip;
		public var level:Level;
		
		public var view:MovieClip;
		public var viewport:Rectangle;
		
		public var camera:Camera;
		
		
		
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
			view.y = viewport.y + viewport.height / 2;
			
			if (camera != null) camera.viewport  = vp;
		}
		
		public function setTickStyle (style:uint, frequency:Number = 32) : void
		{
			tickStyle = style;
			tickDelta = 1.0 / frequency;
		}
		
		public function setCamera (camera:Camera)
		{
			this.camera = camera;
			camera.engine = this;
		}
		
		public function start () : void
		{
			if (status == STATUS_START) {
				throw Error("The engine is already started.");
			}
			
			if (tickStyle == -1) {
				throw Error("The engine does not have a tick style set.");
			}
			
			//if (tickStyle == TICK_CALCULATED) {
				//throw Error("The calculated tick-style is not currently supported.");
			//}
			
			if (level == null) {
				throw Error("The engine requires a level to start.");
			}
			
			if (camera == null) {
				throw Error("The engine requires a camera to start.");
			}
			
			camera.start();
			
			lastFrame 	= getTimer() / 1000;
			time 		= getTimer() / 1000;
			
			// start the engine
			status = STATUS_START
			enterFrameHandler();
		}
		
		private function enterFrameHandler(e:Event = null):void
		{
			// do nothing if idle
			if (status == STATUS_IDLE) return;
			
			
			if (tickStyle == TICK_DISTINCT)
			{
				time = getTimer() / 1000;
				
				while (time > lastFrame)
				{
					lastFrame += tickDelta;
					
					tick ();
				}
			}
			
			else if (tickStyle == TICK_DELTA)
			{
				lastFrame = time;
				time = getTimer() / 1000;
				tickDelta = time - lastFrame;
				
				tick ();
			}
			
			//else if (tickStyle == TICK_CALCULATED)
			//{
				//time = getTimer() / 1000;
				//tickDelta = time;
			//}
		}
		
		protected function tick ()
		{
			level.tick (tickStyle, tickDelta);
			
			camera.tick (tickDelta);
		}
		
		public function spawnEntity (target:Entity, spawnPoint:Point) : void
		{
			target.spawn (spawnPoint.x, spawnPoint.y, level);
		}
	}
}
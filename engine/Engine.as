package iphstich.platformer.engine
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import iphstich.library.Controls;
	import iphstich.platformer.test.TestEnemy;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.levels.interactables.Door;
	import iphstich.platformer.engine.levels.Level;
	import iphstich.platformer.engine.levels.parts.Part;
	import iphstich.platformer.Main;
	
	public class Engine extends EventDispatcher
	{
		/**
		 * Dispatched at the beginning of a tick.
		 */
		public static const EVENT_TICK:String = "Tick";
		
		/**
		 * One of the unique types of tick methods.
		 * This one takes framerate into account and ticks a fixed number of times a second, each with a fixed delta time value.
		 * <b>Warning:</b> This method may create 'random' jumps in lag and performance in practice, but will always produce a concistant result.
		 */
		public static const TICK_DISTINCT:uint = 1;
		
		/**
		 * One of the unique types of tick methods.
		 * This one ignores framerate and simply ticks each frame using whatever the delta time value is.
		 * This is probably the best option for the majority of games out there.
		 */
		public static const TICK_DELTA:uint = 2;
		
		/**
		 * One of the unique types of tick methods.
		 * Instead of using delta time or ticking at all, this calculates vectoral movement and updates based on predictions.
		 * Note, that this is probably the most processing hungry option, but produces and solid and accurate result.
		 * This method is currently not implemented.
		 */
		//public static const TICK_CALCULATED:uint = 3;
		
		
		private static const STATUS_IDLE:uint = 0;
		private static const STATUS_PAUSED:uint = 1;
		private static const STATUS_PLAY:uint = 2;
		
		
		// should be private, but really aren't
		private var time:Number;
		private var lastFrame:Number;
		
		
		
		//private var dummy:MovieClip;
		private var status:int = STATUS_IDLE;
		private var tickStyle:uint = 0;
		private var tickDelta:Number;
		//private var stage:MovieClip;
		public var level:Level;
		
		public var view:MovieClip;
		public var viewport:Rectangle;
		
		private var camera:Camera;
		
		private var didTick:Boolean = false;
		//public static var instance:Engine;
		
		
		
		public function Engine (host:MovieClip, stage:Stage = null)
		{
			// check for stage
			if (stage == null)
			{
				stage = host.stage;
				if (stage == null)
				{
					throw new Error("The engine cannot be created without a stage. Either the host clip needs to be on the stage, or you uneed to feed a stage to this constructor.");
				}
			}
			//this.stage 	= stage;
			
			// set base variables
			lastFrame 	= getTimer() / 1000;
			time 		= lastFrame;
			
			// add event listeners
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, -10);
			//stage.addEventListener(Event.EXIT_FRAME, exitFrameHandler, false, int.MIN_VALUE);
			stage.addEventListener(Event.ENTER_FRAME, exitFrameHandler, false, int.MIN_VALUE);
			
			// create the view
			view = new MovieClip();
			stage.addChild(view);
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
			if (status != STATUS_IDLE) {
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
			status = STATUS_PLAY;
			enterFrameHandler();
		}
		
		public function pause () : void
		{
			if (status == STATUS_IDLE) throw new Error("Cannot pause if engine hasn't started.");
			
			status = STATUS_PAUSED;
			level.pause ();
			
			if (tickStyle == TICK_DISTINCT)
			{
				Controls.automaticReset();
			}
		}
		
		public function unpause () : void
		{
			if (status == STATUS_IDLE) throw new Error("Cannot unpause if engine hasn't started.");
			if (status != STATUS_PAUSED) throw new Error("Cannot unpause if engine isn't paused.");
			
			status = STATUS_PLAY;
			level.unpause ();
			
			if (tickStyle == TICK_DISTINCT)
			{
				Controls.manualReset();
			}
		}
		
		private function enterFrameHandler(e:Event = null):void
		{
			didTick = false;
			time = getTimer() / 1000;
			
			
			// do nothing if idle
			if (status == STATUS_IDLE) return;
			
			
			if (tickStyle == TICK_DELTA)
			{
				tickDelta = time - lastFrame;
				lastFrame = time;
				
				tick ();
			}
			
			else if (tickStyle == TICK_DISTINCT)
			{
				while (time > lastFrame)
				{
					lastFrame += tickDelta;
					
					tick ();
				}
			}
			
			//else if (tickStyle == TICK_CALCULATED)
			//{
				//time = getTimer() / 1000;
				//tickDelta = time;
			//}
		private function exitFrameHandler (e:Event = null)
		{
			if (didTick)
			{
				if (tickStyle == TICK_DISTINCT) Controls.manualReset();
			}
		}
		
		protected function tick ()
		{
			// don't tick if not playing
			if (status != STATUS_PLAY) return;
			
			dispatchEvent(new Event(EVENT_TICK));
			
			didTick = true;
			
			level.tick (tickStyle, tickDelta);
			
			camera.tick (tickDelta);
		}
		
		public function spawnEntity (target:Entity, spawnPoint:Point) : void
		{
			target.spawn (spawnPoint.x, spawnPoint.y, level);
		}
	}
}
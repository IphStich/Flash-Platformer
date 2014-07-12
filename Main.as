package iphstich.platformer
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import iphstich.library.Controls;
	import iphstich.library.FPSCounter;
	import iphstich.library.NextFrame;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.levels.Level;
	
	public class Main extends MovieClip
	{
		public static const GRID_SIZE:Number = 10;
		
		//public static var instance:Main;
		
		protected var pl:Entity;
		protected var level:Level;
		protected var engine:Engine;
		
		public function Main()
		{
			super();
			
			//instance = this;
			Controls.init(stage);
			NextFrame.init(stage);
			
			addChildAt(new FPSCounter(this), this.numChildren);// addChild( new FPSCounter(this) );
			//stage.scaleMode = StageScaleMode.SHOW_ALL;
		}
		
		/**
		 * Override so that whenever a child is added to the the stage, it goes below the FPS counter
		 * @param	child
		 * @return
		 */
		override public function addChild(child:DisplayObject):flash.display.DisplayObject
		{
			return addChildAt(child, 0);
		}
	}
}
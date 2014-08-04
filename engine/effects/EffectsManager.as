package iphstich.platformer.engine.effects 
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	//import Vector;
	import iphstich.platformer.engine.levels.Level;
	/**
	 * ...
	 * @author IphStich
	 */
	public class EffectsManager 
	{
		static var freeInstances:Dictionary = new Dictionary();
		
		static public function create (level:Level, effectClass:Class, x:Number, y:Number) : Effect
		{
			var ret:Effect
			
			// create vector for class if it doesn't exist
			if (freeInstances[effectClass] == undefined)
			{
				freeInstances[effectClass] = new Vector.<Effect>();
			}
			
			// get from vector if possible
			if ((freeInstances[effectClass] as Vector.<Effect>).length > 0)
			{
				ret = (freeInstances[effectClass] as Vector.<Effect>).pop();
			}
			else // if not, create a new instance!
			{
				ret = new effectClass();
			}
			
			
			// init the effect
			ret.x = x;
			ret.y = y;
			ret.gotoAndPlay(1);
			
			// and add to level
			level.addEffect(ret);
			
			
			// return if the caller wishes to modify the effect in any way
			return ret;
		}
		
		static public function endEffect (effect:Effect) : void
		{
			// add it to the vector for re-use later
			(freeInstances[Object(effect).constructor] as Vector.<Effect>).push(effect);
			
			// remove from level/stage
			effect.parent.removeChild(effect);
			
			// set the frame to 1 to prevent re-calling this function
			effect.gotoAndStop(1);
		}
	}
}
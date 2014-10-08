package iphstich.platformer.engine.levels
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.ui.Keyboard;
	import iphstich.pips.EnemyUnicorn;
	import iphstich.pips.EnemyPegasus;
	import iphstich.pips.EnemyEarth;
	import iphstich.platformer.engine.effects.Effect;
	import iphstich.platformer.engine.levels.misc.KillLine;
	import iphstich.platformer.engine.levels.misc.POI;
	import iphstich.platformer.engine.Renderable;
	import iphstich.platformer.engine.levels.misc.Trigger;
	
	import iphstich.library.Controls;
	import iphstich.library.CustomMath;
	import iphstich.platformer.Main;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.ICollidable;
	import iphstich.platformer.engine.levels.interactables.Door;
	import iphstich.platformer.engine.levels.interactables.Interactable;
	import iphstich.platformer.engine.levels.misc.Area;
	import iphstich.platformer.engine.levels.parts.*;
	import iphstich.platformer.test.TestEnemy;
	import iphstich.platformer.engine.levels.misc.EntityPlane;
	
	public class Level extends MovieClip
	{
		protected static var levels:Dictionary;
		public static function getLevel(name:String) : Level
		{
			if (levels == null) levels = new Dictionary();
			if (levels[name]) return levels[name];
			
			var ret:Level = null;
			
			//switch (name) {
				//case "testLevel":
					//ret = new TestLevel();
					//break;
				//case "hallway":
					//ret = new Hallway();
					//break;
				//case "trixieArena":
					//ret = new TrixieArena();
					//break;
				//case "firstRoom":
					//ret = new FirstRoom();
					//break;
			//}
			
			levels[name] = ret;
			if (ret == null) throw new Error("null level");
			return ret;
		}
		
		//public static const GRID_SIZE:Number = 10;
		public static var OUTSIDE_LEVEL:DisplayObject;
		
		protected var areas:Dictionary;
		protected var POIs:Dictionary;
		protected var doors:Vector.<Door>;
		protected var entityLevel:uint;
		protected var entityPlane:MovieClip;
		
		protected var entities:Vector.<Entity>;
		protected var numEntities:uint;
		
		protected var parts:Vector.<Part>;
		protected var numParts:uint = 0;
		
		protected var interactables:Vector.<Interactable>;
		protected var numInteractables:uint = 0;
		
		protected var collidables:Vector.<ICollidable>;
		protected var numCollidables:uint = 0;
		
		public var top:Number;
		public var left:Number;
		public var right:Number;
		public var bottom:Number;
		public var killLevel:Number;
		
		public var engine:Engine;
		
		private var toAddEntities:Vector.<Entity> = new Vector.<Entity>();
		private var toRemoveEntities:Vector.<Entity> = new Vector.<Entity>();
		
		var traceTestEnabled:Boolean = false;
		
		var T:MovieClip;
		
		public function Level()
		{
			if (OUTSIDE_LEVEL == null) OUTSIDE_LEVEL = new Bitmap();
			super();
			
			//entityToRemove = new Vector.<Entity>();
			numEntities = 0;
			
			interpretLevel();
			
			Controls.addKeys("traceTest", Keyboard.T);
			
			
			T = new MovieClip();
			addChild(T);
		}
		
		protected function interpretLevel () : void
		{
			var i:uint, j:uint;
			
			parts 			= new Vector.<Part>();
			doors 			= new Vector.<Door>();
			entities 		= new Vector.<Entity>();
			interactables 	= new Vector.<Interactable>();
			areas			= new Dictionary();
			POIs 			= new Dictionary();
			collidables 	= new Vector.<ICollidable>();
			
			// initialize level bounds to 'null' values
			top 	= Number.MAX_VALUE;
			left 	= Number.MAX_VALUE;
			right 	= Number.MIN_VALUE;
			bottom 	= Number.MIN_VALUE;
			killLevel = NaN;
			
			// grab the level pieces
			var numC:uint = numChildren;
			for (i = 0; i < numC; ++i)
			{
				var child:DisplayObject = this.getChildAt(i);
				if (child is Door) doors.push(child);
				if (child is Part) addPart (child);
				if (child is EntityPlane) entityPlane = child as EntityPlane; // { entityLevel = i; child.visible = false;  }
				if (child is Interactable) interactables.push(child);
				if (child is Area) addArea(child); // areas[child.name] = child;
				if (child is POI) addPOI (child);
				if (child is Entity) (child as Entity).spawn(child.x, child.y, this);
				if (child is Trigger) addTrigger (child);
				if (child is KillLine) killLevel = child.y;
			}
			
			if (isNaN(killLevel)) killLevel = bottom;
			
			numInteractables = interactables.length;
			
			// deal with the entity plane
			var depth:int;
			if (entityPlane != null)
			{
				depth = this.getChildIndex(entityPlane);
				removeChild(entityPlane);
			}
			else
			{
				depth = this.numChildren;
			}
			entityPlane = new MovieClip();
			addChildAt(entityPlane, depth);
			for each (var e:Entity in entities) entityPlane.addChild(e);
			sortRenderables();
		}
		
		public function addPart (child:DisplayObject) : void
		{
			var p:Part = child as Part;
			
			if (child.parent != this)
				this.addChild(child);
			
			// add to lists
			parts.push(p);
			numParts ++;
			collidables.push(p);
			numCollidables ++;
			
			// stretch level bounds
			if (top > p.top) 		top = p.top;
			if (left > p.left) 		left = p.left;
			if (right < p.right) 	right = p.right;
			if (bottom < p.bottom) 	bottom = p.bottom;
			
			// connect pieces by showing every piece every other piece
			for (var i = parts.length-1; i>=0; --i)
			{
				p.show( parts[i] );
			}
		}
		
		public function addArea (child:DisplayObject) : void
		{
			var a:Area = child as Area;
			
			// add to area dictionary
			areas[a.name] = a;
			
			// stretch level bounds
			if (top > a.top) 		top = a.top;
			if (left > a.left) 		left = a.left;
			if (right < a.right) 	right = a.right;
			if (bottom < a.bottom) 	bottom = a.bottom;
		}
		
		public function addPOI (child:DisplayObject) : void
		{
			POIs[child.name] = child;
		}
		
		public function addTrigger (child:DisplayObject) : void
		{
			var t:Trigger = child as Trigger;
			
			collidables.push(t);
			numCollidables ++;
		}
		
		public function activateTrigger (trigger:Trigger, other:Entity) : void
		{
			var i:int;
			
			//trace("TRIGGER", trigger.label);
			trigger.canBeActivated = false;
			
			if (trigger.label == "spawn")
			{
				var q:Number = Number(trigger.params[1] as String);
				var searchName:String = trigger.params[3];
				var type:String = (trigger.params[2] as String).toLowerCase();
				var spawnClass:Class = getClassFromSimpleString(type);
				
				var spawnArea:Area = getArea(searchName);
				if (spawnArea)
				{
					for (i=0; i<q; ++i)
					{
						new spawnClass().spawn(CustomMath.randomBetween(spawnArea.left, spawnArea.right), spawnArea.bottom, this);
					}
					
					return;
				}
				
				var poi:POI = getPOI(searchName);
				if (poi)
				{
					for (i=0; i<q; ++i)
					{
						new spawnClass().spawn(poi.x, poi.y, this);
					}
					
					return;
				}
				
				throw Error("Cannot find appropriate spawn point " + searchName);
			}
			
			else if (trigger.label == "kill")
			{
				other.death();
				trigger.canBeActivated = true;
			}
		}
		
		public function getClassFromSimpleString (string:String) : Class
		{
			return null;
		}
		
		public var pointResult:Vector.<HitData>;
		public function testHitPath (results:Vector.<HitData>, x1:Number, y1:Number, x2:Number, y2:Number) : void
		{
			if (x1 == x2 && y1 == y2) return;
			
			if (traceTestEnabled)
			{
				T.graphics.moveTo(x1, y1);
				T.graphics.lineTo(x2, y2);
			}
			
			var hd:HitData;
			var c:ICollidable;
			var i:int;
			
			// check for all collidables
			for (i = numCollidables-1; i >= 0; --i)
			{
				c = collidables[i];
				hd = c.hitTestPath(x1, y1, x2, y2);
				if (hd != null)
					results.push(hd);
			}
			
			// set t markers for results
			if (results.length > 0)
			{
				if (Math.abs(x1 - x2) > Math.abs(y1 - y2))
				{
					for each (hd in results)
						hd.t = Math.abs(hd.x - x1);
				}
				else
					for each (hd in results)
						hd.t = Math.abs(hd.y - y1);
			}
			
			// check for outside level
			if (!(x2 >= left && x2 <= right && y2 >= top && y2 <= bottom))
			{
				hd = HitData.hit(OUTSIDE_LEVEL, x2, y2, -1)
				results.push();
			}
		} //testHitPath
		
		private var shadowCheck:Vector.<HitData> = new Vector.<HitData>();
		public function testHitShadow (fromX:Number, fromY:Number, maxDistance:Number = NaN) : Number
		{
			if (isNaN(maxDistance)) maxDistance = bottom;
			//else maxDistance += fromY;
			
			testHitPath (shadowCheck, fromX, fromY, fromX, maxDistance);
			shadowCheck.sort(HitData.SORT_BY_T);
			
			var point:Number = NaN;
			//level.testHitPath(shadowCheck, x, y, x, level.bottom);
			//shadowCheck.sort(HitData.SORT_BY_T);
			var hd:HitData;
			while ((hd = shadowCheck.pop()) != null)
			{
				if (hd.hit is Part)
				{
					point = hd.y;
					//trace("---- " + point)
				}
				hd.destroy();
			}
			
			return point;
		}
		
		public function testHitRadial (results:Vector.<HitData>, x:Number, y:Number, radius:Number, blockedBy:Vector.<Class>) : void
		{
			
			
			// this sub-function checks each hit object in 'list',
			// returning null if encountering an object in 'blockedBy',
			// returning a HitData if 'target' is encountered
			// and returning null if neither are encountered
			function findBlocked (target:ICollidable, list:Vector.<HitData>, blockedBy:Vector.<Class>) : HitData
			{
				var count:int = list.length;
				var i:int;
				var hd:HitData;
				var c:Class;
				
				for (i=0; i<count; ++i)
				{
					hd = list[i];
					
					if (hd.hit == target) {
						for (i=i+1; i<count; ++i) list[i].destroy(); // discard un-used HitData
						return hd;
					}
					
					for each (c in blockedBy) if (hd.hit is c)
					{
						for (i=i; i<count; ++i) list[i].destroy(); // discard un-used HitData
						return null;
					}
					
					// discard un-used HitData
					hd.destroy();
				}
				return null;
			}
			
			if (traceTestEnabled)
			{
				T.graphics.drawCircle(x, y, radius);
			}
			
			
			var c:ICollidable;
			var p:Point;
			var points:Vector.<Point>;
			var pathResult:Vector.<HitData>;
			var blockResult:HitData;
			
			// get all the objects that fit within the radius
			// we use this as the short-list when we test for collision
			// this makes the many re-iterations execute potentially significantly faster
			var checkList:Vector.<ICollidable> = new Vector.<ICollidable>();
			getAllWithinRadius (checkList, x, y, radius);
			
			// save the default/standard collision objects
			// so that we can set them back at the end
			var savedCollidables:Vector.<ICollidable> = collidables;
			var savedNum:int = numCollidables;
			
			// override the collision objects for the collision detection later
			collidables = checkList;
			numCollidables = checkList.length;
			
			for each (c in checkList)
			{
				points = c.getRadialCheckPoints(x, y);
				
				for each (p in points)
				{
					pathResult = new Vector.<HitData>()
					
					testHitPath (pathResult, x, y, p.x, p.y);
					
					pathResult.sort(HitData.SORT_BY_T);
					
					blockResult = findBlocked(c, pathResult, blockedBy);
					
					if (blockResult != null)
					{
						results.push(blockResult);
						break;
					}
				}
			}
			
			// reset the saved objects back
			collidables = savedCollidables;
			numCollidables = savedNum;
		}
		
		public function getAllWithinRadius (results:Vector.<ICollidable>, x:Number, y:Number, radius:Number)
		{
			var c:ICollidable;
			var i:int;
			
			// check for all collidables
			for (i = numCollidables-1; i >= 0; --i)
			{
				c = collidables[i];
				if (c.isWithinRadius(x, y, radius))
					results.push(c);
			}
		}
		
		private var inTick:Boolean = false;
		public function tick (style:uint, delta:Number) : void
		{
			if (Controls.pressed("traceTest"))
			{
				traceTestEnabled = !traceTestEnabled;
				if (!traceTestEnabled) T.graphics.clear();
			}
			
			if (traceTestEnabled)
			{
				T.graphics.clear();
				T.graphics.lineStyle(2);
			}
			var e:Entity;
			
			inTick = true;
			
			for each (e in entities)
				e.tickThink (style, delta);
			
			for each (e in entities)
				e.tickMove (delta);
			
			for each (e in entities)
				e.tickCollide (delta);
			
			for each (e in entities)
				e.tickEnd (delta);
			
			inTick = false;
			
			postTick (style, delta);
		}
		
		protected function postTick (style:uint, delta:Number) : void
		{
			if (style == Engine.TICK_DISTINCT) Controls.manualReset();
			
			while (toAddEntities.length > 0)
				addEntity (toAddEntities.pop());
			
			while (toRemoveEntities.length > 0)
				removeEntity(toRemoveEntities.pop());
			
		}
		
		public function addEntity(target:Entity):void
		{
			if (inTick) { markForAddition(target); return; }
			
			//trace("ADD: " + getQualifiedClassName(target), Util.getMemoryLocation(target));
			entities.push(target)
			numEntities ++;
			
			collidables.push(target);
			numCollidables ++;
			
			if (entityPlane) if (!(entityPlane is EntityPlane)) entityPlane.addChild(target);
			
			target.addedToLevel(this);
			
			sortRenderables();
		}
		
		public function sortRenderables () : void
		{
			// do not sort if in the interp level stage
			if (entityPlane == null) return;
			if (entityPlane is EntityPlane) return;
			
			var i:int, j:int;
			var r:Renderable, s:Renderable;
			
			var numC:int = entityPlane.numChildren;
			for (i=1; i<numC; ++i)
			{
				r = entityPlane.getChildAt(i) as Renderable;
				
				for (j=i-1; j>=0; --j)
				{
					s = entityPlane.getChildAt(j) as Renderable;
					if (s.depthPriority <= r.depthPriority) break;
				}
				j += 1;
				
				entityPlane.setChildIndex(r, j);
			}
		}
		
		public function addEffect (target:Effect) : void
		{
			if (entityPlane) entityPlane.addChild(target);
			sortRenderables();
		}
		
		private function markForAddition (entity:Entity) : void
		{
			toAddEntities.push (entity);
		}
		
		public function removeEntity(target:Entity):void
		{
			if (inTick) { markForRemoval(target); return; }
			
			//trace("REMOVE: " + getQualifiedClassName(target), Util.getMemoryLocation(target));
			entities.splice(entities.indexOf(target), 1);
			numEntities --;
			
			collidables.splice(collidables.indexOf(target), 1);
			numCollidables --;
			
			entityPlane.removeChild(target);
			
			target.removedFromLevel(this);
		}
		
		private function markForRemoval (entity:Entity) : void
		{
			if (toRemoveEntities.indexOf(entity) != -1) trace("Cannot remove an entity twice!");
			else toRemoveEntities.push(entity);
		}
		
		public function getDoor(localName:String):Door
		{
			var i:uint;
			for (i = 0; i < doors.length; ++i)
			{
				if (doors[i].local == localName) return doors[i];
			}
			return null;
		}
		
		public function getArea (name:String) : Area
		{
			if (areas[name] == undefined) return null;
			
			return areas[name] as Area;
		}
		
		public function getPOI (name:String) : POI
		{
			if (POIs[name] == undefined) return null;
			
			return POIs[name];
		}
		
		public function getEntityByType (type:Class) : Entity
		{
			var e:Entity;
			
			for each (e in entities)
			{
				if (e is type) return e;
			}
			return null;
		}
		
		public function clear () : void
		{
			var i:int;
			// this function returns the level to its default state, for use again
			
			// delete entities
			//while (entities.length > 0)
			for (i=entities.length-1; i>=0; --i)
			{
				entities[i].clear();
			}
		}
		
		public function start (inEngine:Engine) : void
		{
			engine = inEngine;
			
			//var a:Area = getArea("enemies");
			//if (a == null) return;
			//var i:int;
			//for (i=0; i<10; ++i)
			//{
				//new TestEnemy().spawn(CustomMath.randomBetween(a.left, a.right), a.bottom, this);
			//}
		}
	}
}
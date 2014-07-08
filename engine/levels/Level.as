package iphstich.platformer.engine.levels
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import iphstich.library.CustomMath;
	import iphstich.platformer.Main;
	import iphstich.platformer.engine.Engine;
	import iphstich.platformer.engine.entities.Entity;
	import iphstich.platformer.engine.HitData;
	import iphstich.platformer.engine.levels.interactables.Door;
	import iphstich.platformer.engine.levels.interactables.Interactable;
	import iphstich.platformer.engine.levels.parts.*;
	import iphstich.platformer.engine.entities.enemies.TestEnemy;
	import iphstich.platformer.engine.levels.misc.Area;
	
	import flash.utils.getQualifiedClassName;
	
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
		protected var parts:Vector.<Part>;
		protected var numEntities:uint;
		protected var numParts:uint;
		protected var numInteractables:uint;
		protected var doors:Vector.<Door>;
		protected var entities:Vector.<Entity>;
		protected var entityLevel:uint;
		protected var entityPlane:EntityPlane;
		protected var interactables:Vector.<Interactable>;
		//private var entityToRemove:Vector.<Entity>;
		
		public var top:Number;
		public var left:Number;
		public var right:Number;
		public var bottom:Number;
		
		public var engine:Engine;
		
		public function Level()
		{
			if (OUTSIDE_LEVEL == null) OUTSIDE_LEVEL = new Bitmap();
			super();
			
			//entityToRemove = new Vector.<Entity>();
			numEntities = 0;
			
			interpretLevel();
		}
		
		protected function interpretLevel () : void
		{
			var i:uint, j:uint;
			
			parts 			= new Vector.<Part>();
			doors 			= new Vector.<Door>();
			entities 		= new Vector.<Entity>();
			interactables 	= new Vector.<Interactable>();
			areas			= new Dictionary();
			
			// initialize level bounds to 'null' values
			top 	= Number.MAX_VALUE;
			left 	= Number.MAX_VALUE;
			right 	= Number.MIN_VALUE;
			bottom 	= Number.MIN_VALUE;
			
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
			}
			
			numInteractables = interactables.length;
			
			// interpret the level parts
			//numParts = parts.length;
			//for (i = 0; i < numParts; ++i)
			//{
				////var p:Part = parts[i]
				//
				////// stretch level bounds
				////if (top > p.top) 		top = p.top;
				////if (left > p.left) 		left = p.left;
				////if (right < p.right) 	right = p.right;
				////if (bottom < p.bottom) 	bottom = p.bottom;
				//
				//// connect pieces by showing every piece every other piece
				////for (j=i+1; j<numParts; ++j)
				////{
					//////if (j == i) continue;
					////p.show( parts[j] );
				////}
			//}
		}
		
		public function addPart (child:DisplayObject) : void
		{
			var p:Part = child as Part;
			
			if (child.parent != this)
				this.addChild(child);
			
			// add to parts list
			parts.push(p);
			numParts ++;
			
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
		
		public function testHit(result:Vector.<HitData>, x:Number, y:Number, radius:Number=0, time:Number=-1):Vector.<HitData>
		{
			var obj:Object;
			var ret:Vector.<HitData>; var i:uint;
			
			ret = result;
			
			if (time == -1) time = engine.time;
			//if (radius == 0) radius = 1;
			
			// test level bounds
			if (!(x >= left - radius && x <= right + radius && y >= top - radius && y <= bottom + radius))
			{
				ret.push(HitData.hit(OUTSIDE_LEVEL, x, y, time));
				return ret;
			}
			
			// hit test Parts
			var p:Part;
			for (i = 0; i < numParts; ++i)
			{
				p = parts[i];
				if (p.hitTest(x, y, radius))
					ret.push(HitData.hit(p, x, y, time));
			}
			
			// hit test entities
			var e:Entity;
			for (i = 0; i < numEntities; ++i)
			{
				e = entities[i];
				if (e.hitTest(x, y, radius, time))
					ret.push(HitData.hit(entities[i], x, y, time));
			}
			
			// hit test interactables
			var r:Interactable;
			for (i=0; i<numInteractables; ++i)
			{
				r = interactables[i];
				if (r.hitTest(x, y, radius))
					ret.push(HitData.hit(r, x, y, time));
			}
			
			return ret;
		}
		
		public var pointResult:Vector.<HitData>;
		public function testHitPath(result:Vector.<HitData>, x1:Number, y1:Number, x2:Number, y2:Number, radius:Number = 0, timeFrom:Number = -1, timeTo:Number = -1, interval:Number = -1, endOnFirst:Vector.<Class> = null):Vector.<HitData>
		{
			//this.graphics.clear();
			//this.graphics.lineStyle(1, 0xFF0000, 1);
			//this.graphics.moveTo(x1, y1);
			//if (pointResult == null) pointResult = new Vector.<HitData>();
				//if (pointResult.length > 0)
					//throw new Error("made new");
			
			var i:uint;
			
			//if (timeFrom == -1) timeFrom = engine.time;
			//if (timeTo == -1) timeTo = engine.time;
			//if (interval <= 0) interval = Main.GRID_SIZE;
			//
			//var distance:Number = CustomMath.distance(x1, x2, y1, y2)
			//var numIterations:Number = Math.floor(distance / interval);
			//
			//if (numIterations == 0)
			//{
				//return testHit(result, x2, y2, radius, timeTo);
			//}
			//else
			//{
				//interval = distance / numIterations;
				////var ret:Vector.<HitData> = new Vector.<HitData>();
				//var pathDirection:Point = CustomMath.normalize(new Point(x2 - x1, y2 - y1));
				//var pathX:Number = pathDirection.x;
				//var pathY:Number = pathDirection.y;
				//var timeDif:Number = (timeTo - timeFrom) / numIterations;
				//var start:Point = new Point(x1, y1);
				//
				//for (i=0; i<=numIterations; ++i)
				//{
					//var point:Point = CustomMath.multiply(pathDirection, interval * i);
					//point = point.add(start);
					////this.graphics.lineTo(point.x, point.y - 5);
					////this.graphics.lineTo(point.x, point.y);
					//testHit
						//( result
						//, start.x + pathX * interval * i
						//, start.y + pathY * interval * i
						//, radius
						//, timeFrom + timeDif * i
					//);
					////while (pointResult.length > 0) {
						////var b:HitData = result.pop();
					////}
					////for each (var b:HitData in pointResult) {
						////ret.push(b);
						////if (endOnFirst != null) for each (var c:Class in endOnFirst) if (b.hit is c) return ret;
						////if (b.hit == Level.OUTSIDE_LEVEL) return ret;
					////}
				//}
			//}
			
			//return result;
			
			
			var h:HitData;
			
			if (!(x2 >= left && x2 <= right && y2 >= top && y2 <= bottom))
			{
				result.push(HitData.hit(OUTSIDE_LEVEL, x, y, 0));
				return result;
			}
			
			// hit test Parts
			var p:Part;
			for (i = 0; i < numParts; ++i)
			{
				p = parts[i];
				h = p.hitTestPath(x1, y1, x2, y2);
				if (h != null)
					result.push(h);
			}
			return null;
			
			//// hit test entities
			//var e:Entity;
			//for (i = 0; i < numEntities; ++i)
			//{
				//e = entities[i];
				//if (e.hitTest(x, y, radius, time))
					//ret.push(HitData.hit(entities[i], x, y, time));
			//}
			//
			//// hit test interactables
			//var r:Interactable;
			//for (i=0; i<numInteractables; ++i)
			//{
				//r = interactables[i];
				//if (r.hitTest(x, y, radius))
					//ret.push(HitData.hit(r, x, y, time));
			//}
		} //testHitPath
		
		public function tick (style:uint, delta:Number) : void
		{
			var e:Entity;
			
			for each (e in entities)
				e.tickThink (style, delta);
			
			for each (e in entities)
				e.tickMove (delta);
			
			for each (e in entities) {
				e.x = e.px;
				e.y = e.py;
			}
		}
		
		public function addEntity(target:Entity):void
		{
			//trace(getQualifiedClassName(target) + " - " + target.name)
			
			target.addedToLevel(this);
			//target.level = this;
			entities.push(target)
			addChildAt(target, entityLevel);
			numEntities = entities.length;
		}
		
		public function removeEntity(target:Entity):void
		{
			entities.splice(entities.indexOf(target), 1);
			removeChild(target);
			target.level = null;
			numEntities = entities.length;
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
			return areas[name] as Area;
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
		}
	}
}
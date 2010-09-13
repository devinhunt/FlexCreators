package com.creatorsproject.ui
{
	import com.creatorsproject.data.EventFloor;
	import com.creatorsproject.data.EventRoom;
	import com.creatorsproject.data.PartyData;
	import com.creatorsproject.data.PartyEvent;
	import com.creatorsproject.input.TouchController;
	import com.creatorsproject.input.events.GestureEvent;
	import com.creatorsproject.ui.transitions.AnimationController;
	import com.creatorsproject.ui.transitions.AnimationProfile;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.core.BitmapAsset;
	import mx.effects.easing.Elastic;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.AnimationEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	/**
	 * This is the UI controller and container for the map display for the touchscreens. It basically 
	 * loads and shows a number of maps on 3d planes, and allows the suer to zoom into them with a touch. 
	 * @author devin
	 * 
	 */	

	public class MapUI extends TouchUI implements ITickable
	{
		private var angle:Number = 16;
		
		[Embed(source="../media/img/chinamap/master.jpg")]
		private var _masterImage:Class;
		[Embed(source="../media/img/chinamap/map1.jpg")]
		private var _map1Image:Class;
		[Embed(source="../media/img/chinamap/map2.jpg")]
		private var _map2Image:Class;
		[Embed(source="../media/img/chinamap/map3.jpg")]
		private var _map3Image:Class;
		[Embed(source="../media/img/chinamap/map4.jpg")]
		private var _map4Image:Class;
		[Embed(source="../media/img/chinamap/map5.jpg")]
		private var _map5Image:Class;
		[Embed(source="../media/img/chinamap/map6.jpg")]
		private var _map6Image:Class;
		[Embed(source="../media/img/chinamap/map7.jpg")]
		private var _map7Image:Class;
		[Embed(source="../media/img/chinamap/map8.jpg")]
		private var _map8Image:Class;
		
		
		
		private var _partyData:PartyData;
		private var _root:DisplayObject3D;
		private var _map1:Plane;
		private var _map2:Plane;
		private var _map3:Plane;
		private var _map4:Plane;
		private var _map5:Plane;
		private var _map6:Plane;
		private var _map7:Plane;
		private var _map8:Plane;
		private var _mapMaster:Plane;
		
		private var _mapToPoint:Dictionary;
		private var _mapToPointThreshold:Number = 1000;
		
		private var _maps:Array;
		
		private var _targetMap:DisplayObject3D;
		
		private var _liveMarkers:Array;
		private var _markerCache:Array;
		
		public function MapUI(partyData:PartyData)
		{
			super();
			_partyData = partyData;
			_maps = [];
			_liveMarkers = [];
			_markerCache = [];
			assembleMapUI();
			
			this.state = "overview"; 
		}
		
		
		/**
		 * Builds the basical structure of the UI and assings the correct map images to the plane. 
		 * 
		 */				
		public function assembleMapUI():void {
			_root = new DisplayObject3D();
			
			var mat:MaterialObject3D = new BitmapMaterial((new _masterImage() as BitmapAsset).bitmapData, true);
			mat.interactive = true;
			mat.smooth = true;
			
			_mapMaster = new Plane(mat, 1000, 707, 4, 4);
			_mapMaster.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, this.onMapOverviewRelease);
			
			_map1 = new Plane(new BitmapMaterial((new _map1Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_map2 = new Plane(new BitmapMaterial((new _map2Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_map3 = new Plane(new BitmapMaterial((new _map3Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_map4 = new Plane(new BitmapMaterial((new _map4Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_map5 = new Plane(new BitmapMaterial((new _map5Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_map6 = new Plane(new BitmapMaterial((new _map6Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_map7 = new Plane(new BitmapMaterial((new _map7Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_map8 = new Plane(new BitmapMaterial((new _map8Image() as BitmapAsset).bitmapData, true), 1000, 707, 4, 4);
			_maps = [_mapMaster, _map1, _map2, _map3, _map4, _map5, _map6, _map7, _map8];
			
			_mapToPoint = new Dictionary();
			_mapToPoint[_map3] = new Point(0, 0);
			
			resetMaps();
			
			_root.addChild(_mapMaster);
			_root.addChild(_map1);
			_root.addChild(_map2);
			_root.addChild(_map3);
			_root.addChild(_map4);
			_root.addChild(_map5);
			_root.addChild(_map6);
			_root.addChild(_map7);
			_root.addChild(_map8);
			
			this.addChild(_root);
		}
		
		/**
		 * Places the maps in there correct, and default locations 
		 * 
		 */		
		public function resetMaps():void {
			var radius:Number = -2400;
			var angleStep:Number = 2 * Math.PI / _maps.length;
			
			for(var i:int = 0; i < _maps.length; i ++) {
				var d:DisplayObject3D = _maps[i];
				
				d.x = radius * Math.sin(angleStep * i);
				d.z = radius * Math.cos(angleStep * i);
				d.rotationY = angleStep * i * 180 / Math.PI;
			}
			
			if(_targetMap) {
				var ac:AnimationController = new AnimationController(300);
				ac.addEventListener(AnimationEvent.COMPLETE, onTransitionComplete)
				ac.func = Elastic.easeOut;
	
				// the map
				var ap:AnimationProfile = new AnimationProfile(_targetMap);
				ap.endScale = 1;
				ac.addAnimationProfile(ap);
				ac.start();
			}
		}
		
		// ________________________________________________ Stating and Updating
		
		/**
		 * Required by ITickable 
		 * Called during a render tick and we need to do the same to our children
		 */		
		public function tick():void {
			
			// and update the state
			switch(_state) {
				case "overview":
					var maxDelta:Number = 20;
					
					if(fling.isSwiping) {
						_root.rotationY -= fling.velocity.x / 10;
					}

					break;
				case "focus":
					break;
			}
		}
		
		/**
		 * Change the state of the UI 
		 * @param value The new state 
		 */		
		override public function set state(value:String):void {
			var oldState:String = _state;
			super.state = value;
			_state = value;
			
			trace("Map UI :: Changing to state " + value);
			
			switch(_state) {
				case "overview":
					if(oldState == "disable") {
						this.addChild(_root);
					}
				
					if(oldState == "focus" || oldState == "disable") {
						hideMarkers();
						resetMaps();
					}
					break;
				case "focus":
					centerMap();
					updateMapFocus();
					break;
			}
		}
		
		/**
		 * Alerts the UI that it is not being used, and it should clean itself up from the main stack.  
		 * 
		 */		
		override protected function disableUI():void {
			super.disableUI();
			
			this.hideMarkers();
			this.removeChild(_root);
		}
		
		
		// ________________________________________________ User Interaction
		
		override protected function onMatteClick(event:GestureEvent):void {
			if(_state == "focus") {
				this.state = "overview";
			}
		}
		
		private function onMapOverviewRelease(event:InteractiveScene3DEvent):void {
			if(TouchController.me.state == "touching" && _state == "overview") {
				var referingMap:DisplayObject3D = getMapClick(event.x, event.y);
				
				if(referingMap) {
					_targetMap = referingMap;
					this.state = "focus";
				}
				
				//_targetMap = event.target as DisplayObject3D;
				//this.state = "focus";
			}
		}
		
		private function getMapClick(x:Number, y:Number):DisplayObject3D {
			var click:Point = new Point(x, y);
			for(var map:Object in _mapToPoint) {
				var test:Point = _mapToPoint[map];
				if((click.x - test.x) * (click.x - test.x) + (click.y - test.y) * (click.y - test.y) <= _mapToPointThreshold){
					return map as DisplayObject3D;
				}
			}
			return null;
		}
		
		// ________________________________________________ Focus Loading and Updating
		
		private function centerMap():void {
			var ac:AnimationController = new AnimationController(1000);
			ac.addEventListener(AnimationEvent.COMPLETE, onTransitionComplete)
			ac.func = Elastic.easeOut;

			// the map
			var ap:AnimationProfile = new AnimationProfile(_targetMap);
			ap.endScale = 1.2;
			ac.addAnimationProfile(ap);
			
			// the screen
			ap = new AnimationProfile(_root); 
			ac.addAnimationProfile(ap);
			ap.endRotationY = - _targetMap.rotationY;
			
			ac.start();
		}
		
		private function onTransitionComplete(event:AnimationEvent):void {
			(event.target as AnimationController).removeEventListener(AnimationEvent.COMPLETE, onTransitionComplete);
		}
		
		private function updateMapFocus():void {
			var floor:EventFloor;
			
			switch(_targetMap) {
				case _map1: floor = dirtyGetFloor("First Floor"); break;
				case _map2: floor = dirtyGetFloor("Second Floor"); break;
				case _map3: floor = dirtyGetFloor("Eighth Floor"); break;
			}
			
			var events:Array = _partyData.nextEvents;
			
			var pushx:Number = main.instance.frontUI.width / 2 - 260;
			var pushy:Number = 0;
			
			for each(var ev:PartyEvent in events) {
				var room:EventRoom = _partyData.getRoomFromId(ev.roomId);
				if(room && room.floorId == floor.id) {
					trace(room.name);
					var marker:MapMarker = this.getMarker(ev);
					marker.x = room.x / 1.22 + pushx;
					marker.y = room.y / 1.22 + pushy;
					main.instance.frontUI.addChild(marker)
					_liveMarkers.push(marker);
				}
			}
		}
		
		/**
		 * @private
		 * Simple helper function that get's the current floor from the partyData in a rather greedy manner. 
		 * @param name
		 * @return 
		 * 
		 */		
		private function dirtyGetFloor(name:String):EventFloor {
			for each(var floor:EventFloor in _partyData.floors) {
				if(floor.name == name) {
					return floor;
				}
			}
			return null;
		}
		
		// ________________________________________________ Markers
		
		private function hideMarkers():void {
			while(_liveMarkers.length > 0) {
				main.instance.frontUI.removeChild(_liveMarkers.pop());
			}
		}
		
		private function getMarker(event:PartyEvent):MapMarker {
			if(! _markerCache[event.name]) {
				_markerCache[event.name] = new MapMarker(event);
			}
			return _markerCache[event.name] as MapMarker;
		}
	}
}
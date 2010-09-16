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
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import mx.controls.Button;
	import mx.core.BitmapAsset;
	import mx.effects.easing.Elastic;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.AnimationEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * This is the UI controller and container for the map display for the touchscreens. It basically 
	 * loads and shows a number of maps on 3d planes, and allows the suer to zoom into them with a touch. 
	 * @author devin
	 * 
	 */	

	public class MapUI extends TouchUI implements ITickable
	{
		private var angle:Number = 16;
		
		[Embed(source="../media/img/chinamap/master.png")]
		private var _masterImage:Class;
		[Embed(source="../media/img/chinamap/Beijing_House.png")]
		private var _map1Image:Class;
		[Embed(source="../media/img/chinamap/Art_Bridge.png")]
		private var _map2Image:Class;
		[Embed(source="../media/img/chinamap/798_Space.png")]
		private var _map3Image:Class;
		[Embed(source="../media/img/chinamap/1st_Factory.png")]
		private var _map4Image:Class;
		[Embed(source="../media/img/chinamap/Beyond_Art.png")]
		private var _map5Image:Class;
		[Embed(source="../media/img/chinamap/Pu_Gallery.png")]
		private var _map6Image:Class;
		[Embed(source="../media/img/chinamap/T_Art_1.png")]
		private var _map7Image:Class;
		[Embed(source="../media/img/chinamap/T_Art_2.png")]
		private var _map8Image:Class;
		
		
		private var closeButton:Button;
		
		private var _partyData:PartyData;
		private var _root:DisplayObject3D;
		private var _map1:MapPlane;
		private var _map2:MapPlane;
		private var _map3:MapPlane;
		private var _map4:MapPlane;
		private var _map5:MapPlane;
		private var _map6:MapPlane;
		private var _map7:MapPlane;
		private var _map8:MapPlane;
		private var _mapMaster:MapPlane;
		
		private var _minTheta:Number = 0;
		private var _maxTheta:Number = 8 / 8 * 180;
		
		private var _mapToPoint:Dictionary;
		private var _mapToPointThreshold:Number = 1000;
		
		private var _maps:Array;
		
		private var _targetMap:MapPlane;
		
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
			
			_mapMaster = new MapPlane(onMapOverviewRelease, mat, 771, 800, 4, 4);

			
			_map1 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map1Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			_map2 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map2Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			_map3 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map3Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			_map4 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map4Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			_map5 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map5Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			_map6 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map6Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			_map7 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map7Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			_map8 = new MapPlane(onMapOverviewRelease, new BitmapMaterial((new _map8Image() as BitmapAsset).bitmapData, true), 545, 800, 4, 4);
			
			_maps = [_mapMaster, _map1, _map2, _map3, _map4, _map5, _map6, _map7, _map8];
			
			for each(var map:MapPlane in _maps) {
				map.scale = .8;
			}
			
			_map1.order = 2;
			_map2.order = 3;
			_map3.order = 4;
			_map4.order = 5;
			_map5.order = 6;
			_map6.order = 7;
			_map7.order = 8;
			_map8.order = 9;
			
			_map1.masterLocation = new Point(625, 261);
			_map2.masterLocation = new Point(310, 418);
			_map3.masterLocation = new Point(344, 508);
			_map4.masterLocation = new Point(722, 100);
			_map5.masterLocation = new Point(453, 381);
			_map6.masterLocation = new Point(296, 624);
			_map7.masterLocation = new Point(36, 273);
			_map8.masterLocation = new Point(136, 273);
			
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
			
			// close button
			closeButton = new Button();
			closeButton.width = 80;
			closeButton.height = 80;
			closeButton.styleName = "touchButton";
			closeButton.setStyle("horizontalCenter", 272);
			closeButton.setStyle("verticalCenter", -254);
			closeButton.label = "X";
			closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
		}
		
		/**
		 * Places the maps in there correct, and default locations 
		 * 
		 */		
		public function resetMaps():void {
			var radius:Number = -2500;
			var angleStep:Number = (_maxTheta - _minTheta) / _maps.length;
			
			for(var i:int = 0; i < _maps.length; i ++) {
				var d:DisplayObject3D = _maps[i];
				
				d.x = radius * Math.sin(- angleStep * i * Math.PI / 180);
				d.z = radius * Math.cos(- angleStep * i * Math.PI / 180);
				d.rotationY = - angleStep * i;
			}
			
			if(_targetMap) {
				var ac:AnimationController = new AnimationController(300);
				ac.addEventListener(AnimationEvent.COMPLETE, onTransitionComplete)
				ac.func = Elastic.easeOut;
	
				// the map
				var ap:AnimationProfile = new AnimationProfile(_targetMap);
				ap.endScale = .8;
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
					
					if(fling.isFlinging && _root.rotationY >= _minTheta && _root.rotationY <= _maxTheta)  {
						_root.rotationY += - fling.velocity.x / 10;
					} else {
						if(_root.rotationY < _minTheta) {
							_root.rotationY += (_minTheta - _root.rotationY) / 2 - fling.velocity.x / 10;
						} else if(_root.rotationY > _maxTheta) {
							_root.rotationY += (_maxTheta - _root.rotationY) / 2 - fling.velocity.x / 10;
						}
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
						if(main.instance.frontUI.contains(this.closeButton)) {
							main.instance.frontUI.removeChild(this.closeButton);
						}
						
						hideMarkers();
						resetMaps();
					}
					break;
				case "focus":
					main.instance.frontUI.addChild(this.closeButton);
					if(_targetMap == _mapMaster) {
						closeButton.setStyle("horizontalCenter", 370);
					} else {
						closeButton.setStyle("horizontalCenter", 274);
					}
					
					
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
			
			if(main.instance.frontUI.contains(this.closeButton)) {
				main.instance.frontUI.removeChild(this.closeButton);
			}
			this.hideMarkers();
			this.removeChild(_root);
		}
		
		
		// ________________________________________________ User Interaction
		
		override protected function onMatteClick(event:GestureEvent):void {
			if(_state == "focus") {
				this.state = "overview";
			}
		}
		
		private function onCloseClick(event:MouseEvent):void {
			if(_state == "focus") {
				this.state = "overview";
			}
		}
		
		private function onMapOverviewRelease(event:InteractiveScene3DEvent):void {
			if(TouchController.me.state == "touching" && _state == "overview") {
				var referingMap:DisplayObject3D = getMapClick(event.x, event.y);
				
				if(referingMap) {
					_targetMap = referingMap as MapPlane;
				} else {
					_targetMap = event.target as MapPlane;
				}
				
				this.state = "focus";
			} else if(_state == "focus" && _targetMap == _mapMaster) {
				referingMap = getMapClick(event.x, event.y);
				
				if(referingMap) {
					hideMarkers();
					resetMaps();
					_targetMap = referingMap as MapPlane;
					this.state = "focus";
				}
			}
		}
		
		private function getMapClick(x:Number, y:Number):DisplayObject3D {
			var click:Point = new Point(x, y);
			for each(var map:MapPlane in _maps) {
				var test:Point = map.masterLocation;
				if(test && (click.x - test.x) * (click.x - test.x) + (click.y - test.y) * (click.y - test.y) <= _mapToPointThreshold){
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
			ap.endScale = 1;
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
			var floor:EventFloor = _partyData.getFloorFromOrder(_targetMap.order);
			
			if(! floor) {
				return;
			}
			
			var events:Array = _partyData.nextEvents;
			
			var pushx:Number = main.instance.frontUI.width / 2 - 250;
			var pushy:Number = main.instance.frontUI.height / 2 - 350;
			
			for each(var ev:PartyEvent in events) {
				var room:EventRoom = _partyData.getRoomFromId(ev.roomId);
				if(room && room.floorId == floor.id) {
					var marker:MapMarker = this.getMarker(ev);
					marker.x = pushx + (room.x + room.width / 2) * .8;
					marker.y = pushy + (room.y + room.height / 2) * .8;
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
package com.creatorsproject.ui
{
	import com.creatorsproject.data.EventFloor;
	import com.creatorsproject.data.EventRoom;
	import com.creatorsproject.data.PartyData;
	import com.creatorsproject.data.PartyEvent;
	import com.creatorsproject.input.TouchController;
	import com.creatorsproject.ui.transitions.AnimationController;
	import com.creatorsproject.ui.transitions.AnimationProfile;
	
	import mx.core.BitmapAsset;
	import mx.effects.easing.Elastic;
	
	import org.papervision3d.events.AnimationEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;

	public class MapUI extends TouchUI implements ITickable
	{
		private var angle:Number = 16;
		
		private var _state:String;
		
		private var _partyData:PartyData;
		private var _root:DisplayObject3D;
		private var _map1:Plane;
		private var _map2:Plane;
		private var _map3:Plane;
		
		[Embed(source="../media/img/map1.png")]
		private var _map1Image:Class;
		[Embed(source="../media/img/map2.png")]
		private var _map2Image:Class;
		[Embed(source="../media/img/map3.png")]
		private var _map3Image:Class;
		
		private var _targetMap:DisplayObject3D;
		
		private var _liveMarkers:Array;
		private var _markerCache:Array;
		
		public function MapUI(partyData:PartyData)
		{
			super(fling);
			_partyData = partyData;
			assembleMapUI();
			
			_liveMarkers = [];
			_markerCache = [];
			
			this.state = "overview"; 
		}
		
		public function assembleMapUI():void {
			_root = new DisplayObject3D();
			
			var rad:Number = -2200;
			
			var mat:BitmapMaterial = new BitmapMaterial((new _map1Image() as BitmapAsset).bitmapData, true)
			mat.interactive = true;
			_map1 = new Plane(mat, 612, 856, 4, 4);
			
			mat = new BitmapMaterial((new _map2Image() as BitmapAsset).bitmapData, true)
			mat.interactive = true;
			_map2 = new Plane(mat, 612, 856, 4, 4);
			
			mat = new BitmapMaterial((new _map3Image() as BitmapAsset).bitmapData, true)
			mat.interactive = true;
			_map3 = new Plane(mat, 612, 856, 4, 4);
			
			_map1.x = rad * Math.sin(angle * Math.PI / 180);
			_map1.z = rad * Math.cos(angle * Math.PI / 180);
			_map1.rotationY = angle;
			_map1.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, this.onMapOverviewRelease);
			
			_map2.x = rad * Math.sin(0 * Math.PI / 180);
			_map2.z = rad * Math.cos(0 * Math.PI / 180);
			_map2.rotationY = 0;
			_map2.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, this.onMapOverviewRelease);
			
			_map3.x = rad * Math.sin(-angle * Math.PI / 180);
			_map3.z = rad * Math.cos(-angle * Math.PI / 180);
			_map3.rotationY = -angle;
			_map3.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, this.onMapOverviewRelease);
			
			_root.addChild(_map1);
			_root.addChild(_map2);
			_root.addChild(_map3);
			
			this.addChild(_root);
		}
		
		// ________________________________________________ Stating and Updating
		
		/**
		 * Required by ITickable 
		 * Called during a render tick and we need to do the same to our children
		 * TEMP TODO :: Do it to the kiddies
		 */		
		public function tick():void {
			
			// and update the state
			switch(_state) {
				case "overview":
					var maxDelta:Number = 20;	
					if(fling.isSwiping) {
						_root.rotationY -= (fling.velocity.x / 10) * Math.max(0, (maxDelta - Math.abs(_root.rotationY)) / maxDelta);
					} else {
						_root.rotationY -= _root.rotationY / 5;
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
		public function set state(value:String):void {
			var oldState:String = _state;
			_state = value;
			
			trace("Map UI :: Changing to state " + value);
			
			switch(_state) {
				case "overview":
					break;
				case "focus":
					centerMap();
					updateMapFocus();
					break;
			}
		}
		
		// ________________________________________________ User Interaction
		
		private function onMapOverviewRelease(event:InteractiveScene3DEvent):void {
			if(TouchController.me.state == "touching" && _state == "overview") {
				_targetMap = event.target as DisplayObject3D;
				this.state = "focus";
			}
		}
		
		// ________________________________________________ Focus Loading and Updating
		
		private function centerMap():void {
			var ac:AnimationController = new AnimationController(300);
			ac.addEventListener(AnimationEvent.COMPLETE, onTransitionComplete)
			ac.func = Elastic.easeOut;

			// the map
			var ap:AnimationProfile = new AnimationProfile(_targetMap);
			ap.endScale = 1.6;
			ac.addAnimationProfile(ap);
			
			// the screen
			ap = new AnimationProfile(_root); 
			ac.addAnimationProfile(ap);
			switch(_targetMap) {
				case _map1:
					ap.endRotationY = -angle;
					break;
				case _map2:
					ap.endRotationY = 0;
					break;
				case _map3:
					ap.endRotationY = angle;
					break;
			}
			
			ac.start();
		}
		
		private function onTransitionComplete(event:AnimationEvent):void {
			
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
					var marker:MapMarker = this.getMarker(ev.name);
					marker.x = room.x / 1.22 + pushx;
					marker.y = room.y / 1.22 + pushy;
					main.instance.frontUI.addChild(marker)
				}
			}
		}
		
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
		
		private function getMarker(label:String):MapMarker {
			if(! _markerCache[label]) {
				_markerCache[label] = new MapMarker(label, "");
			}
			return _markerCache[label] as MapMarker;
		}
	}
}
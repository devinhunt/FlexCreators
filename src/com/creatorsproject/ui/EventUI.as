package com.creatorsproject.ui
{
	import com.creatorsproject.data.DataConstants;
	import com.creatorsproject.data.EventFloor;
	import com.creatorsproject.data.EventRoom;
	import com.creatorsproject.data.PartyData;
	import com.creatorsproject.data.PartyEvent;
	import com.creatorsproject.geom.TileBand;
	import com.creatorsproject.input.TouchController;
	import com.creatorsproject.input.events.GestureEvent;
	import com.creatorsproject.ui.chips.EventDetailChip;
	import com.creatorsproject.ui.transitions.AnimationController;
	import com.creatorsproject.ui.transitions.AnimationProfile;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.controls.Button;
	import mx.effects.easing.Elastic;
	
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.events.AnimationEvent;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * The master controller and display for the Event UI. The event UI is made up of a series of TileBands, 
	 * which are textured with movieclips that are genereated dynamically.  
	 * @author devin
	 * 
	 */	
	
	public class EventUI extends TouchUI implements ITickable
	{
		
		public static const CURVE_RADIUS:Number = 3000;
		
		private var _root:DisplayObject3D;
		
		/** The schedule model we're displaying */
		private var _schedule:PartyData;
		
		private var _widthPerHour:Number = 280;
		private var _bandHeight:Number = 300;
		private var _roomBandHeight:Number = 100;
		
		/** Step to divide the grid by, in hours */
		private var _timeGranularity:Number = .5;
		
		/** The curve that schedule tiles follow */
		private var _curve:Array;
		private var _rootThetaOffset:Number = 100;
		private var _minTheta:Number = 0;
		private var _maxTheta:Number = 0;
		
		/** The 3D root schedule of floor bands */
		private var _floorBands:DisplayObject3D;
		
		/** The 3D root of the room schedule */
		private var _roomBands:DisplayObject3D;
		
		/** The 3D object that show time */
		private var _timeBand:DisplayObject3D;
		
		/** Current items in the front UI */
		private var _liveMarkers:Array;
		
		/** cache of all the markers we've built */
		private var _markerCache:Object;
		
		/** cache of all the room schedule bands */
		private var _tilebandCache:Object;
		
		/** The floor we're expanding on */
		private var _targetFloorBand:TileBand;
		
		/** The data that the click on the room band represents */
		private var _targetEventData:PartyEvent;
		
		/** The display object for the event details. This will go on the Front UI plane */
		private var _detailChip:EventDetailChip;
		
		private var _backButton:Button;
		
		/**
		 * Default Constructor 
		 * 
		 */		
		public function EventUI(schedule:PartyData)
		{
			super();
			this.name = "Event Module";
			_schedule = schedule;
			_liveMarkers = [];
			_detailChip = new EventDetailChip();
			_detailChip.addEventListener(Event.CLOSE, onChipCloseRequest);
			_tilebandCache = new Object();
			_markerCache = new Object();
			
			_root = new DisplayObject3D();
			this.addChild(_root);
			_root.rotationY = _rootThetaOffset + _minTheta;
			_root.z = 500;
			
			_backButton = new Button();
			_backButton.label = "BACK";
			//_backButton.setStyle("top", 10);
			//_backButton.setStyle("left", 10);
			_backButton.x = 70;
			_backButton.y = 70;
			_backButton.setStyle("right", 10);
			_backButton.styleName = "touchButton";
			_backButton.addEventListener(MouseEvent.CLICK, onBackClick);
			
			// things we should only need to do once
			this.buildCurve();
			this.assembleTimeUI();
			this.assembleFloorUI();
			this.state = "floors";
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
				case "floors":
				case "rooms":
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
			
			trace("Event UI :: Changing to state " + value);
			
			switch(_state) {
				case "floors":
					_targetFloorBand = null;
					
					if(oldState == "disable") {
						this.addChild(_root);
						try {
						this.roomToFloorAnimation();
						} catch(error:Error) {
							// pass;
						}
					}
					
					if(_backButton.visible) {
						
					}
					
					hideMarkers();
					
					var names:Array = [];
					for each(var floor:EventFloor in _schedule.floors) {
						names.push(floor.name);
					}
					
					showMarkers(names);
					
					_root.removeChild(_roomBands);
					_root.addChild(_floorBands);
					break;
				case "floorSelect":
					this.assembleRoomUI(_targetFloorBand.data as EventFloor);
					this.state = "floorToRoom";
					break;
				case "floorToRoom":
					_root.addChild(_roomBands);
					this.floorToRoomAnimation();
					//this.state = "rooms";
					break;
				case "rooms":
					// TEMP TODO :: Need to be smarter about adding / removing these bands
					hideMarkers();
					
					var roomNames:Array = [];
					for each(var room:EventRoom in (_targetFloorBand.data as EventFloor).rooms) {
						roomNames.push(room.name);
					}
					
					showMarkers(roomNames, 70);
					main.instance.frontUI.addChild(_backButton);
					_root.removeChild(_floorBands);
					break;
				case "roomToFloor":
					_root.addChild(_floorBands);
					this.roomToFloorAnimation();
					
					main.instance.frontUI.removeChild(_backButton);
					
					break;
				case "eventDetail":
					_detailChip.eventData  = _targetEventData;
					main.instance.frontUI.addChild(_detailChip);
					break;
			}
		}
		
		override protected function disableUI():void {
			super.disableUI();
			
			if(main.instance.frontUI.contains(_backButton)) {
				main.instance.frontUI.removeChild(_backButton);
			}
			
			this.hideMarkers();
			this.removeChild(_root);
		}
		
		// ________________________________________________ User Interaction

		override protected function onMatteClick(event:GestureEvent):void {
			super.onMatteClick(event);
			switch(_state) {
				case "rooms":
					// exit out of the rooms view
					this.state = "roomToFloor";
					break;
				case "eventDetail":
					onChipCloseRequest();
					break;
			}
		}
		
		private function onFloorBandRelease(event:InteractiveScene3DEvent):void {
			if(TouchController.me.state == "touching" && _state == "floors") {
				_targetFloorBand = event.target as TileBand;
				this.state = "floorSelect";
			}
		}
		
		/**
		 * Our Room band has been licked properly. Start showing an event chip 
		 * @param event
		 * 
		 */		
		private function onRoomBandRelease(event:InteractiveScene3DEvent):void {
			/*
			if(TouchController.me.state == "touching" && _state == "rooms") {
				var band:TileBand = event.target as TileBand;
				var data:EventRoom = band.data as EventRoom;
				
				for each(var e:PartyEvent in data.events) {
					var startHr:Number = (e.startTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					var endHr:Number = (e.endTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					
					if(startHr * _widthPerHour <= event.x && endHr * _widthPerHour >= event.x) {
						_targetEventData = e;
						this.state = "eventDetail";
						break;
					}
				}
			}
			*/
		}
		
		private function onBackClick(event:MouseEvent):void {
			if(_state == "rooms") {
				this.state = "roomToFloor";
			}
		}
		
		private function onChipCloseRequest(event:Event = null):void {
			if(_state == "eventDetail") {
				main.instance.frontUI.removeChild(_detailChip);
				this.state = "rooms";
			}
		}
		
		// ________________________________________________ Building UI
		
		protected function assembleTimeUI():void {
			_timeBand = new DisplayObject3D();
			
			var tex:MovieClip = this.makeTimeTexutre();
			var mat:MovieMaterial = new MovieMaterial(tex);
			mat.smooth = true;
			
			var timeline:TileBand = new TileBand(mat, _curve, 80);
			
			_timeBand.addChild(timeline);
			_timeBand.y = 200;
			_root.addChild(_timeBand);
		}
		 
		protected function assembleFloorUI():void {
			
			if(! _floorBands) {
				_floorBands = new DisplayObject3D();
			}
			
			var spacing:Number = _bandHeight + 5; 
			
			for(var f:int = 0; f < _schedule.floors.length; f ++) {
				var band:TileBand = this.getFloorBand(_schedule.floors[f]);
				band.y = (spacing * (_schedule.floors.length - 1) / 2) - spacing * f - (spacing / 2);
				band.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, this.onFloorBandRelease);
				_floorBands.addChild(band);
			}
		}
		
		protected function assembleRoomUI(floor:EventFloor):void {
			if(!_roomBands) {
				_roomBands = new DisplayObject3D();
			}
			
			var kids:Object = _roomBands.children;
			for each(var kid:DisplayObject3D in kids) {
				_roomBands.removeChild(kid);
			}
			
			var spacing:Number = _roomBandHeight + 5;
			
			for(var r:int = 0; r < floor.rooms.length; r ++) {
				var band:TileBand = this.getRoomBand(floor.rooms[r], DataConstants.roomColors[floor.name], DataConstants.floorColors[floor.name]);
				band.y = (spacing * (floor.rooms.length - 1) / 2) - spacing * r - (spacing / 2);
				_roomBands.addChild(band);
			}
		}
		
		protected function getFloorBand(floor:EventFloor):TileBand {
			if(! _tilebandCache[floor.name + floor.id]) {
				var tex:MovieClip = this.makeFloorTexture(floor, _bandHeight);
				var mat:MovieMaterial = new MovieMaterial(tex, false, false, true);
				mat.smooth = true;
				mat.interactive = true;
				var band:TileBand = new TileBand(mat, _curve, _bandHeight);
				band.data = floor;
				_tilebandCache[floor.name + floor.id] = band;
			}
			
			return _tilebandCache[floor.name + floor.id];
		}
		
		protected function getRoomBand(room:EventRoom, color:uint = 0xff00ff, floorColor:uint = 0xff00ff):TileBand {
			if(! _tilebandCache[room.name + room.id]) {
				var tex:MovieClip = this.makeRoomTexture(room, _roomBandHeight, color, floorColor);
				var mat:MovieMaterial = new MovieMaterial(tex, true, false, false);
				mat.smooth = true;
				mat.interactive = true;
				var band:TileBand = new TileBand(mat, _curve, _roomBandHeight);
				band.data = room;
				band.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, this.onRoomBandRelease);
				_tilebandCache[room.name + room.id] = band;
			}
			return _tilebandCache[room.name + room.id];
		}
		
		/**
		 * Builds a long texture to be applied to a solid plane 
		 * @param floor The floor to show the room events with
		 * @param texHeight The height the texture needs to be
		 * @return The texture
		 * 
		 */		
		private function makeFloorTexture(floor:EventFloor, texHeight:Number = 100):MovieClip {
			var tex:MovieClip = new MovieClip();
			var heightPerRoom:Number = texHeight / floor.rooms.length;
			
			
			var floorColor:uint = DataConstants.floorColors[floor.name];
			var roomColor:uint = DataConstants.roomColors[floor.name];
			
			tex.graphics.beginFill(floorColor, .3);
			tex.graphics.drawRect(0, 0, _schedule.totalHours * _widthPerHour, texHeight);
			tex.graphics.endFill(); 
			
			for(var r:int = 0; r < floor.rooms.length; r++) {
				this.drawRoomTex(tex, floor.rooms[r], (texHeight / floor.rooms.length) * r, (texHeight / floor.rooms.length), floorColor);
			}
			
			return tex;
		}
		
		/**
		 * Creates a texture to be applied to a room band 
		 * @param room The room we're displaying with this texture
		 * @param texHeight The height of the texture
		 * @return 
		 * 
		 */		
		private function makeRoomTexture(room:EventRoom, texHeight:Number = 100, color:uint = 0xff00ff, floorColor:uint = 0xff00ff):MovieClip {
			var tex:MovieClip = new MovieClip();
			tex.graphics.beginFill(floorColor, .3);
			tex.graphics.drawRect(0, 0, _schedule.totalHours * _widthPerHour, texHeight);
			tex.graphics.endFill(); 
			
			this.drawRoomTex(tex, room, 0, texHeight, floorColor);
			
			return tex;
		}
		
		private function drawRoomTex(parent:MovieClip, room:EventRoom, top:Number, height:Number, color:uint = 0xff00ff):void {
			var g:Graphics = parent.graphics;
			var spacing:Number = 4;
			for(var e:int = 0; e < room.events.length; e ++) {
				var event:PartyEvent = room.events[e];
					var startHr:Number = (event.startTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					var endHr:Number = (event.endTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					
					g.beginFill(color);
					g.drawRoundRect(startHr * _widthPerHour + spacing, 
											top + spacing, 
											(endHr - startHr) * _widthPerHour - (spacing * 2),
											height - (spacing * 2), 3);
					g.endFill();
					
					
					var text:TextField = new TextField();
					text.htmlText = event.name;
					
					var format:TextFormat = new TextFormat("Neo Sans Intel", 24, 0xffffff);
					text.setTextFormat(format);
					text.width = (endHr - startHr) * _widthPerHour - 10;
					text.height = height / 2 + 10;
					
					text.x = startHr * _widthPerHour + 15;
					text.y = top + height / 2 - text.textHeight / 2;
					
					
					parent.addChild(text); 
			}
		}
		
		private function makeTimeTexutre():MovieClip {
			var totalTicks:int = _schedule.totalHours;
			
			var tex:MovieClip = new MovieClip();
			var g:Graphics = tex.graphics;
			
			g.beginFill(0xffffff);
			g.drawRect(0, 0, _schedule.totalHours * _widthPerHour, 80);
			g.endFill(); 
			
			var startPush:Number = _schedule.startDate.minutes / 60;
			var startHr:Number = _schedule.startDate.hours;
			
			for(var t:int = 0; t < totalTicks; t ++) {
				var text:TextField = new TextField();
				
				/*
				if((startHr + t) % 24 < 10) {
					text.htmlText = "0" + (startHr + t) % 12 + ":00";
				} else {
					text.htmlText = (startHr + t) % 12 + ":00";
				}
				*/
				text.htmlText = (startHr + t) % 24 + ":00";
				
				text.height = 70;
				text.y = 10;
				text.x = (t + startPush) * _widthPerHour;
					
				var format:TextFormat = new TextFormat("Neo Sans Intel", 36);
				text.setTextFormat(format);
				tex.addChild(text);
			}
			
			return tex;
		}
		
		// ________________________________________________ UI Transitions
		private function onTransitionComplete(event:AnimationEvent):void {
			var ac:AnimationController = event.target as AnimationController;
			ac.removeEventListener(AnimationEvent.COMPLETE, onTransitionComplete);
			ac.breakdown();
			
			switch(_state) {
				case "floorToRoom":
					state = "rooms";
					break;
				case "roomToFloor":
					state = "floors";
					break;
			}
		}
		
		private function floorToRoomAnimation():void {
			var ac:AnimationController = new AnimationController(300);
			ac.func = Elastic.easeOut;
			
			for each(var band:TileBand in _floorBands.children) {
				var ap:AnimationProfile = new AnimationProfile(band);
				ap.startScale = 1;
				ap.endScale = .5;
				ac.addAnimationProfile(ap);
			}
			
			for each(band in _roomBands.children) {
				ap = new AnimationProfile(band);
				ap.startScale = 1.5;
				ap.endScale = 1;
				ac.addAnimationProfile(ap);
			}
			ac.addEventListener(AnimationEvent.COMPLETE, onTransitionComplete);
			ac.start();
		}
		
		private function roomToFloorAnimation():void {
			var ac:AnimationController = new AnimationController(300);
			ac.func = Elastic.easeOut;
			
			for each(var band:TileBand in _floorBands.children) {
				var ap:AnimationProfile = new AnimationProfile(band);
				ap.endScale = 1;
				ac.addAnimationProfile(ap);
			}
			
			for each(band in _roomBands.children) {
				ap = new AnimationProfile(band);
				ap.endScale = 1.5;
				ac.addAnimationProfile(ap);
			}
			ac.addEventListener(AnimationEvent.COMPLETE, onTransitionComplete);
			ac.start();
		}
		
		// ________________________________________________ Curve Genereation
		
		private function buildCurve():void {
			var curve:Array = [];
			var totalHours:Number = _schedule.totalHours;
			
			var segments:int = int(totalHours / _timeGranularity);
			var radius:Number = CURVE_RADIUS;
			var step:Number = Math.atan2(_widthPerHour * _timeGranularity, radius);
			
			_minTheta = _rootThetaOffset;
			_maxTheta = segments * step * 180 / Math.PI + (180 - _rootThetaOffset);
			
			for (var seg:int = 0; seg < segments + 1; seg ++) {
				curve.push(new Vertex3D(radius * Math.cos(step * seg), 0, radius * Math.sin(step * seg)));
			}
			
			_curve = curve;
		}
		
		/**
		 * Finds the closets curve index that cooresponds to the time 
		 * @param time The time to compare against
		 */		
		private function getCurveIndex(time:Date):Number {
			var hours:Number = (time.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
			return Math.max(0, Math.min(_curve.length - 1, hours / _timeGranularity));
		}
		
		// ________________________________________________ Markers
		
		/**
		 * Displays markers on the front UI for the current display 
		 * @param labels The names of the markers to show
		 */		
		private function showMarkers(labels:Array, spacing:Number = 150):void {
			for(var i:int = 0; i < labels.length; i ++) {
				var marker:ScheduleMarker = getMarker(labels[i]);
				
				marker.x = 10;
				marker.y = (main.instance.frontUI.height / 2) - (spacing * (labels.length - 1) / 2) + spacing * i - 20;
				
				_liveMarkers.push(marker);
				main.instance.frontUI.addChild(marker);
			}
		}
		
		private function hideMarkers():void {
			while(_liveMarkers.length > 0) {
				var marker:DisplayObject = _liveMarkers.pop();
				if(main.instance.frontUI.contains(marker)) {
					main.instance.frontUI.removeChild(_liveMarkers.pop());
				}
			}
		}
		
		private function getMarker(label:String):ScheduleMarker {
			if(! _markerCache[label]) {
				_markerCache[label] = new ScheduleMarker(label);
			}
			return _markerCache[label] as ScheduleMarker;
		}		
	}
}
package com.creatorsproject.ui
{
	import com.creatorsproject.data.EventFloor;
	import com.creatorsproject.data.EventRoom;
	import com.creatorsproject.data.PartyData;
	import com.creatorsproject.data.ScheduleEvent;
	import com.creatorsproject.geom.TileBand;
	import com.creatorsproject.input.TouchController;
	
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class EventUI extends TouchUI implements ITickable
	{
		
		/** The schedule model we're displaying */
		private var _schedule:PartyData;
		
		private var _widthPerHour:Number = 300;
		private var _bandHeight:Number = 200;
		
		/** Step to divide the grid by, in hours */
		private var _timeGranularity:Number = .5;
		
		/** The curve that schedule tiles follow */
		private var _curve:Array;
		
		/** The 3D root schedule of floor bands */
		private var _floorBands:DisplayObject3D;
		
		/** The 3D root of the room schedule */
		private var _roomBands:DisplayObject3D;
		
		/** Current items in the front UI */
		private var _liveMarkers:Array;
		
		/** cache of all the markers we've built */
		private var _markerCache:Object;
		
		/** cache of all the room schedule bands */
		private var _tilebandCache:Object;
		
		/** current state of the schedule ui */
		private var _state:String;
		
		/** The floor we're expanding on */
		private var _targetFloorBand:TileBand;
		
		/**
		 * Default Constructor 
		 * 
		 */		
		public function EventUI(schedule:PartyData)
		{
			super();
			_schedule = schedule;
			_liveMarkers = [];
			_tilebandCache = new Object();
			_markerCache = new Object();
			
			// things we should only need to do once
			this.buildCurve();
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
					if(fling.isSwiping) {
						this.rotationY += - fling.velocity.x / 10;
					}
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
			
			trace("Event UI :: Changing to state " + value);
			
			switch(_state) {
				case "floors":
					_targetFloorBand = null;
					this.removeChild(_roomBands);
					this.addChild(_floorBands);
					break;
				case "floorSelect":
					this.assembleRoomUI(_targetFloorBand.data as EventFloor);
					this.state = "floorToRoom";
					break;
				case "floorToRoom":
					this.state = "rooms";
					break;
				case "rooms":
					this.removeChild(_floorBands);
					this.addChild(_roomBands);
					break;
				case "roomToFloor":
					this.state = "floors"
					break;
			}
		}
		
		// ________________________________________________ User Interaction

		override protected function onMatteClick(event:MouseEvent):void {
			super.onMatteClick(event);
			switch(_state) {
				case "rooms":
					trace(TouchController.me.state);
					if(TouchController.me.state != "swipe") {
						this.state = "roomToFloor";
					}
					break;
			}
		}
		
		
		private function onFloorBandRelease(event:InteractiveScene3DEvent):void {
			if(TouchController.me.state == "touching") {
				_targetFloorBand = (event.target as TileBand) as TileBand;
				this.state = "floorSelect";
			}
		}
		
		// ________________________________________________ Building UI 
		protected function assembleFloorUI():void {
			
			if(! _floorBands) {
				_floorBands = new DisplayObject3D();
			}			
			
			for(var f:int = 0; f < _schedule.floors.length; f ++) {
				var band:TileBand = this.getFloorBand(_schedule.floors[f]);
				band.y = -205 * f;
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
			
			for(var r:int = 0; r < floor.rooms.length; r ++) {
				var band:TileBand = this.getRoomBand(floor.rooms[r]);
				
				band.y = -205 * r;
				_roomBands.addChild(band);
			}
		}
		
		protected function getFloorBand(floor:EventFloor):TileBand {
			if(! _tilebandCache[floor.name]) {
				var tex:MovieClip = this.makeFloorTexture(floor, _bandHeight);
				var mat:MovieMaterial = new MovieMaterial(tex, false, false, true);
				mat.smooth = true;
				mat.interactive = true;
				mat.oneSide = false;
				var band:TileBand = new TileBand(mat, _curve, _bandHeight);
				band.data = floor;
				_tilebandCache[floor.name] = band;
			}
			
			return _tilebandCache[floor.name];
		}
		
		protected function getRoomBand(room:EventRoom):TileBand {
			if(! _tilebandCache[room.name]) {
				var tex:MovieClip = this.makeRoomTexture(room, _bandHeight);
				var mat:MovieMaterial = new MovieMaterial(tex, false, false, true);
				mat.smooth = true;
				mat.interactive = true;
				mat.oneSide = false;
				var band:TileBand = new TileBand(mat, _curve, _bandHeight);
				band.data = room;
				_tilebandCache[room.name] = band;
			}
			
			return _tilebandCache[room.name];
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
			
			tex.graphics.beginFill(0x555555);
			tex.graphics.drawRect(0, 0, _schedule.totalHours * _widthPerHour, texHeight);
			tex.graphics.endFill();
			
			for(var r:int = 0; r < floor.rooms.length; r++) {
				this.drawRoomTex(tex, floor.rooms[r], (texHeight / floor.rooms.length) * r, (texHeight / floor.rooms.length));
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
		private function makeRoomTexture(room:EventRoom, texHeight:Number = 100):MovieClip {
			var tex:MovieClip = new MovieClip();
			
			tex.graphics.beginFill(0x555555);
			tex.graphics.drawRect(0, 0, _schedule.totalHours * _widthPerHour, texHeight);
			tex.graphics.endFill();
			
			this.drawRoomTex(tex, room, 0, texHeight);
			
			return tex;
		}
		
		private function drawRoomTex(parent:MovieClip, room:EventRoom, top:Number, height:Number):void {
			var g:Graphics = parent.graphics;
			for(var e:int = 0; e < room.events.length; e ++) {
				var event:ScheduleEvent = room.events[e];
					var startHr:Number = (event.startTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					var endHr:Number = (event.endTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					
					g.beginFill(0xff00ff);
					g.drawRect(startHr * _widthPerHour, 
											top, 
											(endHr - startHr) * _widthPerHour,
											height);
					g.endFill();
					
					
					var text:TextField = new TextField();
					text.htmlText = event.name;
					text.x = startHr * _widthPerHour + 5;
					text.y = top + 5;
					text.width = (endHr - startHr) * _widthPerHour - 10;
					text.height = height - 5;
					var format:TextFormat = new TextFormat(null, 36);
					text.setTextFormat(format);
					parent.addChild(text); 
			}
		}
		
		// ________________________________________________ Curve Genereation
		
		private function buildCurve():void {
			var curve:Array = [];
			var totalHours:Number = _schedule.totalHours;
			
			var segments:int = int(totalHours / _timeGranularity);
			var radius:Number = 2000;
			var step:Number = Math.atan2(_widthPerHour * _timeGranularity, radius);
			
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
		private function showMarkers(labels:Array):void {
			for(var i:int = 0; i < labels.length; i ++) {
				var marker:ScheduleMarker = getMarker(labels[i]);
				
				marker.x = 10;
				marker.y = i * 105 + 184;
				
				_liveMarkers.push(marker);
				main.instance.frontUI.addChild(marker);
			}
		}
		
		private function hideMarkers():void {
			for each(var marker:ScheduleMarker in _liveMarkers) {
				main.instance.frontUI.removeChild(marker);
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
package com.creatorsproject.ui
{
	import com.creatorsproject.data.EventFloor;
	import com.creatorsproject.data.EventRoom;
	import com.creatorsproject.data.Schedule;
	import com.creatorsproject.data.ScheduleEvent;
	import com.creatorsproject.geom.TileBand;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class EventUI extends DisplayObject3D implements ITickable
	{
		
		/** The schedule model we're displaying */
		private var _schedule:Schedule;
		
		private var _widthPerHour:Number = 200;
		
		/** Step to divide the grid by, in hours */
		private var _timeGranularity:Number = .5;
		
		/** The curve that schedule tiles follow */
		private var _curve:Array;
		
		/** The root schedule of floor bands */
		private var _floorBands:DisplayObject3D;
		
		/** Current items in the front UI */
		private var _liveMarkers:Array;
		
		/** chache of all the markers we've built */
		private var _markers:Object;
		
		/** current state of the schedule ui */
		private var _state:String;
		
		/** The floor we're expanding on */
		private var _targetFloor:EventFloor;
		
		/**
		 * Default Constructor 
		 * 
		 */		
		public function EventUI(schedule:Schedule)
		{
			_schedule = schedule;
			_liveMarkers = [];
			_markers = new Object();
			
			this.buildFloorUI();
			this.state = "default";
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
				case "default":
					break;2
				case "floorSelect":
					break;
			}
		}
		
		private function displayFloorBands():void {
			
		}
		
		private function displayRoomBands():void {
			
		}
		
		// ________________________________________________ User Interaction
		
		private function onFloorBandClick(event:InteractiveScene3DEvent = null):void {
			if(! _targetFloor) {
				_targetFloor = (event.target as TileBand).data as EventFloor;
				this.state = "floorSelect";
			}
		}
		
		// ________________________________________________ Building UI 
		protected function buildFloorUI():void {
			// generate the curve the grid follows on
			var curve:Array = [];
			var totalHours:Number = _schedule.totalHours;
			
			var segments:int = int(totalHours / _timeGranularity);
			var radius:Number = 2000;
			var step:Number = Math.atan2(_widthPerHour * _timeGranularity, radius);
			
			for (var seg:int = 0; seg < segments + 1; seg ++) {
				curve.push(new Vertex3D(radius * Math.cos(step * seg), 0, radius * Math.sin(step * seg)));
			}
			_curve = curve;
			
			
			// build the floor bands
			_floorBands = new DisplayObject3D();
			var labels:Array = []

			for(var f:int = 0; f < _schedule.floors.length; f ++) {
				var tex:MovieClip = this.makeFloorTexture(_schedule.floors[f]);
				var mat:MovieMaterial = new MovieMaterial(tex, false, false, true);
				mat.smooth = true;
				mat.interactive = true;
				var band:TileBand = new TileBand(mat, _curve);
				
				// rough positioning
				band.y = -105 * f;
				
				band.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onFloorBandClick);
				band.data = _schedule.floors[f];
				_floorBands.addChild(band);
				labels.push((_schedule.floors[f] as EventFloor).name);
			}
			
			this.showMarkers(labels);
			this.addChild(_floorBands);
		}
		
		protected function buildRoomUI():void {
			
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
				var room:EventRoom = floor.rooms[r];
				
				for(var e:int = 0; e < room.events.length; e ++) {
					var event:ScheduleEvent = room.events[e];
					var startHr:Number = (event.startTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					var endHr:Number = (event.endTime.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
					
					tex.graphics.beginFill(0xff00ff);
					tex.graphics.drawRect(startHr * _widthPerHour, 
											(texHeight / floor.rooms.length) * r, 
											(endHr - startHr) * _widthPerHour,
											(texHeight / floor.rooms.length));
					tex.graphics.endFill();
					
					// add in the text for this bad boy
					var text:TextField = new TextField();
					text.htmlText = event.name;
					text.x = startHr * _widthPerHour + 5;
					text.y = (texHeight / floor.rooms.length) * r + 5;
					text.height = (texHeight / floor.rooms.length) - 5;
					tex.addChild(text); 
				}
			}
			
			return tex;
		}
		
		/**
		 * Finds the closets curve index that cooresponds to the time 
		 * @param time The time to compare against
		 */		
		private function getCurveIndex(time:Date):Number {
			var hours:Number = (time.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
			return Math.max(0, Math.min(_curve.length - 1, hours / _timeGranularity));
		}
		
		// ______________________________________ Markers
		
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
			if(! _markers[label]) {
				_markers[label] = new ScheduleMarker(label);
			}
			return _markers[label] as ScheduleMarker;
		}		
	}
}
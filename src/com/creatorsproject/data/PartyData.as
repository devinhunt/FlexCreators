package com.creatorsproject.data
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * Loader and organizer for the data that powers this little app. 
	 * @author devin
	 */		
	
	public class PartyData extends EventDispatcher
	{
		
		/** True if we have asked the server for a schedule */		
		private var _scheduleRequested:Boolean = false;
		
		/** True if we have recieved and parsed the latest schedule data */
		private var _sceduleRecieved:Boolean = false;
		
		private var _creatorsRecieved:Boolean = false;
		
		/** List of all individule events */
		private var _events:Array;
		
		/** List of all rooms involved in the event */
		private var _rooms:Array;
		
		/** All the floors in the party */
		private var _floors:Array;
		
		/** Creators involved with this party */
		private var _creators:Array;
		
		private var _startDate:Date;
		private var _endDate:Date;
		
		// TEMP TODO :: ^ Refactor the _**item** storage to a hashtable if order becomes unimportant
		
		// Raw data store //
		private var _rawEventData:Object;
		private var _rawRoomData:Object;
		private var _rawFloorData:Object;
		private var _rawCreatorData:Object;
		
		public function PartyData()
		{
			_events = [];
		}
		
		// ______________________________________ Data Updateting
		/**
		 * Starts the schedule building requests. The data model is requested in this order:
		 * 1) Floors
		 * 2) Rooms
		 * 3) Events
		 * And the the full schedule tree is reconsistuted. This makes the processing quick and efficient and allows
		 * us to keep our json requests to a minimum.
		 */
		public function loadData():void {
			_scheduleRequested = true;
			_creatorsRecieved = false;
			_sceduleRecieved = false;
			
			var floorLoader:URLLoader = new URLLoader();
			floorLoader.addEventListener(Event.COMPLETE, this.onFloorsReceived);
			floorLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			floorLoader.load(new URLRequest(main.URL_SERVER + main.URL_FLOOR));
			
			var creatorLoader:URLLoader = new URLLoader();
			creatorLoader.addEventListener(Event.COMPLETE, this.onCreatorsRecieved);
			creatorLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			creatorLoader.load(new URLRequest(main.URL_SERVER + main.URL_CREATOR));
		}
		
		/**
		 * JSON loaded from the server request 
		 * @param event The complete event
		 */
		public function onEventsRecieved(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onEventsRecieved);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawEventData = JSON.decode(rawData)
			_events = [];
			
			for each(var rawEvent:Object in _rawEventData) {
				_events.push(ScheduleEvent.createEventFromJson(rawEvent));
			}
			
			// associate our events with their room
			for each(var room:EventRoom in _rooms) {
				for each(var e:ScheduleEvent in _events) {
					if(e.roomId == room.id) {
						room.events.push(e);
					}
				}
			}
			
			// and set out constants;
			if(_events.length > 0) {
				var sd:Date = new Date((_events[0] as ScheduleEvent).startTime.getTime());
				var ed:Date = new Date((_events[0] as ScheduleEvent).endTime.getTime());
				
				for each(var ev:ScheduleEvent in _events) {
					if(ev.startTime.getTime() < sd.getTime()) {
						sd.setTime(ev.startTime.getTime());
					}
					
					if(ev.endTime.getTime() > ed.getTime()) {
						ed.setTime(ev.endTime.getTime());
					}
				}
				_startDate = sd
				_endDate = ed;
			}
			
			// and we're done!
			this._sceduleRecieved = true;
			if(_creatorsRecieved) {
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function onRoomsRevieved(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onRoomsRevieved);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawRoomData = JSON.decode(rawData)
			_rooms = [];
			
			for each(var rawRoom:Object in _rawRoomData) {
				_rooms.push(new EventRoom(rawRoom.pk, rawRoom.fields.name, rawRoom.fields.floor));
			}
			
			// associate the rooms with their floors 
			for each(var floor:EventFloor in _floors) {
				for each(var room:EventRoom in _rooms) {
					if(room.floorId == floor.id) {
						floor.rooms.push(room);
					}
				}
			}
			
			// and continue the data building
			var eventLoader:URLLoader = new URLLoader();
			eventLoader.addEventListener(Event.COMPLETE, this.onEventsRecieved);
			eventLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			eventLoader.load(new URLRequest(main.URL_SERVER + main.URL_SCHEDULE));
		}
		
		public function onFloorsReceived(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onFloorsReceived);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawFloorData = JSON.decode(rawData)
			_floors = [];
			
			for each(var rawFloor:Object in _rawFloorData) {
				_floors.push(new EventFloor(rawFloor.pk, rawFloor.fields.name, parseInt(rawFloor.fields.order))); 
			}
			
			var roomLoader:URLLoader = new URLLoader();
			roomLoader.addEventListener(Event.COMPLETE, this.onRoomsRevieved);
			roomLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			roomLoader.load(new URLRequest(main.URL_SERVER + main.URL_ROOM));
		}
		
		public function onCreatorsRecieved(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onCreatorsRecieved);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawCreatorData = JSON.decode(rawData)
			_creators = [];
			
			for each(var rawCreator:Object in _rawCreatorData) {
				_creators.push(new Creator(rawCreator));
			}
			
			this._creatorsRecieved = true;
			if(_sceduleRecieved) {
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		/**
		 * Oh shit something went wrong with the JSON request
		 * @param event
		 */		
		public function onJsonIOError(event:Event):void {
			trace("There has been an IOError");
			this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		// ------------------------------------------------ Getters and Setters
		public function get startDate():Date {
			return _startDate;
		}
		
		public function get endDate():Date {
			return _endDate;
		}
		
		/**
		 * Returns the total number of hours that party scehedule spans 
		 * 
		 */		
		public function get totalHours():Number {
			return (_endDate.getTime() - _startDate.getTime()) / 1000 / 60 / 60;
		}
		
		public function get floors():Array { return _floors; }
		public function get rooms():Array { return _rooms; }
		public function get events():Array { return _events; }
		public function get creators():Array { return _creators; }
	}
}
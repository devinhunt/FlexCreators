package com.creatorsproject.data
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;

	/**
	 * Loader and organizer for the data that powers this little app. 
	 * @author devin
	 */		
	
	public class PartyData extends EventDispatcher
	{
		
		/** Interval (in milliseconds) that we check for new statuses */
		public static const REFRESH_TIME:int = 10000;
		
		/** The maximum number of status we'll keep in local memory */
		public static const MAX_STATUS:int = 20;
		
		public static const MAX_PHOTOS:int = 40;
		
		/** Are we pulling live updates ? */
		private var _isLiveUpdating:Boolean = false;
		private var _liveTimer:Timer;
		
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
		
		/** All the creators chips */
		private var _chips:Array;
		
		/** All the videos we have */
		private var _videos:Array;
		
		/** Array of status, with the newest ones at the end */
		[Bindable]
		public var statuses:ArrayCollection;
		
		/** Array of status, with the newest ones at the end */
		[Bindable]
		public var livePhoto:PartyPhoto;
		
		private var _photos:Array;
		private var _photoPointer:int = 0;
		
		private var _lastPhotoId:int;
		
		/** The newest status id we have
		 *  We are making the very lazy assumption that a larger primary key === newer */
		private var _latestStatusId:int = -1;
		private var _latestMajor:PartyStatus;
		
		private var _startDate:Date;
		private var _endDate:Date;
		
		// Raw data store //
		private var _rawEventData:Object;
		private var _rawRoomData:Object;
		private var _rawFloorData:Object;
		private var _rawCreatorData:Object;
		
		public function PartyData()
		{
			_events = [];
			statuses = new ArrayCollection();
			_liveTimer = new Timer(REFRESH_TIME);
			_liveTimer.addEventListener(TimerEvent.TIMER, onUpdateTimer);
		}
		
		// ______________________________________ Status Updating and Cycling
		
		public function startLiveUpdating():void {
			_isLiveUpdating = true;
			_liveTimer.start();
			this.onUpdateTimer();
		
		}
		
		public function stopLiveUpdating():void {
			_isLiveUpdating = false;
			_liveTimer.stop()
		}
		
		private function onUpdateTimer(event:TimerEvent = null):void {
			this.updateLivePhoto();
			this.updateStatuses();			 
		}
		
		public function updateStatuses():void {
			var url:String = DataConstants.serverUrl;
			
			if(_latestStatusId >= 0) {
				url += DataConstants.URL_STATUS_SINCE + _latestStatusId;
			} else {
				url += DataConstants.URL_STATUS;
			}
			
			
			var statusLoader:URLLoader = new URLLoader();
			statusLoader.addEventListener(Event.COMPLETE, this.onStatusReceived);
			statusLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			statusLoader.load(new URLRequest(url));
		}
		
		private function onStatusReceived(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onStatusReceived);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			var rawStatuses:Object = JSON.decode(rawData);
			var newStatuses:Array = [];
			var newMajorFound:Boolean = false;
			
			for each(var status:Object in rawStatuses) {
				var newStatus:PartyStatus = new PartyStatus(status)
				if( newStatus.state != "dead") {
					
					if(newStatus.state == "minor") {
						statuses.addItemAt(newStatus, 0);
					} else if(_latestMajor && _latestMajor.id < newStatus.id){
						_latestMajor = newStatus;
						newMajorFound = true;
					} else if(! _latestMajor){
						_latestMajor = newStatus;
						newMajorFound = true;
					}
					
					if(newStatus.id > _latestStatusId) {
						_latestStatusId = newStatus.id;
					}
					
					if(statuses.length > MAX_STATUS) {
						statuses.removeItemAt(statuses.length - 1);
					}
				}
				
				if(newMajorFound) {
					this.dispatchEvent(new Event("newMajor"));
				}
			}
			this.dispatchEvent(new Event("newStatus"));
		}
		
		// ______________________________________ Photo Updating and Cycling
		
		public function updateFirstPhoto():void {
			var url:String = DataConstants.serverUrl + DataConstants.URL_PHOTO;
			var photoLoader:URLLoader = new URLLoader();
			photoLoader.addEventListener(Event.COMPLETE, this.onFirstPhotoReceived);
			photoLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			photoLoader.load(new URLRequest(url));
		}
		
		public function updateLivePhoto():void {
			var url:String = DataConstants.serverUrl + DataConstants.URL_PHOTO;
			var photoLoader:URLLoader = new URLLoader();
			photoLoader.addEventListener(Event.COMPLETE, this.onFirstPhotoReceived);
			photoLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			photoLoader.load(new URLRequest(url));
		}
		
		private function onFirstPhotoReceived(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onFirstPhotoReceived);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			var rawPhoto:Array = JSON.decode(rawData).data;
			
			if(rawPhoto.length > MAX_PHOTOS) {
				rawPhoto = rawPhoto.slice(0, MAX_PHOTOS);
			}
			
			if(rawPhoto.length > 0) {
				var index:int = Math.max(int(Math.random() * rawPhoto.length), 0);
				this.livePhoto = new PartyPhoto(rawPhoto[index]);
				
				// display a simple photo event to allow the application to buffer the load
				this.dispatchEvent(new Event("photo"));
			}
		}
		
		// ______________________________________ Data Updateting
		/**
		 * Starts the schedule building requests. The data model is requested in this order:
		 * 1) Floors
		 * 2) Rooms
		 * 3) Events
		 * 4) Creators
		 * 5) Videos
		 * 5) Creator Chips
		 * And the the full schedule tree is reconsistuted. This makes the processing quick and efficient and allows
		 * us to keep our json requests to a minimum.
		 */
		public function loadData():void {
			_scheduleRequested = true;
			_creatorsRecieved = false;
			_sceduleRecieved = false;
			
			var floorLoader:URLLoader = new URLLoader();
			floorLoader.addEventListener(Event.COMPLETE, onFloorsReceived);
			floorLoader.addEventListener(IOErrorEvent.IO_ERROR, onJsonIOError);
			floorLoader.load(new URLRequest(DataConstants.serverUrl + DataConstants.URL_FLOOR));
		}
		
		public function onFloorsReceived(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onFloorsReceived);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawFloorData = JSON.decode(rawData)
			_floors = [];
			
			for each(var rawFloor:Object in _rawFloorData.data) {
				_floors.push(new EventFloor(rawFloor)); 
			}
			
			var roomLoader:URLLoader = new URLLoader();
			roomLoader.addEventListener(Event.COMPLETE, this.onRoomsRevieved);
			roomLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			roomLoader.load(new URLRequest(DataConstants.serverUrl + DataConstants.URL_ROOM));
		}
		
		public function onRoomsRevieved(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onRoomsRevieved);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawRoomData = JSON.decode(rawData)
			_rooms = [];
			
			for each(var rawRoom:Object in _rawRoomData.data) {
				_rooms.push(new EventRoom(rawRoom));
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
			eventLoader.load(new URLRequest(DataConstants.serverUrl + DataConstants.URL_SCHEDULE));
		}
		
		public function onEventsRecieved(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onEventsRecieved);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawEventData = JSON.decode(rawData)
			_events = [];
			
			for each(var rawEvent:Object in _rawEventData.data.events) {
				_events.push(new PartyEvent(rawEvent));
			}
			
			// associate our events chips with their events
			/*
			for each(var chip:Object in _rawEventData.chips) {
				for each(var e:PartyEvent in _events) {
					if(e.id == chip.fields.event) {
						e.chipUrl = chip.fields.image;
					}
				}
			}
			*/
			
			// associate our events with their room
			for each(var room:EventRoom in _rooms) {
				for each(var e:PartyEvent in _events) {
					if(e.roomId == room.id) {
						room.addEvent(e);
						e.floorName = this.getFloorFromRoom(room).name;
					}
				}
			}
			
			var finalRooms:Array = [];
			var toRemove:Array = [];
			for each(room in _rooms) {
				if(room.events.length > 0) {
					finalRooms.push(room);
				} else {
					toRemove.push(room);
				}
			}
			
			for each(var floor:EventFloor in _floors) {
				floor.cullRooms(toRemove);
			}
			
			_rooms = finalRooms;
		
			// and set out constants;
			if(_events.length > 0) {
				var sd:Date = new Date((_events[0] as PartyEvent).startTime.getTime());
				var ed:Date = new Date((_events[0] as PartyEvent).endTime.getTime());
				
				for each(var ev:PartyEvent in _events) {
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
			
			var eventLoader:URLLoader = new URLLoader();
			eventLoader.addEventListener(Event.COMPLETE, this.onCreatorsRecieved);
			eventLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			eventLoader.load(new URLRequest(DataConstants.serverUrl + DataConstants.URL_CREATOR));
		}
		
		public function onCreatorsRecieved(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onCreatorsRecieved);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			_rawCreatorData = JSON.decode(rawData)
			_creators = [];
			
			for each(var rawCreator:Object in _rawCreatorData.data) {
				_creators.push(new Creator(rawCreator));
			}
			
			/* WE ARE NOT GRABBING VIDEO THIS WAY ANYMORE 
			var eventLoader:URLLoader = new URLLoader();
			eventLoader.addEventListener(Event.COMPLETE, this.onVideosRecieved);
			eventLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			eventLoader.load(new URLRequest(DataConstants.serverUrl + DataConstants.URL_VIDEO));
			*/
			
			// and we're done!
			this._sceduleRecieved = true;
			this.dispatchEvent(new Event(Event.COMPLETE));
			
		}
		
		public function onVideosRecieved(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onVideosRecieved);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			var rawVideoData:Object = JSON.decode(rawData)
			this._videos = [];
			
			for each(var raw:Object in rawVideoData) {
				_videos.push(new PartyVideo(raw));
			}
			
			var eventLoader:URLLoader = new URLLoader();
			eventLoader.addEventListener(Event.COMPLETE, this.onCreatorChipsReciever);
			eventLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			//eventLoader.load(new URLRequest(DataConstants.serverUrl + DataConstants.URL_CREATOR_CHIPS));
		}
		
		public function onCreatorChipsReciever(event:Event):void {
			(event.target as URLLoader).removeEventListener(Event.COMPLETE, this.onCreatorChipsReciever);
			(event.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			
			var rawData:String = (event.target as URLLoader).data;
			var rawChips:Object = JSON.decode(rawData)
			this._chips = [];
			
			for each(var raw:Object in rawChips) {
				_chips.push(new PartyCreatorChip(raw));
			}
			
			// and we're done!
			this._sceduleRecieved = true;
			this.dispatchEvent(new Event(Event.COMPLETE));
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
		 * Returns the latest major alert we have in the system
		 */
		public function get latestMajor():PartyStatus {
			return _latestMajor;
		}
		
		public function get nextEvents():Array {
			var currentDate:Date = new Date(2010, 9, 14, 20, 12, 00);
			var events:Array = []
			var threshold:Number = .5;			// in hours
			
			for each(var event:PartyEvent in _events) {
				if(Math.abs((currentDate.getTime() - event.startTime.getTime()) / 1000 / 60 / 60) < .5
				   || (currentDate.getTime() > event.startTime.getTime() && currentDate.getTime() < event.endTime.getTime())) {
					events.push(event);
				}
			}
			
			return events;
		}
		
		public function getEventFromCreator(creator:Creator):PartyEvent {
			for each(var event:PartyEvent in _events) {
				if(event.creatorId == creator.id) {
					return event;
				}
			}
			return null;
		}
		
		public function getFloorFromRoom(room:EventRoom):EventFloor {
			for each(var floor:EventFloor in _floors) {
				if(floor.rooms.indexOf(room) >= 0) {
					return floor;
				}
			}
			return null;
		}
		
		public function getFloorFromOrder(order:int):EventFloor {
			for each(var floor:EventFloor in _floors) {
				if(floor.order == order) {
					return floor;
				}
			}
			return null;
		}
		
		public function getRoomFromId(roomId:String):EventRoom {
			for each(var room:EventRoom in _rooms) {
				if(room.id == roomId) {
					return room;
				}
			}
			return null;
		}
		
		public function getChipsForCreator(creator:Creator):Array {
			var rez:Array = [];
			
			for each(var chip:PartyCreatorChip in _chips) {
				if(creator.id == chip.creatorId) {
					rez.push(chip);
				}
			}
			
			return rez;
		}
		
		public function getVideoFromId(id:String):PartyVideo {
			for each(var video:PartyVideo in _videos) {
				if(video.id == id) {
					return video;
				}
			}
			return null;	
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
		
		public static function dateFromJSON(jsonDate:String):Date {
			var dateSet:Array = (jsonDate.split(" ")[0] as String).split("-");
			var timeSet:Array = (jsonDate.split(" ")[1] as String).split(":");
			
			return new Date(dateSet[0], dateSet[1], dateSet[2], timeSet[0], timeSet[1]);
		}
	}
}
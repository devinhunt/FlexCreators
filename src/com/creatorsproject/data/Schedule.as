package com.creatorsproject.data
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Schedule
	{
		
		/** True if we have asked the server for a schedule */		
		private var _scheduleRequested:Boolean = false;
		
		/** True if we have recieved and parsed the latest schedule data */
		private var _sceduleRecieved:Boolean = false;
		
		/** List of all individule events */
		private var _events:Array;
		
		/** List of all rooms involved in the event */
		private var _rooms:Array;
		
		/** All the floors in the party */
		private var _floors:Array;
		
		// Raw data store //
		private var _rawEventData:Object;
		private var _rawRoomData:Object;
		
		public function Schedule()
		{
			_events = [];
		}
		
		// ------------------------------------------------ Schedule Updateting
		
		public function requestSchedule():void {
			_scheduleRequested = true;
			var eventLoader:URLLoader = new URLLoader();
			eventLoader.addEventListener(Event.COMPLETE, this.onEventsRecieved);
			eventLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			eventLoader.load(new URLRequest(main.URL_SERVER + main.URL_SCHEDULE));
			
			var roomLoader:URLLoader = new URLLoader();
			roomLoader.addEventListener(Event.COMPLETE, this.onRoomsRevieved);
			roomLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onJsonIOError);
			roomLoader.load(new URLRequest(main.URL_SERVER + main.URL_ROOM));
			
		}
		
		/**
		 * JSON loaded from the server request 
		 * @param event The complete event
		 */
		public function onEventsRecieved(event:Event):void {
			var rawData:String = (event.target as URLLoader).data;
			_rawEventData = JSON.decode(rawData)
			_events = [];
			
			for each(var rawEvent:Object in _rawEventData) {
				_events.push(ScheduleEvent.createEventFromJson(rawEvent));
			}
		}
		
		public function onRoomsRevieved(event:Event):void {
			var rawData:String = (event.target as URLLoader).data;
			_rawRoomData = JSON.decode(rawData)
			_rooms = [];
			
			for each(var rawRoom:Object in _rawRoomData) {
				_rooms.push(new EventRoom(rawRoom.fields.
			}
		}
		
		public function onFloorsReceived(event:Event):void {
			
		}
		
		/**
		 * Oh shit something went wrong with the JSON request
		 * @param event
		 */		
		public function onJsonIOError(event:Event):void {
			trace("There has been an IOError");
		}
		
		// ------------------------------------------------ GETTERS AND SETTERS
		public function get startDate():Date {
			return new Date();
		}
		
		public function get endDate():Date {
			return new Date();
		}
		
		/**
		 * Returns the total number of hours that party scehedule spans 
		 * 
		 */		
		public function get totalHours():Number {
			// TEMP TODO set the hours dynamically
			return 10;
		}
		
	}
}
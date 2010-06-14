package com.creatorsproject.ui
{
	import com.creatorsproject.data.Schedule;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class EventUI extends DisplayObject3D implements ITickable
	{
		
		/** The schedule model we're displaying */
		private var _schedule:Schedule;
		
		/**
		 * Default Constructor 
		 * 
		 */		
		public function EventUI(schedule:Schedule)
		{
			
		}
		
		
		/**
		 * Required by ITickable 
		 * Called during a render tick
		 */		
		public function tick():void {
			
		}
	}
}
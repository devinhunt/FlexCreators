package com.creatorsproject.ui
{
	import com.creatorsproject.data.Schedule;
	
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class EventUI extends DisplayObject3D implements ITickable
	{
		
		/** The schedule model we're displaying */
		private var _schedule:Schedule;
		
		/** Step to divide the grid by, in hours */
		private var _timeGranularity:Number = .5;
		
		/**
		 * Default Constructor 
		 * 
		 */		
		public function EventUI(schedule:Schedule)
		{
			_schedule = schedule;
			this.buildUI();
		}
		
		
		/**
		 * Required by ITickable 
		 * Called during a render tick
		 */		
		public function tick():void {
			
		}
		
		/////////////////
		// Building UI //
		/////////////////
		protected function buildUI():void {
			// generate the curve the grid follows on
			var curve:Array = [];
			var totalHours = (_schedule.endDate.getTime() - _schedule.startDate.getTime()) / 1000 / 60 / 60;
			
			var segments:int = int(totalHours / _timeGranularity);
			var segWidth
			var radius:Number = 1000;
			var step:Number = Math.atan2(100, radius);
			trace("step will be " + step);
			trace("building with arcsteps of " + step);
			
			for (var seg:int = 0; seg < segments + 1; seg ++) {
				curve.push(new Vertex3D(radius * Math.cos(step * seg), 0, radius * Math.sin(step * seg)));
			}
			
		}
		
		
	}
}
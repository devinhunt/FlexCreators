package com.creatorsproject.ui
{
	import com.creatorsproject.data.Creator;
	
	import org.papervision3d.core.material.TriangleMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	/**
	 * The creators UI is the controller class and display object for the Creators Node 
	 * It's bascially a big scattering of plans
	 * @author devin
	 */	
	
	public class CreatorUI extends TouchUI implements ITickable
	{	
		public static var chipWidth:Number = 300;
		public static var chipHeight:Number = 300;
		
		private var _creators:Array;
		private var _state:String;
		
		private var _root:DisplayObject3D;
		
		public function CreatorUI(creators:Array)
		{
			super();
			this.name = "Creator Module";
			_creators = creators;
			this.assembleCreatorsUI();
			this.state = "creators";
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
			
			trace("Creator UI :: Changing to state " + value);
			
			switch(_state) {
				
			}
		}
		
		// ________________________________________________ Interaction
		
		// ________________________________________________ Building UI
		
		protected function assembleCreatorsUI():void {
			
			if(! _root) {
				_root = new DisplayObject3D();
			}
			
			var thetaStep:Number = Math.PI * 2 / _creators.length;
			var radius:Number = 1.2 * chipWidth / Math.tan(thetaStep);
			
			for(var c:int = 0; c < _creators.length; c ++) {
				var co:Creator = _creators[c];
				var mat:TriangleMaterial = new ColorMaterial();
				var plane:Plane = new Plane(mat, chipWidth, chipHeight);
				
				plane.x = radius * Math.cos(thetaStep * c);
				plane.z = radius * Math.sin(thetaStep * c);
				plane.rotationY = 270 - (180 * (thetaStep * c) / Math.PI);
				
				_root.addChild(plane);
			}
			
			this.addChild(_root);
		}
	}
}
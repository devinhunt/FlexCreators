package com.creatorsproject.ui
{
	import com.creatorsproject.data.Creator;
	import com.creatorsproject.data.PartyData;
	import com.creatorsproject.input.TouchController;
	import com.creatorsproject.ui.chips.CreatorDetailChip;
	
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * The creators UI is the controller class and display object for the Creators Node 
	 * It's bascially a big scattering of plans
	 * @author devin
	 */	
	
	public class CreatorUI extends TouchUI implements ITickable
	{	
		public static var chipWidth:Number = 300;
		public static var chipHeight:Number = 300;
		
		private var _detailChip:CreatorDetailChip;
		
		private var _partyData:PartyData;
		private var _state:String;
		
		private var _root:DisplayObject3D;
		private var _targetChip:CreatorPlane;
		
		
		public function CreatorUI(partyData:PartyData)
		{
			super();
			this.name = "Creator Module";
			_partyData = partyData;
			_detailChip = new CreatorDetailChip();
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
				case "creators":
					if(fling.isFlinging) {
						_root.rotationY += - fling.velocity.x / 10;
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
			
			trace("Creator UI :: Changing to state " + value);
			
			switch(_state) {
				case "creators":
					if(main.instance.frontUI.contains(_detailChip)) {
						main.instance.frontUI.removeChild(_detailChip);
					}
					break;
					
				case "creatorDetail":
					main.instance.frontUI.addChild(_detailChip);
					break;
			}
		}
		
		// ________________________________________________ Interaction
		
		private function onChipClick(event:InteractiveScene3DEvent):void {
			if(TouchController.me.state == "touching" && _state == "creators") {
				_targetChip = event.target as CreatorPlane;
				this.state = "creatorDetail";
			}
		}
		
		// ________________________________________________ Building UI
		
		protected function assembleCreatorsUI():void {
			
			if(! _root) {
				_root = new DisplayObject3D();
				this.addChild(_root);
			}
			
			var radius:Number = 2600;
			var creators:Array = _partyData.creators;
			var thetaStep:Number = Math.PI * 2 / creators.length;
			
			
			for(var c:int = 0; c < creators.length; c ++) {
				var co:Creator = creators[c];
				var plane:CreatorPlane = new CreatorPlane(co);
				
				plane.x = radius * Math.cos(thetaStep * c);
				plane.z = radius * Math.sin(thetaStep * c);
				plane.rotationY = 270 - (180 * (thetaStep * c / Math.PI));
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, this.onChipClick);
				
				_root.addChild(plane);
			}
		}
	}
}
package com.creatorsproject.ui.transitions
{
	import mx.effects.easing.Linear;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * Simple class that stores animation data
	 * @author devin
	 */	
	
	public class AnimationProfile
	{
		public var startPosition:Number3D;
		public var endPosition:Number3D;
		public var startAlpha:Number;
		public var endAlpha:Number;
		
		public var target:DisplayObject3D;
		
		public function AnimationProfile(target:DisplayObject3D, endPosition:Number3D = null, endOpacity:Number = 1)
		{
			this.target = target;
			this.startPosition = target.position.clone();
			this.startAlpha = target.alpha;
			
			this.endPosition = endPosition ? endPosition : new Number3D();
			this.endAlpha = endOpacity;
		}

	}
}
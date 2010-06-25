package com.creatorsproject.ui.transitions
{
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
		
		public var startScale:Number;
		public var endScale:Number;
		
		public var startRotationY:Number;
		public var endRotationY:Number;
		
		public var target:DisplayObject3D;
		
		public function AnimationProfile(target:DisplayObject3D, endPosition:Number3D = null)
		{
			this.target = target;
			this.startPosition = target.position.clone();
			this.startAlpha = target.alpha;
			this.startScale = target.scale;
			this.startRotationY = target.rotationY;
			
			this.endPosition = endPosition ? endPosition : target.position.clone();
			this.endAlpha = target.alpha;
			this.endScale = target.scale;
			this.endRotationY = target.rotationY;
		}

	}
}
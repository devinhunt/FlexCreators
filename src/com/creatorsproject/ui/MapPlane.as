package com.creatorsproject.ui
{
	import flash.geom.Point;
	
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.objects.primitives.Plane;

	public class MapPlane extends Plane
	{
		public var masterLocation:Point;
		public var order:int;
		
		public function MapPlane(clickListener:Function, material:MaterialObject3D=null, width:Number=0, height:Number=0, segmentsW:Number=0, segmentsH:Number=0)
		{
			material.interactive = true;
			super(material, width, height, segmentsW, segmentsH);
			this.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, clickListener);
		}
		
	}
}
package com.creatorsproject.geom
{
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.MaterialObject3D;
	
	/**
	 * A plane-like band built from an array of vertices that define a curve 
	 * @author devin
	 */	
	
	public class TileBand extends TriangleMesh3D
	{
		private var _curve:Array;
		private var _height:Number;
		private var _segWidth:Number;
		
		public function TileBand(material:MaterialObject3D, curve:Array, height:Number = 100, segWidth:Number = 100)
		{
			super(material, new Array(), new Array(), null);
			_curve = curve;
			_height = height;
			_segWidth = segWidth;
			
			buildGeom();
		}
		
		private function buildGeom():void {
			var verts:Array = this.geometry.vertices;
			var faces:Array = this.geometry.faces;
			
			var a:Vertex3D;
			var b:Vertex3D;
			var c:Vertex3D;
			var d:Vertex3D;
			
			var uvA:NumberUV;
			var uvB:NumberUV;
			var uvC:NumberUV;
			
			// build the vertices of the strip and the faces at the same time
			for(var p:int = 0; p < _curve.length - 1; p ++) {
				a = new Vertex3D(_curve[p].x, 0, _curve[p].z)
				b = new Vertex3D(_curve[p].x, _height, _curve[p].z);
				c = new Vertex3D(_curve[p + 1].x, 0, _curve[p + 1].z);
				d = new Vertex3D(_curve[p + 1].x, _height, _curve[p + 1].z);
				verts.push(a);
				verts.push(b);
				verts.push(c);
				verts.push(d);
				
				// first face: tl tr bl
				uvA = new NumberUV(p * _segWidth, 0);
				uvB = new NumberUV((p + 1) * _segWidth, 0);
				uvC = new NumberUV(p * _segWidth, _height);
				faces.push(new Triangle3D(this, [a, c, b], this.material, [uvA, uvB, uvC]));
				
				// second face: bl tr br
				uvA = new NumberUV(p * _segWidth, _height);
				uvB = new NumberUV((p + 1) * _segWidth, 0);
				uvC = new NumberUV((p + 1) * _segWidth, _height);
				faces.push(new Triangle3D(this, [b, c, d], this.material, [uvA, uvB, uvC]));
			}
		}
	}
}
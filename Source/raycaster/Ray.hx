package raycaster;

import openfl.geom.Point;

class Ray {
	public var direction:Point;

	/**
		Point where Ray hits a wall
	**/
	public var clip:Point = new Point(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);

	public function new(direction:Point) {
		this.direction = direction;
	}
}

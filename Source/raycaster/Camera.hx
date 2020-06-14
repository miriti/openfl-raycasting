package raycaster;

import openfl.geom.Point;

typedef Camera = {
	angle:Float,
	direction:Point,
	plane:Point,
	planeDistance:Float,
	rays:Array<Ray>,
	position:Point,
	radius:Float
}

package raycaster;

import lime.math.RGBA;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;

using Math;
using Std;

class Raycaster extends Bitmap {
	public static inline final MAP_WIDTH:Int = 20;
	public static inline final MAP_HEIGHT:Int = 20;

	public var camera:Camera;

	public var fog:Bool = true;
	public var map:Array<Array<BitmapData>>;

	/**
		Field of view angle in degrees
	**/
	public var fov(default, set):Float;

	var fov_rad:Float; // Fild of view angle in radians

	var screenWidth:Int;
	var screenHeight:Int;

	var hScale:Float = 0.5;

	function set_fov(value:Float):Float {
		fov_rad = value * Math.PI / 180;
		camera.planeDistance = (1 / (fov_rad / 2).sin()) * (fov_rad / 2).cos();
		return fov = value;
	}

	public function new(screenWidth:Int, screenHeight:Int, fov:Float) {
		super(new BitmapData(screenWidth, screenHeight, false));

		this.screenWidth = screenWidth;
		this.screenHeight = screenHeight;

		camera = {
			angle: Math.PI / 3,
			direction: new Point(),
			rays: [for (_ in 0...screenWidth) new Ray(new Point())],
			position: new Point(),
			radius: 0.3,
			plane: new Point(),
			planeDistance: 1
		};

		this.fov = fov;

		function genTile(i:Int, j:Int, color:Int):BitmapData {
			switch (color) {
				case 0xff0000:
					camera.position.setTo(i + 0.5, j + 0.5);
				case 0x0:
					return Math.random() > 0.5 ? Assets.getBitmapData('Assets/openfl.png') : Assets.getBitmapData('Assets/haxe.png');
			}
			return null;
		}

		var mapBitmap = Assets.getBitmapData('Assets/map.png');

		map = [
			for (i in 0...mapBitmap.width) [for (j in 0...mapBitmap.height) genTile(i, j, mapBitmap.getPixel(i, j))]
		];
	}

	function cameraCollision() {
		var mapX:Int = camera.position.x.int();
		var mapY:Int = camera.position.y.int();

		// Left
		if (((mapX >= 1 && map[mapX - 1][mapY] != null) || (mapX == 0)) && camera.position.x < mapX + camera.radius)
			camera.position.x = mapX + camera.radius;

		// Top
		if (((mapY >= 1 && map[mapX][mapY - 1] != null) || (mapY == 0)) && camera.position.y < mapY + camera.radius)
			camera.position.y = mapY + camera.radius;

		// Right
		if (((mapX < MAP_WIDTH - 1 && map[mapX + 1][mapY] != null) || (mapX == MAP_WIDTH - 1))
			&& camera.position.x > mapX + 1 - camera.radius)
			camera.position.x = mapX + 1 - camera.radius;

		// Bottom
		if (((mapY < MAP_HEIGHT - 1 && map[mapX][mapY + 1] != null) || (mapY == MAP_HEIGHT - 1))
			&& camera.position.y > mapY + 1 - camera.radius)
			camera.position.y = mapY + 1 - camera.radius;

		var corners:Array<{x:Float, y:Float}> = [];
		if ((mapX >= 1 && mapY >= 1 && map[mapX - 1][mapY - 1] != null) || (mapX == 0 && mapY == 0)) {
			corners.push({x: mapX, y: mapY});
		}
		if ((mapX < MAP_WIDTH - 1 && mapY >= 1 && map[mapX + 1][mapY - 1] != null) || (mapX == MAP_WIDTH - 1 && mapY == 0)) {
			corners.push({x: mapX + 1, y: mapY});
		}
		if ((mapX < MAP_WIDTH - 1 && mapY < MAP_HEIGHT - 1 && map[mapX + 1][mapY + 1] != null)
			|| (mapX == MAP_WIDTH - 1 && mapY == MAP_HEIGHT - 1)) {
			corners.push({x: mapX + 1, y: mapY + 1});
		}
		if ((mapX >= 1 && mapY < MAP_HEIGHT - 1 && map[mapX - 1][mapY + 1] != null) || (mapX == 1 && mapY == MAP_HEIGHT - 1)) {
			corners.push({x: mapX, y: mapY + 1});
		}

		for (corner in corners) {
			var v = new Point(camera.position.x - corner.x, camera.position.y - corner.y);
			var len = v.length;
			if (len < camera.radius) {
				camera.position.x = corner.x + (v.x / len) * camera.radius;
				camera.position.y = corner.y + (v.y / len) * camera.radius;
			}
		}
	}

	public function render() {
		cameraCollision();

		bitmapData.lock();
		bitmapData.fillRect(bitmapData.rect, 0x0);

		var perpAngle:Float = camera.angle + Math.PI / 2;
		camera.direction.setTo(camera.angle.cos() * camera.planeDistance, camera.angle.sin() * camera.planeDistance);
		camera.plane.setTo(perpAngle.cos(), perpAngle.sin());

		for (ray_n in 0...screenWidth) {
			var ray = camera.rays[ray_n];
			var cameraX:Float = (2 * ray_n / screenWidth - 1);
			ray.direction.setTo(camera.direction.x + camera.plane.x * cameraX, camera.direction.y + camera.plane.y * cameraX);

			var mapX:Int = camera.position.x.int();
			var mapY:Int = camera.position.y.int();

			ray.clip.setTo(camera.position.x, camera.position.y);

			var deltaDistX:Float = ray.direction.x == 0 ? 0 : (1 / ray.direction.x).abs();
			var deltaDistY:Float = ray.direction.y == 0 ? 0 : (1 / ray.direction.y).abs();

			var texture:BitmapData = null;
			var textureU:Float = 0;
			var side:Int = 0;
			var stepX:Int = 0;
			var stepY:Int = 0;
			while (true) {
				var sideDx:Float;
				var sideDy:Float;

				if (ray.direction.x < 0) {
					sideDx = (ray.clip.x - mapX) * deltaDistX;
					stepX = -1;
				} else {
					sideDx = (mapX + 1 - ray.clip.x) * deltaDistX;
					stepX = 1;
				}

				if (ray.direction.y < 0) {
					sideDy = (ray.clip.y - mapY) * deltaDistY;
					stepY = -1;
				} else {
					sideDy = (mapY + 1 - ray.clip.y) * deltaDistY;
					stepY = 1;
				}

				ray.clip.x += ray.direction.x * Math.min(sideDx, sideDy);
				ray.clip.y += ray.direction.y * Math.min(sideDx, sideDy);

				if (sideDx < sideDy) {
					mapX += stepX;
					textureU = ray.clip.y - mapY;
					side = 0;
				} else {
					mapY += stepY;
					textureU = ray.clip.x - mapX;
					side = 1;
				}

				if (mapX >= 0 && mapX < MAP_WIDTH && mapY >= 0 && mapY < MAP_HEIGHT) {
					if (map[mapX][mapY] != null) {
						texture = map[mapX][mapY];
						break;
					}
				} else {
					ray.clip.setTo(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
					break;
				}
			}

			if (Math.isFinite(ray.clip.x) && Math.isFinite(ray.clip.x)) {
				var distance:Float = 0;

				distance = side == 0 ? (mapX - camera.position.x + (1 - stepX) / 2) / ray.direction.x : (mapY - camera.position.y +
					(1 - stepY) / 2) / ray.direction.y;

				var columnLength = (screenHeight / distance) * hScale;
				var columnStart = ((screenHeight - columnLength) / 2).int();
				var columnEnd = ((screenHeight + columnLength) / 2).int();

				for (line in Math.max(0, columnStart).int()...Math.min(screenHeight, columnEnd).int()) {
					var textureV:Float = (line - columnStart) / (columnEnd - columnStart);
					var color:Int;
					if (texture != null) {
						color = texture.getPixel32((texture.width * textureU).int(), (texture.height * textureV).int());
					} else {
						color = 0xffffffff;
					}

					if (fog && distance > 1) {
						var rgba = cast(color, RGBA);
						var m = 1 / distance;
						rgba.r = (rgba.r * m).int();
						rgba.g = (rgba.g * m).int();
						rgba.b = (rgba.b * m).int();
						rgba.a = (rgba.a * m).int();
						color = rgba;
					}

					bitmapData.setPixel(ray_n, line, color);
				}
			}
		}

		bitmapData.unlock();
	}
}

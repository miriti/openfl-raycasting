package gui;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import raycaster.Raycaster;

class Tile extends Bitmap {
	public static inline final SIZE:Int = 20;

	public function new() {
		super();
	}
}

class GUI extends Sprite {
	var raycaster:Raycaster;

	var camera:Sprite = new Sprite();

	public function new(raycaster:Raycaster) {
		super();

		this.raycaster = raycaster;

		var placeholder = new BitmapData(300, 300, false, 0xcccccc);

		for (i in 0...Raycaster.MAP_WIDTH) {
			for (j in 0...Raycaster.MAP_HEIGHT) {
				var tile = new Tile();
				tile.bitmapData = raycaster.map[i][j] == null ? placeholder : raycaster.map[i][j];
				tile.width = tile.height = Tile.SIZE;
				var tileSprite = new Sprite();
				tileSprite.buttonMode = true;
				tileSprite.x = i * Tile.SIZE;
				tileSprite.y = j * Tile.SIZE;
				tileSprite.addChild(tile);
				tileSprite.addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> {
					var texture = Math.random() > 0.5 ? Assets.getBitmapData('Assets/openfl.png') : Assets.getBitmapData('Assets/haxe.png');
					if (raycaster.map[i][j] == null) {
						tile.bitmapData = raycaster.map[i][j] = texture;
					} else {
						tile.bitmapData = placeholder;
						raycaster.map[i][j] = null;
					}
					raycaster.render();
					update();
				});

				addChild(tileSprite);
			}
		}

		var grid = new Shape();

		grid.graphics.lineStyle(1, 0x888888);
		for (i in 0...Raycaster.MAP_WIDTH) {
			for (j in 0...Raycaster.MAP_HEIGHT) {
				grid.graphics.drawRect(i * Tile.SIZE, j * Tile.SIZE, Tile.SIZE, Tile.SIZE);
			}
		}

		addChild(grid);

		camera.mouseEnabled = false;
		addChild(camera);

		var sliderFov = new Slider(300, 1, 179, raycaster.fov);
		var fovValue = new TextField();
		sliderFov.y = height + 10;
		sliderFov.addEventListener(Event.CHANGE, (event:Event) -> {
			raycaster.fov = sliderFov.value;
			fovValue.text = '${Std.int(sliderFov.value)}';
			raycaster.render();
			update();
		});
		addChild(sliderFov);

		var fovLabel = new TextField();
		fovLabel.selectable = false;
		fovLabel.autoSize = LEFT;
		fovLabel.text = 'FOV: ';
		fovLabel.y = sliderFov.y + (sliderFov.height - fovLabel.height) / 2;
		addChild(fovLabel);

		sliderFov.x = fovLabel.width + 15;

		fovValue.selectable = false;
		fovValue.autoSize = LEFT;
		fovValue.text = '${sliderFov.value}';
		fovValue.x = sliderFov.x + sliderFov.width + 15;
		fovValue.y = fovLabel.y;
		addChild(fovValue);

		var cbxFog = new Checkbox('Distance fog', true);
		cbxFog.y = height + 10;
		cbxFog.addEventListener(Event.CHANGE, (event:Event) -> {
			raycaster.fog = cbxFog.checked;
			raycaster.render();
		});
		addChild(cbxFog);
	}

	public function update() {
		camera.graphics.clear();

		for (ray in raycaster.camera.rays) {
			camera.graphics.lineStyle(1, 0xffff00);
			camera.graphics.moveTo(raycaster.camera.position.x * Tile.SIZE, raycaster.camera.position.y * Tile.SIZE);

			if (Math.isFinite(ray.clip.x) && Math.isFinite(ray.clip.y)) {
				camera.graphics.lineTo(ray.clip.x * Tile.SIZE, ray.clip.y * Tile.SIZE);
			}
		}

		camera.graphics.beginFill(0xff0000);
		camera.graphics.drawCircle(raycaster.camera.position.x * Tile.SIZE, raycaster.camera.position.y * Tile.SIZE, 2);
		camera.graphics.endFill();

		camera.graphics.lineStyle(1, 0xff0000);
		camera.graphics.drawCircle(raycaster.camera.position.x * Tile.SIZE, raycaster.camera.position.y * Tile.SIZE, raycaster.camera.radius * Tile.SIZE);
	}
}

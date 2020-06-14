package;

import openfl.text.TextField;
import gui.GUI;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import raycaster.Raycaster;

class Main extends Sprite {
	static inline final MOVE_SPEED:Float = 2; // Tiles per second
	static inline final ROTATE_SPEED:Float = 1.57079632679; // π/2

	public function new() {
		super();

		var raycaster = new Raycaster(200, 200, 60);
		raycaster.scaleX = raycaster.scaleY = 2;
		addChild(raycaster);

		var instructions:TextField = new TextField();
		instructions.autoSize = LEFT;
		instructions.x = raycaster.x + 10;
		instructions.y = raycaster.y + raycaster.height + 10;
		instructions.wordWrap = true;
		instructions.width = raycaster.width;
		instructions.text = 'W/S - Forward/Back\nA/D - Rotate';
		addChild(instructions);

		var gui = new GUI(raycaster);
		gui.x = raycaster.width;
		addChild(gui);

		var lastTime = Lib.getTimer();

		var keys:Map<Int, Bool> = [];

		var move:Int = 0;
		var rotate:Int = 0;

		function updateDirectionAndRotation() {
			move = ((keys[Keyboard.W] || keys[Keyboard.UP]) ? 1 : 0) + ((keys[Keyboard.S] || keys[Keyboard.DOWN]) ? -1 : 0);
			rotate = ((keys[Keyboard.D] || keys[Keyboard.RIGHT]) ? 1 : 0) + ((keys[Keyboard.A] || keys[Keyboard.LEFT]) ? -1 : 0);
		}

		addEventListener(Event.ADDED_TO_STAGE, (event:Event) -> {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, (kbe:KeyboardEvent) -> {
				keys[kbe.keyCode] = true;
				updateDirectionAndRotation();
			});
			stage.addEventListener(KeyboardEvent.KEY_UP, (kbe:KeyboardEvent) -> {
				keys[kbe.keyCode] = false;
				updateDirectionAndRotation();
			});
		});

		function render() {
			raycaster.render();
			gui.update();
		}

		addEventListener(Event.ENTER_FRAME, (event:Event) -> {
			var currentTime = Lib.getTimer();
			var delta = (currentTime - lastTime) / 1000;
			lastTime = currentTime;

			if (move != 0) {
				var dx = move * (Math.cos(raycaster.camera.angle) * MOVE_SPEED * delta);
				var dy = move * (Math.sin(raycaster.camera.angle) * MOVE_SPEED * delta);
				raycaster.camera.position.x += dx;
				raycaster.camera.position.y += dy;
			}

			if (rotate != 0) {
				raycaster.camera.angle += rotate * (ROTATE_SPEED * delta);
			}

			if (move != 0 || rotate != 0) {
				render();
			}
		});

		render();
	}
}

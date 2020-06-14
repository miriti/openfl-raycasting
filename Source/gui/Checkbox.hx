package gui;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;

class Checkbox extends Sprite {
	var bmpUnchecked:Bitmap;
	var bmpChecked:Bitmap;

	public var checked(default, set):Bool;

	function set_checked(value:Bool):Bool {
		bmpChecked.visible = value;
		bmpUnchecked.visible = !value;

		return checked = value;
	}

	public function new(label:String, defaultValue:Bool = false) {
		super();

		bmpChecked = new Bitmap(Assets.getBitmapData('Assets/cbx_on.png'));
		bmpUnchecked = new Bitmap(Assets.getBitmapData('Assets/cbx_off.png'));

		addChild(bmpChecked);
		addChild(bmpUnchecked);

		var caption = new TextField();
		caption.selectable = false;
		caption.autoSize = LEFT;
		caption.text = label;
		caption.x = bmpChecked.x + bmpChecked.width + 10;
		caption.y = (bmpChecked.height - caption.height) / 2;
		addChild(caption);

		buttonMode = true;

		addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> {
			checked = !checked;
			dispatchEvent(new Event(Event.CHANGE));
		});

		checked = defaultValue;
	}
}

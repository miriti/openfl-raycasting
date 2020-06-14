package gui;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class Slider extends Sprite {
	var _value:Float;

	public var value(get, set):Float;

	function get_value():Float
		return _value;

	function set_value(newValue:Float):Float {
		return _value = newValue;
	}

	var minVal:Float;
	var maxVal:Float;

	public function new(sliderWidth:Float, minVal:Float, maxVal:Float, initValue:Float) {
		super();

		this.minVal = minVal;
		this.maxVal = maxVal;

		var railHeight:Float = 10;
		var sliderHeight:Float = 30;

		_value = initValue;

		graphics.lineStyle(1, 0x0);
		graphics.beginFill(0xffffff);
		graphics.drawRoundRect(0, (sliderHeight - railHeight) / 2, sliderWidth, railHeight, 5);
		graphics.endFill();

		var knobWidth = 15;

		var dragging:Bool = false;

		var knob = new Sprite();
		knob.graphics.lineStyle(1, 0x0);
		knob.graphics.beginFill(0xcccccc);
		knob.graphics.drawRoundRect(-(knobWidth / 2), -(sliderHeight / 2), knobWidth, sliderHeight, 5);
		knob.graphics.endFill();

		knob.buttonMode = true;
		knob.addEventListener(MouseEvent.MOUSE_DOWN, (event:MouseEvent) -> {
			knob.startDrag(false, new Rectangle(0, sliderHeight / 2, sliderWidth, 0));
			dragging = true;
		});
		knob.addEventListener(MouseEvent.MOUSE_UP, (event:MouseEvent) -> {
			knob.stopDrag();
			dragging = false;
		});
		knob.addEventListener(MouseEvent.RELEASE_OUTSIDE, (event:MouseEvent) -> {
			knob.stopDrag();
			dragging = false;
		});
		knob.addEventListener(MouseEvent.MOUSE_MOVE, (event:MouseEvent) -> {
			if (dragging) {
				_value = minVal + (maxVal - minVal) * (knob.x / sliderWidth);
				dispatchEvent(new Event(Event.CHANGE));
			}
		});

		knob.x = sliderWidth * (initValue - minVal) / maxVal;
		knob.y = sliderHeight / 2;
		addChild(knob);
	}
}

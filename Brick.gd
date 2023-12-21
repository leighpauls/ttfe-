class_name Brick
extends Sprite2D

signal clicked(brick: Brick, mouse_position: Vector2)
signal hovered(brick: Brick)

var brick_id: int
var _line: Line

func _ready():
	_line = $Line

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_position = event.get_position()
		if (event.is_pressed()
	 	  and event.get_button_index() == MOUSE_BUTTON_LEFT
		  and get_rect().has_point(to_local(mouse_position))):
			clicked.emit(self, mouse_position)
	
		if event.is_released():
			_line.set_visible(false)
	
	if (event is InputEventMouseMotion
	  and get_rect().has_point(to_local(event.get_position()))):
		hovered.emit(self)

func draw_line_target(target_position: Vector2):
	_line.set_visible(true)
	_line.set_target(target_position)

func hide_line():
	_line.set_visible(false)

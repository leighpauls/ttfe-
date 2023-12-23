class_name Brick
extends Polygon2D

const WIDTH = 5
const HEIGHT = 6
const SPACING = 120.0

signal clicked(brick: Brick, mouse_position: Vector2)
signal hovered(brick: Brick)

var brick_number: int

var _line: Line
var _grid_position: Vector2i

func _ready():
	_line = $Line

func _process(delta):
	$label.set_text(var_to_str(brick_number))

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_position = event.get_position()

		if (event.is_pressed()
		  and event.get_button_index() == MOUSE_BUTTON_LEFT
		  and _is_on_brick(mouse_position)):
			clicked.emit(self, mouse_position)
	
		if event.is_released():
			_line.set_visible(false)
	
	if event is InputEventMouseMotion and _is_on_brick(event.get_position()):
		hovered.emit(self)

func set_grid_position(grid_position: Vector2i):
	_grid_position = grid_position
	var y_offset
	if grid_position.x % 2 == 0:
		y_offset = Vector2.ZERO
	else:
		y_offset = Vector2(0, SPACING / 2)
	
	set_position(Vector2(SPACING/2, SPACING/2) + SPACING * _grid_position + y_offset)

func draw_line_target(target_position: Vector2):
	_line.set_visible(true)
	_line.set_target(target_position)

func hide_line():
	_line.set_visible(false)

func _is_on_brick(point: Vector2):
	return Geometry2D.is_point_in_polygon(to_local(point), self.get_polygon())

func is_adjacent(other: Brick):
	var delta = other._grid_position - _grid_position
	if delta.x == 0:
		return delta.y == 1 or delta.y == -1

	if delta.x == 1 or delta.x == -1:
		if _grid_position.x % 2 == 0:
			return delta.y == -1 or delta.y == 0
		else:
			return delta.y == 0 or delta.y == 1
	return false
		

class_name Brick
extends Polygon2D

const WIDTH = 5
const HEIGHT = 8
const SPACING = 120.0

signal clicked(brick: Brick, mouse_position: Vector2)
signal hovered(brick: Brick)

const MOVEMENT_ANIMATION_DURATION = 0.25

var _colors: PackedColorArray

var brick_number: int

var _line: Line
var _label: Label
var _animation_player: AnimationPlayer
var _movement_animation_name: String
var _movement_animation: Animation
var _movement_animation_track: int

var _grid_position: Vector2i

func _ready():
	_line = $Line
	_label = $label
	_animation_player = $AnimationPlayer
	
	_colors = get_meta("colors", PackedColorArray([color]))
	
	var animation_name = 'movement'
	var library_name = 'dynamic'
	_movement_animation_name = '%s/%s' % [library_name, animation_name]
	
	_movement_animation = Animation.new()
	_movement_animation.length = MOVEMENT_ANIMATION_DURATION
	_movement_animation_track = _movement_animation.add_track(Animation.TYPE_VALUE)
	_movement_animation.track_set_path(_movement_animation_track, str(get_path_to(self)) + ':position')
	
	_movement_animation.track_insert_key(_movement_animation_track, 0.0, position)
	_movement_animation.track_insert_key(
		_movement_animation_track, MOVEMENT_ANIMATION_DURATION, Vector2(300, 300))
	_movement_animation.track_set_interpolation_type(_movement_animation_track, Animation.INTERPOLATION_CUBIC)
	
	var lib = AnimationLibrary.new()
	lib.add_animation(animation_name, _movement_animation)
	_animation_player.add_animation_library(library_name, lib)

func _process(_delta):
	var color_idx = int(log(brick_number) / log(2)) % _colors.size()
	color = _colors[color_idx]
	
	var display_number := brick_number
	var display_unit := ''
	if display_number >= 1024:
		display_number /= 1024
		display_unit = 'K'
	if display_number >= 1024:
		display_number /= 1024
		display_unit = 'M'
	if display_number >= 1024:
		display_number /= 1024
		display_unit = 'G'
	
	
	_label.set_text(str(display_number) + display_unit)

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

func set_grid_position(grid_position: Vector2i) -> void:
	_grid_position = grid_position
	
	var new_position := grid_to_position(_grid_position)
	_animation_player.stop(true)
	_movement_animation.track_set_key_value(_movement_animation_track, 0, position)
	_movement_animation.track_set_key_value(_movement_animation_track, 1, new_position)
	_animation_player.play(_movement_animation_name)


func get_grid_position() -> Vector2i:
	return _grid_position

static func grid_to_position(grid_position: Vector2i) -> Vector2:
	var y_offset: Vector2
	if grid_position.x % 2 == 0:
		y_offset = Vector2.ZERO
	else:
		y_offset = Vector2(0, SPACING / 2)
	
	return (
		Vector2(SPACING/2, SPACING/2)
		+ SPACING * grid_position
		+ y_offset)

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
		

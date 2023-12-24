extends Node2D

var brick_scene = preload('res://Brick.tscn')

var rng = RandomNumberGenerator.new()

var selected_bricks: Array[Brick] = []
var grid: Dictionary = {} # Vector2i to Brick

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(Brick.WIDTH):
		for y in range(Brick.HEIGHT):
			if x % 2 == 1 and y == Brick.HEIGHT - 1:
				continue
			var grid_position = Vector2i(x, y)
			var new_brick: Brick = brick_scene.instantiate()
			
			new_brick.brick_number = int(pow(2, rng.randi_range(1, 3)))
			
			new_brick.clicked.connect(_on_brick_clicked)
			new_brick.hovered.connect(_on_brick_hovered)
			
			$Background.add_child(new_brick)
			
			new_brick.set_grid_position(grid_position)

func _on_brick_clicked(brick: Brick, mouse_position: Vector2):
	selected_bricks = [brick]
	selected_bricks[-1].draw_line_target(mouse_position)

func _on_brick_hovered(brick: Brick):
	if selected_bricks.size() == 0:
		return
	
	var prev_brick = selected_bricks[-1]
	
	if brick in selected_bricks:
		while selected_bricks[-1] != brick:
			var popped_brick = selected_bricks.pop_back()
			popped_brick.hide_line()
		return
	
	var expected_numbers: Array[int]
	var prev_number = prev_brick.brick_number
	if selected_bricks.size() == 1:
		expected_numbers = [prev_number]
	else:
		expected_numbers = [prev_number, prev_number * 2]
	
	if prev_brick.is_adjacent(brick) and brick.brick_number in expected_numbers: 
		selected_bricks.push_back(brick)
		prev_brick.draw_line_target(brick.get_global_position())

func _unhandled_input(event):
	if event is InputEventMouseMotion and selected_bricks.size() > 0:
		selected_bricks[-1].draw_line_target(event.get_position())
	
	if (event is InputEventMouseButton
	  and event.is_released() 
	  and event.get_button_index() == MOUSE_BUTTON_LEFT):
		_handle_release_selected()
		

func _handle_release_selected():
	var selected_total: int = 0
	for brick in selected_bricks:
		brick.hide_line()
		selected_total += brick.brick_number
	
	if selected_bricks.size() <= 1:
		selected_bricks = []
		return
	
	var new_number = int(pow(2, floor(log(selected_total) / log(2))))
	
	selected_bricks.pop_back().brick_number = new_number
	
	while selected_bricks.size() > 0:
		var removed_brick = selected_bricks.pop_front()
		removed_brick.get_parent().remove_child(removed_brick)

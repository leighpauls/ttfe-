extends Node2D

var brick_scene = preload('res://Brick.tscn')

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
			new_brick.set_grid_position(grid_position)
			new_brick.clicked.connect(_on_brick_clicked)
			new_brick.hovered.connect(_on_brick_hovered)
			
			$Background.add_child(new_brick)

func _on_brick_clicked(brick: Brick, mouse_position: Vector2):
	selected_bricks = [brick]
	selected_bricks[-1].draw_line_target(mouse_position)

func _on_brick_hovered(brick: Brick):
	if selected_bricks.size() > 0 and brick not in selected_bricks:
		var prev_brick = selected_bricks[-1]
		selected_bricks.push_back(brick)
		prev_brick.draw_line_target(brick.get_global_position())

func _unhandled_input(event):
	if event is InputEventMouseMotion and selected_bricks.size() > 0:
		selected_bricks[-1].draw_line_target(event.get_position())
	
	if (event is InputEventMouseButton
	  and event.is_released() 
	  and event.get_button_index() == MOUSE_BUTTON_LEFT):
		for brick in selected_bricks:
			brick.hide_line()
		selected_bricks = []
		

extends Polygon2D
class_name Line

func set_target(target_point: Vector2):
	var delta = get_parent().to_local(target_point)
	
	var distance = delta.length()
	var angle = delta.angle()
	
	set_transform(
		Transform2D(
			angle,
			Vector2(distance/100.0, 1),
			0,
			Vector2.ZERO))

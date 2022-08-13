class_name LineOfSight
extends RayCast2D


func has_line_of_sight(target_pos: Vector2) -> bool:
	cast_to = target_pos - global_position
	force_raycast_update()
	return not is_colliding()

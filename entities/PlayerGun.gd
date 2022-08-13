class_name PlayerGun
extends Gun


func _process(_delta: float) -> void:
	global_rotation = get_global_mouse_position().angle_to_point(global_position)

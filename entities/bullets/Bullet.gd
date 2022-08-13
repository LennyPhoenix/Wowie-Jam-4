class_name Bullet
extends KinematicBody2D

export var speed := 600.0
export var target_radius := 30.0
export var damage := 25.0

var target_position: Vector2

onready var velocity := Vector2.RIGHT.rotated(rotation) * speed


func within_target_range() -> bool:
	assert(target_position, "No target position")
	return global_position.distance_squared_to(target_position) <= pow(target_radius, 2)


func _physics_process(_delta: float) -> void:
	velocity = move_and_slide(velocity)
	if get_slide_count() or (target_position and within_target_range()):
		var _tweener = create_tween()\
			.tween_property(self, "velocity", Vector2.ZERO, 0.1)

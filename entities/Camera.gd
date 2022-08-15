extends Node2D

onready var line_of_sight: RayCast2D = $LineOfSight
onready var rotate_group: Node2D = $RotateGroup

var target_angle: float


func _process(delta: float) -> void:
	var candidate: Node2D
	for player in get_tree().get_nodes_in_group("Player"):
		if line_of_sight.has_line_of_sight(player.global_position):
			if not candidate is Drone or not candidate:
				candidate = player

	if candidate:
		target_angle = candidate.global_position.angle_to_point(rotate_group.global_position)

	if target_angle:
		rotate_group.global_rotation = lerp_angle(
			rotate_group.global_rotation,
			target_angle,
			5*delta
		)

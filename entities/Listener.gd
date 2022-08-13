extends Node2D

signal heard_sound(pos)

enum Mode {
	PROXIMITY,
	LINE_OF_SIGHT,
	BOTH,
	EITHER,
}

export var radius := 100.0
export(Mode) var mode: int = Mode.EITHER

onready var line_of_sight: LineOfSight = $LineOfSight


func sound(pos: Vector2, volume: float) -> void:
	var in_proximity: bool = global_position.distance_squared_to(pos) <= pow(radius*volume, 2)
	var has_line_of_sight: bool = line_of_sight.has_line_of_sight(pos)

	var heard: bool
	match mode:
		Mode.PROXIMITY:
			heard = in_proximity
		Mode.LINE_OF_SIGHT:
			heard = has_line_of_sight
		Mode.EITHER:
			heard = in_proximity or has_line_of_sight
		Mode.BOTH:
			heard = in_proximity and has_line_of_sight

	if heard:
		emit_signal("heard_sound", pos)

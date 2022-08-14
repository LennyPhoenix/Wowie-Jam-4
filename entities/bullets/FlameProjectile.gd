extends Bullet

export var slow_time := 3.0


func _ready() -> void:
	var _tweener = create_tween()\
		.tween_property(self, "velocity", Vector2.ZERO, slow_time)


func _physics_process(_delta: float) -> void:
	velocity = move_and_slide(velocity)

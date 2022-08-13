extends Bullet

export var destroy_time := 0.1

var deleting := false


func destroy() -> void:
	deleting = true
	var _tweener = create_tween()\
		.tween_property(self, "modulate", Color.transparent, destroy_time)

	yield(get_tree().create_timer(destroy_time), "timeout")
	queue_free()

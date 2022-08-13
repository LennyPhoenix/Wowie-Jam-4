class_name DroneBullet
extends Bullet

export var destroy_time := 0.1

var can_delete := false
var deleting := false


func destroy() -> void:
	if not deleting and can_delete:
		deleting = true
		var _tweener = create_tween()\
			.tween_property(self, "modulate", Color.transparent, destroy_time)

		yield(get_tree().create_timer(destroy_time), "timeout")
		queue_free()


func _on_DestroyArea_body_entered(body: Node) -> void:
	if body.is_in_group("BotBullet"):
		destroy()


func _on_DeletableTimer_timeout() -> void:
	can_delete = true

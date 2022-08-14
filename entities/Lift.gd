extends Area2D

signal bot_entered()


func _on_Lift_body_entered(body: Node) -> void:
	if body is Bot:
		emit_signal("bot_entered")

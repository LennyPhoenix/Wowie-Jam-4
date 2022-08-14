class_name ConditionCollector
extends Node

signal conditions_valid()
signal conditions_invalid()

export(Array, NodePath) var conditionals := []

var was_valid := false


func _process(_delta: float) -> void:
	var valid := true
	for conditional in conditionals:
		var node = get_node_or_null(conditional)
		if node:
			if node is FloorButton and not node.is_pressed():
				valid = false
				break
			elif node is WallSwitch and not node.pressed:
				valid = false
				break
			elif node is Enemy and node.state != Enemy.State.DEAD:
				valid = false
				break

	if valid and not was_valid:
		emit_signal("conditions_valid")
		was_valid = valid
	elif not valid and was_valid:
		emit_signal("conditions_invalid")
		was_valid = valid

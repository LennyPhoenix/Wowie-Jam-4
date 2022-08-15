extends Control

var paused := false setget set_paused


func _ready() -> void:
	self.paused = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		self.paused = not self.paused


func _on_Resume_pressed() -> void:
	self.paused = false


func set_paused(new_paused: bool) -> void:
	paused = new_paused
	get_tree().paused = paused
	visible = paused

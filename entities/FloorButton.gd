class_name FloorButton
extends Area2D

signal pressed
signal unpressed

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var switch: AudioStreamPlayer2D = $Switch

var pressed := false setget set_pressed


func _physics_process(_delta: float) -> void:
	self.pressed = is_pressed()


func is_pressed() -> bool:
	return len(get_overlapping_bodies()) > 0


func set_pressed(new_pressed: bool) -> void:
	if new_pressed != pressed:
		pressed = new_pressed
		switch.play()
		if pressed:
			animation_player.play("Press")
			emit_signal("pressed")
		elif not is_pressed():
			animation_player.play("Unpress")
			emit_signal("unpressed")

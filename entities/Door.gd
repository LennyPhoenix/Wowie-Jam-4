tool
extends StaticBody2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sfx: AudioStreamPlayer2D = $SFX

export var open := false setget set_open


func toggle_open() -> void:
	self.open = not open


func set_open(new_open: bool) -> void:
	if new_open != open:
		open = new_open
		sfx.play()
		if open:
			animation_player.play("Opening")
		else:
			animation_player.play_backwards("Opening")

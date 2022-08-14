class_name WallSwitch
extends Area2D

signal pressed

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var particles_2d: Particles2D = $Particles2D
onready var smash: AudioStreamPlayer2D = $Smash

var pressed := false


func _on_WallSwitch_body_entered(body: Node) -> void:
	if not pressed and not body is DroneBullet:
		pressed = true
		particles_2d.emitting = true
		animation_player.play("Press")
		emit_signal("pressed")
		smash.play()

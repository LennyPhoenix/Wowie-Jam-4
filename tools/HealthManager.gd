class_name HealthManager
extends Node2D

signal dead()

onready var timer: Timer = $Timer
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var health_bar: HealthBar = $HealthBar
onready var hurt: AudioStreamPlayer2D = $Hurt

export var max_health := 100.0
export var regen_time := 2.0
export var regen_acceleration := 0.15
export var regen_amount := 5.0

onready var current_regen_time := regen_time
onready var health := max_health setget set_health


func set_health(new_health: float) -> void:
	health = new_health
	health_bar.set_health(health/max_health)


func damage(amount: float) -> void:
	hurt.play()
	self.health -= amount

	if health <= 0:
		emit_signal("dead")
		return

	current_regen_time = regen_time
	timer.start(current_regen_time)
	animation_player.play("Show")


func _on_Timer_timeout() -> void:
	if round(health) == round(max_health):
		animation_player.play("Hide")
		return

	current_regen_time -= regen_acceleration
	current_regen_time = max(current_regen_time, 0.2)
	timer.start(current_regen_time)

	self.health += regen_amount
	self.health = min(health, max_health)

class_name Drone
extends KinematicBody2D

signal dead()

onready var camera: Camera2D = $Camera
onready var tracker_gun: PlayerGun = $TrackerGun
onready var killer_gun: PlayerGun = $KillerGun
onready var right_particles: Particles2D = $RightParticles
onready var left_particles: Particles2D = $LeftParticles
onready var health_manager: HealthManager = $HealthManager
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite
onready var particles_2d: Particles2D = $Particles2D
onready var death_sound: AudioStreamPlayer2D = $DeathSound

export var max_speed := 200.0
export var acceleration := 800.0
export var friction := 350.0

export var rot_max_speed := 360.0
export var rot_acceleration := 600.0
export var rot_friction := 1200.0

var move_velocity := Vector2.ZERO
var move_intent := 0.0
var rot_speed := 0.0
var rot_intent := 0.0
var dead := false


func _ready() -> void:
	health_manager.set_as_toplevel(true)


func _process(_delta: float) -> void:
	if dead: return

	health_manager.global_position = global_position - Vector2(0, 10)
	move_intent = Input.get_axis("brake", "accelerate")
	rot_intent = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("shoot_left"):
		get_tree().call_group("TrackerBullet", "set", "can_delete", true)
		get_tree().call_group("TrackerBullet", "destroy")
		var bullet = tracker_gun.shoot()
		bullet.target_position = get_global_mouse_position()
		get_tree().call_group("Listener", "sound", global_position, 1.5)
	if Input.is_action_just_pressed("shoot_right"):
		var bullet = killer_gun.shoot()
		bullet.target_position = get_global_mouse_position()
		get_tree().call_group("Listener", "sound", global_position, 1.0)

	left_particles.emitting = move_intent
	right_particles.emitting = move_intent
	if move_intent or rot_intent:
		animation_player.play("Roll")
	else:
		animation_player.play("Idle")


func _physics_process(delta: float) -> void:
	if dead: return

	# Position
	var acc: float = (acceleration if move_intent else friction) * delta
	var target_speed: float = max_speed

	var move_vec := (Vector2.RIGHT*move_intent).rotated(rotation)
	move_velocity = move_velocity.move_toward(move_vec * target_speed, acc)
	move_velocity = move_and_slide(move_velocity)

	camera.position.x = move_intent * target_speed * 0.1

	# Rotation
	var rot_acc: float = (
		rot_acceleration
		if rot_intent and sign(rot_intent) == sign(rot_speed)
		else rot_friction
	) * delta
	var rot_target_speed: float = rot_max_speed

	var difference = (rot_intent * rot_target_speed) - rot_speed
	rot_speed += sign(difference) * max(rot_acc, abs(difference))
	rotation_degrees += rot_speed * delta


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("EnemyBullet"):
		health_manager.damage(body.damage)
		body.queue_free()


func _on_HealthManager_dead() -> void:
	if not dead:
		death_sound.play()
		sprite.visible = false
		tracker_gun.visible = false
		killer_gun.visible = false
		particles_2d.emitting = true
		dead = true
		emit_signal("dead")

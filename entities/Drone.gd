extends KinematicBody2D

onready var camera: Camera2D = $Camera
onready var tracker_gun: PlayerGun = $TrackerGun
onready var killer_gun: PlayerGun = $KillerGun
onready var right_particles: Particles2D = $RightParticles
onready var left_particles: Particles2D = $LeftParticles

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


func _process(_delta: float) -> void:
	move_intent = Input.get_axis("brake", "accelerate")
	rot_intent = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("shoot_left"):
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


func _physics_process(delta: float) -> void:
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

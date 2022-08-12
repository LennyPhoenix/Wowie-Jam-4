extends KinematicBody2D

onready var camera: Camera2D = $Camera
onready var tracker_gun: Node2D = $TrackerGun
onready var killer_gun: Node2D = $KillerGun

export var max_speed := 200.0
export var acceleration := 800.0
export var friction := 350.0

export var rot_max_speed := 180.0
export var rot_acceleration := 600.0
export var rot_friction := 500.0

var move_velocity := Vector2.ZERO
var move_intent := 0.0
var rot_speed := 0.0
var rot_intent := 0.0


func _process(_delta: float) -> void:
	move_intent = Input.get_axis("brake", "accelerate")
	rot_intent = Input.get_axis("left", "right")

	var mouse: Vector2 = get_global_mouse_position()
	tracker_gun.global_rotation = mouse.angle_to_point(tracker_gun.global_position)
	killer_gun.global_rotation = mouse.angle_to_point(killer_gun.global_position)


func _physics_process(delta: float) -> void:
	# Position
	var acc: float = (acceleration if move_intent else friction) * delta
	var target_speed: float = max_speed

	var move_vec := (Vector2.RIGHT*move_intent).rotated(rotation)
	move_velocity = move_velocity.move_toward(move_vec * target_speed, acc)
	move_velocity = move_and_slide(move_velocity)

	camera.position.x = move_intent * target_speed * 0.1

	# Rotation
	var rot_acc: float = (rot_acceleration if rot_intent else rot_friction) * delta
	var rot_target_speed: float = rot_max_speed

	rot_speed = (Vector2.RIGHT*rot_speed).move_toward(Vector2.RIGHT * rot_intent * rot_target_speed, rot_acc).x
	rotation_degrees += rot_speed * delta

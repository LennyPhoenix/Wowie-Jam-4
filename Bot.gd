extends KinematicBody2D

export var max_speed := 300.0
export var acceleration := 1000.0
export var friction := 3000.0

onready var line_of_sight: RayCast2D = $LineOfSight
onready var navigation: NavigationAgent2D = $Navigation
onready var legs: Node2D = $Legs
onready var top: Node2D = $Top
onready var left_gun: Gun = $Top/LeftGun
onready var right_gun: Gun = $Top/RightGun
onready var nav_target: Sprite = $Debug/Target
onready var movement_direction: RayCast2D = $Debug/MoveIntention

var tracking := false
var tracker: Bullet
var last_tracker_position: Vector2
var target_position: Vector2

var shooting := false

var move_velocity := Vector2.ZERO


func _process(_delta: float) -> void:
	for bullet in get_tree().get_nodes_in_group("TrackerBullet"):
		if not bullet.deleting and (not tracking or bullet == tracker):
			# Check line of sight
			line_of_sight.cast_to = bullet.global_position - global_position
			line_of_sight.force_raycast_update()
			if not line_of_sight.is_colliding():
				last_tracker_position = bullet.global_position
				navigation.set_target_location(last_tracker_position)
				tracker = bullet
				tracking = true

	# Horrendous tracking code
	target_position = navigation.get_next_location()
	if tracking:
		var angle = target_position.angle_to_point(global_position)
		legs.rotation = angle
		if not shooting:
			top.rotation = angle
	if not is_instance_valid(tracker):
		tracking = false
	if navigation.is_navigation_finished() and tracking:
		if is_instance_valid(tracker) and not tracker.deleting:
			tracker.destroy()
		tracking = false


func _physics_process(delta: float) -> void:
	var move_intent := Vector2.ZERO
	if tracking:
		nav_target.global_position = target_position
		move_intent = (target_position - global_position).normalized()

	var acc: float = (acceleration if move_intent else friction) * delta
	var target_speed: float = max_speed

	movement_direction.cast_to = move_intent * 100

	move_velocity = move_velocity.move_toward(move_intent * target_speed, acc)
	move_velocity = move_and_slide(move_velocity)

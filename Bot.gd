extends KinematicBody2D

export var max_speed := 300.0
export var acceleration := 1000.0
export var friction := 3000.0

onready var line_of_sight: LineOfSight = $LineOfSight
onready var navigation: NavigationAgent2D = $Navigation
onready var shoot_timer: Timer = $ShootTimer
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
var shooting_target: Bullet
var right_gun_next := false

var move_velocity := Vector2.ZERO


func _process(_delta: float) -> void:
	deal_with_trackers()
	deal_with_killers()


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


func _on_ShootTimer_timeout() -> void:
	if shooting:
		if right_gun_next:
			var _bullet = right_gun.shoot()
		else:
			var _bullet = left_gun.shoot()
		right_gun_next = not right_gun_next


func deal_with_trackers() -> void:
	for bullet in get_tree().get_nodes_in_group("TrackerBullet"):
		if not bullet.deleting and (not tracking or bullet == tracker):
			if line_of_sight.has_line_of_sight(bullet.global_position):
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
		if is_instance_valid(tracker):
			tracker.destroy()
		tracking = false


func deal_with_killers() -> void:
	if shooting and is_instance_valid(shooting_target):
		if shooting_target.deleting:
			shooting = false
		else:
			if not line_of_sight.has_line_of_sight(shooting_target.global_position):
				shooting = false

	for bullet in get_tree().get_nodes_in_group("KillerBullet"):
		if not bullet.deleting and not shooting:
			if line_of_sight.has_line_of_sight(bullet.global_position):
				shooting_target = bullet
				shooting = true

	if shooting:
		top.global_rotation = shooting_target.global_position.angle_to_point(global_position)
		left_gun.global_rotation = shooting_target.global_position.angle_to_point(left_gun.global_position)
		right_gun.global_rotation = shooting_target.global_position.angle_to_point(right_gun.global_position)

extends KinematicBody2D

enum State {
	PATROLLING,
	SUSPICIOUS,
	INVESTIGATING,
	ENGAGING,
	DEAD,
}

export(Array, NodePath) var patrol_points := []
export var current_patrol_target := 0

export var max_speed := 100.0
export var acceleration := 1500.0
export var friction := 6000.0

export var max_health := 100.0
export var field_of_view := 100.0
export var confirmed_angle := 10.0
export var chase_distance := 130.0

onready var gun: Gun = $RotateGroup/Gun
onready var navigation: NavigationAgent2D = $Navigation
onready var nav_target: Sprite = $Debug/Target
onready var vision: Area2D = $RotateGroup/Vision
onready var move_indicator: RayCast2D = $Debug/MoveIntention
onready var line_of_sight: LineOfSight = $LineOfSight
onready var rotate_group: Node2D = $RotateGroup
onready var hitbox: Area2D = $Hitbox

var state: int = State.PATROLLING setget set_state
var health: float = max_health setget set_health
var investigating := false
var investigation_coroutine
const CANCEL = true

var move_velocity := Vector2.ZERO
var target_position: Vector2
var last_seen_position := Vector2.ZERO


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		self.state = State.PATROLLING

	target_position = navigation.get_next_location()

	match state:
		State.PATROLLING:
			if len(patrol_points) > 0:
				var current_point = get_node(patrol_points[current_patrol_target]).global_position
				var angle = target_position.angle_to_point(global_position)
				rotate_group.global_rotation = angle
				if navigation.is_target_reached():
					current_patrol_target = (current_patrol_target + 1) % len(patrol_points)
				navigation.set_target_location(current_point)
		State.SUSPICIOUS:
			if navigation.is_navigation_finished():
				state = State.INVESTIGATING
				investigation_coroutine = investigate()
		State.ENGAGING:
			rotate_group.rotation = last_seen_position.angle_to_point(global_position)
			gun.global_rotation = last_seen_position.angle_to_point(gun.global_position)

	for node in get_tree().get_nodes_in_group("Player"):
		var angle_to_player: float = node.global_position.angle_to_point(global_position)
		var current_angle := rotate_group.global_rotation
		var r_diff := angle_to_player - current_angle
		if abs(rad2deg(r_diff)) <= field_of_view/2:
			player_seen(node)

	for body in vision.get_overlapping_bodies():
		if body.is_in_group("Player"):
			player_seen(body)


func _physics_process(delta: float) -> void:
	var move_intent := Vector2.ZERO
	match state:
		State.PATROLLING:
			if len(patrol_points) > 0 and target_position.distance_squared_to(global_position) > 25:
				nav_target.global_position = target_position
				move_intent = (target_position - global_position).normalized()
		State.SUSPICIOUS:
			nav_target.global_position = target_position
			move_intent = (target_position - global_position).normalized()
		State.ENGAGING:
			if global_position.distance_squared_to(last_seen_position) > pow(chase_distance, 2):
				nav_target.global_position = target_position
				move_intent = (target_position - global_position).normalized()

	var acc: float = (acceleration if move_intent else friction) * delta
	var target_speed: float = max_speed

	move_indicator.cast_to = move_intent * 100

	move_velocity = move_velocity.move_toward(move_intent * target_speed, acc)
	move_velocity = move_and_slide(move_velocity)


func _on_Listener_heard_sound(pos: Vector2) -> void:
	self.state = State.SUSPICIOUS
	last_seen_position = pos
	var _tweener = create_tween().tween_property(rotate_group, "global_rotation",
		last_seen_position.angle_to_point(global_position),
		0.8
	)
	navigation.set_target_location(last_seen_position)


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("BotBullet"):
		self.health -= body.damage
		body.queue_free()


func set_health(new_health: float):
	health = new_health
	if health < 0:
		queue_free() # TODO: Death


func player_seen(player: Node2D) -> void:
	if line_of_sight.has_line_of_sight(player.global_position):
		self.state = State.SUSPICIOUS
		last_seen_position = player.global_position
		navigation.set_target_location(last_seen_position)
		var _tweener = create_tween().tween_property(rotate_group, "global_rotation",
			last_seen_position.angle_to_point(global_position),
			0.8
		)


func investigate() -> void:
	var res = yield(get_tree().create_timer(0.2), "timeout")
	if res: return
	var left = rotation_degrees - 90
	var right = rotation_degrees + 90
	var tweener = create_tween().tween_property(rotate_group, "rotation_degrees",
		left,
		0.3
	)
	res = yield(tweener, "finished")
	if res: return
	res = yield(get_tree().create_timer(0.8), "timeout")
	if res: return
	tweener = create_tween().tween_property(rotate_group, "rotation_degrees",
		right,
		0.3
	)
	res = yield(tweener, "finished")
	if res: return
	res = yield(get_tree().create_timer(0.8), "timeout")
	if res: return
	state = State.PATROLLING


func set_state(new_state: int) -> void:
	if new_state != State.INVESTIGATING and state == State.INVESTIGATING:
		investigation_coroutine.resume(CANCEL)
	state = new_state

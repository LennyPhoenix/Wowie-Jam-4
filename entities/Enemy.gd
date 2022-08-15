class_name Enemy
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

export var field_of_view := 90.0
export var confirmed_angle := 15.0
export var chase_distance := 60.0

onready var gun: Gun = $RotateGroup/Gun
onready var collider: CollisionShape2D = $Collider
onready var health_manager: HealthManager = $HealthManager
onready var navigation: NavigationAgent2D = $Navigation
onready var nav_target: Sprite = $Debug/Target
onready var move_indicator: RayCast2D = $Debug/MoveIntention
onready var line_of_sight: LineOfSight = $LineOfSight
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var rotate_group: Node2D = $RotateGroup
onready var hitbox: Area2D = $Hitbox
onready var death_sound: AudioStreamPlayer2D = $DeathSound

var state: int = State.PATROLLING
var investigating := false
var engaged_target: Node2D

var move_velocity := Vector2.ZERO
var target_position: Vector2
var last_seen_position := Vector2.ZERO
var target_rotation: float


func _process(_delta: float) -> void:
	target_position = navigation.get_next_location()

	match state:
		State.PATROLLING:
			if len(patrol_points) > 0:
				target_rotation = target_position.angle_to_point(global_position)
				if navigation.is_target_reached():
					current_patrol_target = (current_patrol_target + 1) % len(patrol_points)
				var current_point = get_node(patrol_points[current_patrol_target]).global_position
				navigation.set_target_location(current_point)
		State.SUSPICIOUS:
			if navigation.is_navigation_finished():
				state = State.INVESTIGATING
				investigate()
		State.ENGAGING:
			target_rotation = target_position.angle_to_point(global_position)
			gun.global_rotation = last_seen_position.angle_to_point(gun.global_position)
			if navigation.is_navigation_finished() or not is_instance_valid(engaged_target):
				state = State.INVESTIGATING
				investigate()
		State.DEAD:
			return

	var fov_normal: Vector2 = Vector2.RIGHT.rotated(rotate_group.global_rotation)
	for player in get_tree().get_nodes_in_group("Player"):
		if line_of_sight.has_line_of_sight(player.global_position):
			var player_normal: Vector2 = (player.global_position - global_position).normalized()
			var r_diff = rad2deg(acos(fov_normal.dot(player_normal)))
			if r_diff <= confirmed_angle/2:
				state = State.ENGAGING
				engaged_target = player
			elif r_diff <= field_of_view/2:
				if state == State.ENGAGING and player == engaged_target:
					last_seen_position = player.global_position
					nav_target.global_position = last_seen_position
					navigation.set_target_location(last_seen_position)
					target_rotation = last_seen_position.angle_to_point(global_position)
				else:
					player_seen(player)


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
			if not is_instance_valid(engaged_target):
				return
			if global_position.distance_squared_to(engaged_target.global_position) > pow(chase_distance, 2):
				move_intent = (target_position - global_position).normalized()
		State.DEAD:
			return

	if move_intent != Vector2.ZERO:
		animation_player.play("Running")
	else:
		animation_player.play("Idle")

	var acc: float = (acceleration if move_intent else friction) * delta
	var target_speed: float = max_speed

	move_indicator.cast_to = move_intent * 100

	move_velocity = move_velocity.move_toward(move_intent * target_speed, acc)
	move_velocity = move_and_slide(move_velocity)

	if target_rotation:
		rotate_group.global_rotation = lerp_angle(
			rotate_group.global_rotation,
			target_rotation,
			6*delta
		)


func _on_Listener_heard_sound(pos: Vector2) -> void:
	if state == State.DEAD or state == State.ENGAGING:
		return

	state = State.SUSPICIOUS
	last_seen_position = pos
	target_rotation = last_seen_position.angle_to_point(global_position)
	navigation.set_target_location(last_seen_position)


func _on_Hitbox_body_entered(body: Node) -> void:
	if state != State.DEAD:
		if body.is_in_group("BotBullet"):
			health_manager.damage(body.damage)
			player_seen(body)
			body.queue_free()
		elif body.is_in_group("Player"):
			player_seen(body)


func player_seen(player: Node2D) -> void:
	if state != State.ENGAGING and state != State.DEAD:
		state = State.SUSPICIOUS
		last_seen_position = player.global_position
		navigation.set_target_location(last_seen_position)
		target_rotation = last_seen_position.angle_to_point(global_position)


func investigate() -> void:
	yield(get_tree().create_timer(0.2), "timeout")
	if state != State.INVESTIGATING: return
	var left = rotation_degrees - 90
	var right = rotation_degrees + 90
	var behind = rotation_degrees + 180
	target_rotation = deg2rad(left)
	yield(get_tree().create_timer(0.8), "timeout")
	if state != State.INVESTIGATING: return
	target_rotation = deg2rad(right)
	yield(get_tree().create_timer(0.8), "timeout")
	if state != State.INVESTIGATING: return
	target_rotation = deg2rad(behind)
	yield(get_tree().create_timer(0.8), "timeout")
	if state != State.INVESTIGATING: return
	state = State.PATROLLING


func _on_ShootTimer_timeout() -> void:
	if state == State.ENGAGING:
		var _bullet = gun.shoot()
		get_tree().call_group("Listener", "sound", global_position, 3.0)


func _on_HealthManager_dead() -> void:
	state = State.DEAD
	death_sound.play()
	health_manager.visible = false
	collider.set_deferred("disabled", true)
	animation_player.play("Dead")

class_name Drone
extends KinematicBody2D

signal dead()

onready var camera: Camera2D = $Camera
onready var health_manager: HealthManager = $HealthManager
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var right_particles: Particles2D = $Collider/RightParticles
onready var left_particles: Particles2D = $Collider/LeftParticles
onready var hitbox: Area2D = $Collider/Hitbox
onready var sprite: Sprite = $Collider/Sprite
onready var tracker_gun: Node2D = $Collider/TrackerGun
onready var killer_gun: Node2D = $Collider/KillerGun
onready var particles_2d: Particles2D = $Collider/Particles2D
onready var death_sound: AudioStreamPlayer2D = $DeathSound
onready var collider: CollisionShape2D = $Collider

export var max_speed := 200.0
export var acceleration := 800.0
export var friction := 550.0

var move_velocity := Vector2.ZERO
var move_intent := Vector2.ZERO
var dead := false


func _ready() -> void:
	health_manager.set_as_toplevel(true)


func _process(_delta: float) -> void:
	if dead: return

	health_manager.global_position = global_position - Vector2(0, 10)

	move_intent = Vector2.ZERO
	move_intent.x = Input.get_axis("left", "right")
	move_intent.y = Input.get_axis("up", "down")
	move_intent = move_intent.normalized()

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

	left_particles.emitting = move_intent != Vector2.ZERO
	right_particles.emitting = move_intent != Vector2.ZERO
	if move_intent:
		animation_player.play("Roll")
	else:
		animation_player.play("Idle")


func _physics_process(delta: float) -> void:
	if dead: return

	# Position
	var acc: float = (acceleration if move_intent else friction) * delta
	var target_speed: float = max_speed

	move_velocity = move_velocity.move_toward(move_intent * target_speed, acc)
	move_velocity = move_and_slide(move_velocity)

	camera.position = move_intent * target_speed * 0.1

	# Rotation
	if move_intent:
		collider.global_rotation = lerp_angle(collider.global_rotation, move_intent.angle(), 0.2)


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

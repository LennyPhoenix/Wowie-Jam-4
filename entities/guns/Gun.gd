class_name Gun
extends Node2D

export var bullet_scene: PackedScene
export var spread := 5.0

onready var emitter: Position2D = $Emitter
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var gunshot: AudioStreamPlayer2D = $Gunshot
var entities: Node2D


func shoot() -> Bullet:
	assert(bullet_scene, "Bullet scene invalid")

	if animation_player.has_animation("Shoot"):
		animation_player.play("Shoot")

	gunshot.play()

	var bullet: Bullet = bullet_scene.instance()
	bullet.set_as_toplevel(true)
	bullet.global_transform = emitter.global_transform
	bullet.rotation_degrees += (randf()*2-1)*spread

	if not entities:
		var parent: Node = get_parent()
		while parent.name != "Entities":
			parent = parent.get_parent()
		entities = parent

	entities.add_child(bullet)

	return bullet

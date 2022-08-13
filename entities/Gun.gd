class_name Gun
extends Node2D

export var bullet_scene: PackedScene

onready var emitter: Position2D = $Emitter


func shoot() -> Bullet:
	assert(bullet_scene, "Bullet scene invalid")

	var bullet: Bullet = bullet_scene.instance()
	bullet.set_as_toplevel(true)
	bullet.global_transform = emitter.global_transform
	add_child(bullet)

	return bullet

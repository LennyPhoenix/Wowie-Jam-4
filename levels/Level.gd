class_name Level
extends Node2D

signal restart()
signal finished()
signal failed()

const DRONE_SCENE = preload("res://entities/Drone.tscn")

onready var bot: Bot = $"%Bot"
onready var drone: Drone = $"%Drone"
onready var entities: Node2D = $Entities
onready var failure: Control = $UI/Failure
onready var color_rect: ColorRect = $UI/ColorRect


func _ready() -> void:
	color_rect.color = Color.black
	var _tweener = create_tween().tween_property(color_rect, "color",
		Color(0, 0, 0, 0),
		0.5
	)


func _on_Bot_dead() -> void:
	failure.visible = true
	emit_signal("failed")


func _on_Drone_dead() -> void:
	yield(get_tree().create_timer(1), "timeout")
	drone.queue_free()
	drone = DRONE_SCENE.instance()
	bot.get_parent().add_child_below_node(bot, drone)
	drone.global_position = bot.global_position
	var _res = drone.connect("dead", self, "_on_Drone_dead")


func _on_Restart_pressed() -> void:
	emit_signal("restart")


func _on_Lift_bot_entered() -> void:
	var tweener = create_tween().tween_property(color_rect, "color",
		Color.black,
		0.5
	)
	yield(tweener, "finished")
	emit_signal("finished")

extends Node

export(Array, PackedScene) var levels := []
export var current_level := 0

var level: Level

onready var ui: CanvasLayer = $UI
onready var menu: AudioStreamPlayer = $Music/Menu
onready var sneak: AudioStreamPlayer = $Music/Sneak
onready var attack: AudioStreamPlayer = $Music/Attack
onready var death: AudioStreamPlayer = $Music/Death

var menu_music := true
var attacking_music := false setget set_attacking_music


func load_level() -> void:
	level = levels[current_level].instance()
	add_child(level)
	var _res = level.connect("restart", self, "_on_Level_restart")
	_res = level.connect("finished", self, "_on_Level_finished")
	_res = level.connect("failed", self, "_on_Level_failed")
	if menu_music:
		menu_music = false
		attacking_music = false
		menu.stop()
		sneak.play()
		attack.play()
		attack.volume_db = -100


func set_attacking_music(new_attacking_music: bool) -> void:
	if new_attacking_music != attacking_music:
		attacking_music = new_attacking_music
		if attacking_music:
			sneak.volume_db = -100
			attack.volume_db = 0
		else:
			sneak.volume_db = 0
			attack.volume_db = -100


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

	if not menu_music:
		var sneaking = true
		for node in get_tree().get_nodes_in_group("Enemy"):
			if node.state == Enemy.State.ENGAGING:
				sneaking = false
				break
		self.attacking_music = not sneaking


func _on_Start_pressed() -> void:
	ui.visible = false
	load_level()


func _on_Level_restart() -> void:
	level.queue_free()
	load_level()


func _on_Level_finished() -> void:
	current_level += 1
	level.queue_free()
	load_level()


func _on_Level_failed() -> void:
	menu_music = true
	self.attacking_music = false
	sneak.stop()
	attack.stop()
	death.play()
	yield(death, "finished")
	if menu_music:
		menu.play()

extends MarginContainer


func _on_Pixelated_toggled(button_pressed: bool) -> void:
	var mode = SceneTree.STRETCH_MODE_VIEWPORT if button_pressed else SceneTree.STRETCH_MODE_2D
	get_tree().set_screen_stretch(mode, SceneTree.STRETCH_ASPECT_KEEP, Vector2(480, 270))


func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed

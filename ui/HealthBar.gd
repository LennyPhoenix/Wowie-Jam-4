class_name HealthBar
extends PanelContainer

onready var progress_bar: ProgressBar = $ProgressBar


func get_health() -> float:
	return progress_bar.value / 100


func set_health(health: float) -> void:
	progress_bar.value = health * 100

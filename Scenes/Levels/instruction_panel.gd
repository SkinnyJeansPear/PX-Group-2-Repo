extends Control

@onready var start_game: Button = $ColorRect/StartGame

func _ready():
	get_tree().paused = true

func _on_start_game_pressed() -> void:
	hide()
	get_tree().paused = false

extends Control

@onready var start_game: Button = $ColorRect/StartGame

func _ready():
	get_tree().paused = true
	start_game.pressed.connect(_on_start_game_pressed)

func _on_start_game_pressed() -> void:
	hide()
	get_tree().paused = false

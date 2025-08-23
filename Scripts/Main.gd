extends Node2D

func _on_submit_button_pressed() -> void:
	var game_manager = get_tree().get_root().get_node("Main/GameManager")
	if game_manager:
		game_manager.submit_score()
	else:
		print("GameManager not found in scene tree!")

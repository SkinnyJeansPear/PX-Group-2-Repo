extends Control

func _on_start_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")

func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

extends Control

func _on_start_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tutorial/Tutorial.tscn")

extends Control
@onready var menu_click: AudioStreamPlayer = $menu_click

func _on_start_tutorial_pressed() -> void:
	menu_click.play()
	await menu_click.finished
	get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")

func _on_level_select_pressed() -> void:
	menu_click.play()
	await menu_click.finished
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

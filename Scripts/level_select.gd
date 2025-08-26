extends Control
@onready var menu_click: AudioStreamPlayer = $menu_click

func _play_click_and_change_scene(scene_path: String) -> void:
	menu_click.play()
	await menu_click.finished
	get_tree().change_scene_to_file(scene_path)

func _on_back_pressed() -> void:
	_play_click_and_change_scene("res://Scenes/main_menu.tscn")

func _on_parking_lot_pressed() -> void:
	_play_click_and_change_scene("res://Scenes/Levels/ParkingLot.tscn")

# when adding the rest of the scenes, do it like this format
#func _on_parking_lot_pressed() -> void:
	#_play_click_and_change_scene("res://Scenes/Levels/ParkingLot.tscn")

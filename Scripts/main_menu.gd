# res://Scripts/main_menu.gd
extends Control

func _get_click_player() -> AudioStreamPlayer:
	var n := get_node_or_null("menu_click")
	if n and n is AudioStreamPlayer:
		return n
	push_warning("menu_click AudioStreamPlayer not found; continuing without click SFX.")
	return null

func _on_start_tutorial_pressed() -> void:
	var click := _get_click_player()
	if click and click.stream:
		click.play()
		await click.finished
	var st := get_tree()
	if st:
		st.change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")
	else:
		push_error("SceneTree is null. Cannot change scene.")

func _on_level_select_pressed() -> void:
	var click := _get_click_player()
	if click and click.stream:
		click.play()
		await click.finished
	var st := get_tree()
	if st:
		st.change_scene_to_file("res://Scenes/level_select.tscn")
	else:
		push_error("SceneTree is null. Cannot change scene.")

func _on_about_cpted_pressed() -> void:
	var click := _get_click_player()
	if click and click.stream:
		click.play()
		await click.finished
	var st := get_tree()
	if st:
		st.change_scene_to_file("res://Scenes/about_cpted.tscn")
	else:
		push_error("SceneTree is null. Cannot change scene.")

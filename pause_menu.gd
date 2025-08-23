extends Control
@onready var menu_click: AudioStreamPlayer = $menu_click

func _ready():
	$AnimationPlayer.play("RESET")
	hide()

func resume():
	menu_click.play()
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	hide()
	
func pause():
	menu_click.play()
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	show()

func testEsc():
	if Input.is_action_just_pressed("escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()
	
func _on_resume_pressed() -> void:
	menu_click.play()
	resume()

#the sound wont get cut off
func _on_restart_pressed() -> void:
	menu_click.play()
	await menu_click.finished
	resume()
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	menu_click.play()
	await menu_click.finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _process(delta):
	testEsc()

extends Node

@onready var current_level = $CurrentLevel
@onready var button = $LoadLevelButton

func _ready():
	button.pressed.connect(_on_load_level_button_pressed)

func _on_load_level_button_pressed():
	# Clear existing level if any
	for child in current_level.get_children():
		child.queue_free()

	# Load the level scene
	var level_scene = preload("res://scenes/levels/Level_Park.tscn")
	var level_instance = level_scene.instantiate()
	current_level.add_child(level_instance)
	
	button.visible = false

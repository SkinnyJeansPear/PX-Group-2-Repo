# res://Scripts/end_panel.gd
extends Control
class_name EndPanel

@export_file("*.tscn") var next_level_path: String = ""   # set per level (e.g., ParkingLot.tscn)
@export var show_feedback_placeholder: bool = true        # reserve space for future feedback

@onready var score_label: Label = $Panel/VBox/Score
@onready var feedback_label: Label = $Panel/VBox/Feedback
@onready var btn_restart: Button = $Panel/VBox/Buttons/Restart
@onready var btn_next: Button = $Panel/VBox/Buttons/NextLevel
@onready var btn_menu: Button = $Panel/VBox/Buttons/MainMenu

var _frozen: bool = false

func _ready() -> void:
	visible = false
	btn_restart.pressed.connect(_on_restart)
	btn_next.pressed.connect(_on_next)
	btn_menu.pressed.connect(_on_menu)

func open_results() -> void:
	# Freeze the score at the moment of submit
	_frozen = true
	var final_score: int = 0
	if has_node("/root/ScoreManager"):
		final_score = get_node("/root/ScoreManager").score
	
	score_label.text = "Final Score: %d" % final_score
	
	if show_feedback_placeholder:
		feedback_label.visible = true
		feedback_label.text = "Feedback: (coming soon)"
	else:
		feedback_label.visible = false
	
	visible = true
	# Optionally, block input behind the panel
	set_process_input(true)
	get_tree().paused = true  # pause gameplay; UI will still work if set as process mode 'when paused'
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_next() -> void:
	get_tree().paused = false
	if next_level_path != "" and ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		# Fallback to level select
		if ResourceLoader.exists("res://Scenes/level_select.tscn"):
			get_tree().change_scene_to_file("res://Scenes/level_select.tscn")
		else:
			push_warning("Next level path not set or missing.")

func _on_menu() -> void:
	get_tree().paused = false
	if ResourceLoader.exists("res://Scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		push_warning("Main menu scene not found.")

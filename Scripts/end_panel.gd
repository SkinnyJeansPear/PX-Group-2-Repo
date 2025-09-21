
extends Control
class_name EndPanel

@export_file("*.tscn") var next_level_path: String = ""
@export var show_feedback_placeholder: bool = true

enum FeedbackMode { STATIC_ONLY, STATIC_PLUS_DYNAMIC }
@export var feedback_mode: FeedbackMode = FeedbackMode.STATIC_PLUS_DYNAMIC
@export var per_level_feedback: Dictionary = {
	"Tutorial": "Tip: Remove the hazards and place the safety items sensibly.",
	"ParkingLot": "Tip: Clear hazards and use fences/lighting/bins to protect pedestrians.",
	"BasketballCourt": "Tip: Remove sharp debris and secure the court area with lighting/fencing.",
	"StoreFronts": "Tip: Remove environmental hazards and place barriers/bins/lighting where appropriate."
}
@export var pass_score: int = 30

@onready var score_label: Label = $Panel/VBox/Score
@onready var feedback_label: Label = $Panel/VBox/Feedback
@onready var btn_restart: Button = $Panel/VBox/Buttons/Restart
@onready var btn_next: Button = $Panel/VBox/Buttons/NextLevel
@onready var btn_menu: Button = $Panel/VBox/Buttons/MainMenu

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 10000
	process_mode = Node.PROCESS_MODE_ALWAYS
	btn_restart.pressed.connect(_on_restart)
	btn_next.pressed.connect(_on_next)
	btn_menu.pressed.connect(_on_menu)

func open_results() -> void:
	var final_score: int = 0
	if has_node("/root/ScoreManager"):
		final_score = get_node("/root/ScoreManager").score
	score_label.text = "Final Score: %d" % final_score

	var fb: String = _build_feedback(final_score)
	if fb == "" and show_feedback_placeholder:
		fb = "Feedback: (coming soon)"
	feedback_label.visible = fb != ""
	feedback_label.text = fb

	visible = true
	get_tree().paused = true
	
	#if has_node("/root/ScoreManager"):
	#	get_node("/root/ScoreManager").debug_print_progress()
		

func _get_level_id() -> String:
	var id: String = ""
	if get_tree() != null and get_tree().current_scene != null:
		var cs: Node = get_tree().current_scene
		id = str(cs.name)
		# Prefer the scene file’s base name, e.g., "Tutorial" from ".../Tutorial.tscn"
		if "scene_file_path" in cs:
			var p: String = String(cs.scene_file_path)
			if p != "":
				var base := p.get_file().get_basename()
				if base != "":
					id = base
	return id

func _build_feedback(final_score:int) -> String:
	var lines: Array[String] = []
	var lvl: String = _get_level_id()

	# Static per-level note
	if per_level_feedback.has(lvl):
		var msg: String = str(per_level_feedback[lvl])
		if msg != "":
			lines.append(msg)

	# Dynamic hints
	if feedback_mode == FeedbackMode.STATIC_PLUS_DYNAMIC and has_node("/root/ScoreManager"):
		var sm: Node = get_node("/root/ScoreManager")

		if final_score < pass_score:
			lines.append("Try to reach at least %d points." % pass_score)

		if lvl == "Tutorial":
			# Safe items: list names when missing
			if sm.has_method("missing_required_safe"):
				var miss_safe: Array = sm.missing_required_safe()
				if not miss_safe.is_empty():
					# optional pretty names
					var pretty: Array[String] = []
					var friendly := {"lamp":"Lamp", "netted_fence":"Netted Fence", "trashcan":"Trash Can"}
					for k in miss_safe:
						pretty.append(friendly.get(String(k), String(k)))
					lines.append("Safe items not placed correctly: " + ", ".join(pretty))
			# Unsafe stays generic as requested
			if sm.has_method("any_required_unsafe_left") and sm.any_required_unsafe_left():
				lines.append("You left some unsafe items unremoved.")
		else:
			# Generic for non-tutorial levels
			if sm.has_method("any_required_unsafe_left") and sm.any_required_unsafe_left():
				lines.append("You left some unsafe items unremoved.")
			if sm.has_method("any_required_safe_missed") and sm.any_required_safe_missed():
				lines.append("Some safety items weren’t placed correctly.")

	if lines.is_empty():
		return ""
	return "Feedback:\n- " + "\n- ".join(lines)

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_next() -> void:
	get_tree().paused = false
	if next_level_path != "" and ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	elif ResourceLoader.exists("res://Scenes/level_select.tscn"):
		get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_menu() -> void:
	get_tree().paused = false
	if ResourceLoader.exists("res://Scenes/main_menu.tscn"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

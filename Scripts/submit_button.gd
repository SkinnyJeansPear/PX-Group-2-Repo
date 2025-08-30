# res://Scripts/submit_button.gd
extends Button
@export var end_panel_path: NodePath = "/root/Main/UILayer/EndPanel" # default assumes siblings under a Canvas/Panel

func _ready() -> void:
	pressed.connect(_on_submit)

func _on_submit() -> void:
	var end_panel = get_node_or_null(end_panel_path)
	if end_panel and end_panel.has_method("open_results"):
		end_panel.open_results()
	else:
		push_warning("EndPanel not found at %s" % str(end_panel_path))

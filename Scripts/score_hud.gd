# res://Scripts/score_hud.gd
extends Label

func _ready() -> void:
	text = "Score: 0"
	if has_node("/root/ScoreManager"):
		var sm: Node = get_node("/root/ScoreManager")
		if sm:
			sm.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score:int) -> void:
	text = "Score: %d" % new_score

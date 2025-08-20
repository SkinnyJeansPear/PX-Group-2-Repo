extends Control

@onready var bin: TextureRect = $TextureRect/Bin
@onready var hidden_pos = position
@onready var shown_pos = position - Vector2(200, 0)  # Slide left by 200 px
@onready var trashed_object: AudioStreamPlayer = $TextureRect/Bin/trashed_object

var tween: Tween

func _ready():
	visible = true
	position = hidden_pos

func show_bar():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", shown_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func hide_bar():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", hidden_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	trashed_object.play()

func is_mouse_over_bin() -> bool:
	return bin.get_global_rect().has_point(get_global_mouse_position())

extends TextureRect

@export var normal_texture: Texture2D
@export var upgraded_texture: Texture2D
@export var threshold: int = 100

var changed := false

func _ready():
	ScoreManager.score_changed.connect(_on_score_changed)
	texture = normal_texture

func _on_score_changed(new_score: int) -> void:
	if not changed and new_score >= threshold:
		texture = upgraded_texture
		changed = true

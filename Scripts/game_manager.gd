extends Node

@onready var ambient_music: AudioStreamPlayer = $ambient_music

func _ready():
	ambient_music.play()

	if has_node("/root/ScoreManager"):
		ScoreManager.reset()
		ScoreManager.required_unsafe_counts = { "garbage": 2 }
		ScoreManager.required_safe_counts = { "lamp": 1, "netted_fence": 1 }
		ScoreManager.min_points_to_count_safe = 1

func _process(_delta):
	if not ambient_music.playing:
		ambient_music.play()
	
var placed_objects: Dictionary = {}

var fence_line_start: Vector2 = Vector2(0, 360)
var fence_line_end: Vector2 = Vector2(1800, 360)
var fence_segment_spacing: int = 128

var current_fence_type: String = ""
var current_fence_nodes: Array = []
var current_fence_script: Node = null

extends Node

@onready var ambient_music: AudioStreamPlayer = $ambient_music

func _ready():
	ambient_music.play()
	
	if has_node("/root/ScoreManager"):
		ScoreManager.required_unsafe_counts = { "garbage": 7}
		ScoreManager.required_safe_counts = { "lamp": 1, "trash_can": 1, "car_barrier": 1, "cctv_left": 1, "drink_fountain": 1, "maintenance_worker": 1, "parking_sign": 1, "table_and_chairs": 1, "crossing_sign": 1, "crossing_lines": 1}
		ScoreManager.min_points_to_count_safe = 1
		ScoreManager.reset()

func _process(_delta):
	if not ambient_music.playing:
		ambient_music.play()
	
var placed_objects: Dictionary = {}

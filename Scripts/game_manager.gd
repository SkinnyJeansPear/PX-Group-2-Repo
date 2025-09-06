extends Node

@onready var ambient_music: AudioStreamPlayer = $ambient_music

func _ready():
	ambient_music.play()

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

var good_zones = [
	Rect2(Vector2(200, 200), Vector2(400, 400)),
	Rect2(Vector2(800, 100), Vector2(300, 300))
]

var bad_zones = [
	Rect2(Vector2(0, 0), Vector2(200, 200))
]

extends Node

@onready var ambient_music: AudioStreamPlayer = $ambient_music

func _ready():
	ambient_music.play()

func _process(_delta):
	if not ambient_music.playing:
		ambient_music.play()

var drag_scales = {
	"lamp": Vector2(1.5, 1.5),
	"trashcan": Vector2(0.8,0.8),
	"fountain": Vector2(1.5,1.5)
}

var placed_objects: Dictionary = {}

var fence_line_start: Vector2 = Vector2(0, 360)
var fence_line_end: Vector2 = Vector2(1800, 360)
var fence_segment_spacing: int = 128

extends Node

var object_positions = {
	"lamp": [
		Vector2(325, 265),
		Vector2(525, 450)
	],
	"trashcan": [
		Vector2(500, 375)
	]
}

var drag_scales = {
	"lamp": Vector2(1.5, 1.5),
	"trashcan": Vector2(0.8,0.8)
}

var placed_objects: Dictionary = {}

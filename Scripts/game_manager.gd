extends Node

var drag_scales = {
	"lamp": Vector2(1.5, 1.5),
	"trashcan": Vector2(0.8, 0.8)
}

var placed_objects: Dictionary = {}  # key: object (TextureRect), value: position (Vector2)

var fence_line_start: Vector2 = Vector2(0, 360)
var fence_line_end: Vector2 = Vector2(1800, 360)
var fence_segment_spacing: int = 128

# Target data
var target_positions = {
	"lamp": [
		Vector2(325, 265),
		Vector2(525, 450)
	]
}
var trash_position = Vector2(1000, 600)
var trash_radius = 100

var score = 0
var score_submitted = false

func submit_score():
	if score_submitted:
		return
	score = evaluate_score()
	score_submitted = true
	show_score()

func evaluate_score() -> int:
	var total_score = 0
	for obj in placed_objects.keys():
		var obj_pos: Vector2 = placed_objects[obj]
		var is_safe = obj.has_meta("is_safe") and obj.get_meta("is_safe")
		var obj_name = obj.name.to_lower()

		if is_safe:
			var targets = target_positions.get(obj_name, [])
			var matched = false
			for target_pos in targets:
				if obj_pos.distance_to(target_pos) < 100:
					total_score += 10
					matched = true
					break
			if not matched:
				total_score += 0  # Safe object in wrong place = 0 points
		else:
			if obj_pos.distance_to(trash_position) < trash_radius:
				total_score += 10  # Unsafe object placed in trash
			else:
				total_score -= 10  # Unsafe object placed elsewhere
	return total_score

func show_score():
	var popup = Popup.new()
	add_child(popup)
	popup.popup_centered()
	popup.set_size(Vector2(300, 150))

	var label = Label.new()
	label.text = "Your Score: %d" % score
	label.set_position(Vector2(50, 50))
	label.set_scale(Vector2(2, 2))
	popup.add_child(label)

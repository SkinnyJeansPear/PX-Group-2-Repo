extends TextureRect

var dragging := false
var offset := Vector2.ZERO
@onready var trash_bar := get_node("/root/Main/TrashBar")

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			offset = get_global_mouse_position() - global_position
			trash_bar.show_bar()
		else:
			dragging = false
			if trash_bar.is_mouse_over_bin():
				queue_free()
			trash_bar.hide_bar()

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() - offset
		if trash_bar.is_mouse_over_bin():
			trash_bar.bin.modulate = Color(1, 0.5, 0.5)
		else:
			trash_bar.bin.modulate = Color(1, 1, 1)

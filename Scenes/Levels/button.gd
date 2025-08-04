extends Button

@onready var grid: TileMapLayer = $"../../Grid"

func _on_toggled(button_pressed):
	if button_pressed == true:
		grid.visible = true
	else:
		grid.visible = false

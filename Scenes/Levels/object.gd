extends TextureRect

var dragging = false
var offset = Vector2.ZERO

@onready var tilemap: TileMapLayer = $"../../../../../Grid"

const TILE_SIZE = 64
const SPRITE_SIZE = 128

func _ready():
	mouse_filter = MOUSE_FILTER_PASS  # So it receives input events
	z_index = 100  

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			offset = get_global_mouse_position() - global_position
		else:
			dragging = false
			global_position = snap_to_tilemap(get_global_mouse_position())

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - offset

func snap_to_tilemap(global_pos: Vector2) -> Vector2:
	if not tilemap:
		printerr("TileMap not found!")
		return global_pos  # fallback to original position

	var local_pos = tilemap.to_local(global_pos)
	var cell = tilemap.local_to_map(local_pos)
	var cell_origin = tilemap.map_to_local(cell)
	var snapped_pos = tilemap.to_global(cell_origin)

	# Offset to center the 128x128 sprite on a 2x2 tile area
	snapped_pos += Vector2(TILE_SIZE, TILE_SIZE) / 2  # center of tile
	snapped_pos -= Vector2(SPRITE_SIZE, SPRITE_SIZE) / 2  # center of sprite

	return snapped_pos

extends TextureRect

const TILE_SIZE = 64
const SPRITE_SIZE = 128

var dragging = false
var drag_sprite: TextureRect = null
var offset = Vector2.ZERO

@onready var drag_layer: Control = get_tree().get_root().get_node("Main/CanvasLayer/DragLayer")
@onready var tilemap: TileMapLayer = get_tree().get_root().get_node("Main/Grid")
@onready var nav_bar: Control = get_tree().get_root().get_node("Main/NavBar")

func _ready():
	mouse_filter = MOUSE_FILTER_PASS

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_drag()
		elif dragging:
			end_drag()

func _process(_delta):
	if dragging and drag_sprite:
		drag_sprite.global_position = get_global_mouse_position() - offset

func start_drag():
	dragging = true
	drag_sprite = duplicate()
	drag_sprite.set_script(null)
	drag_layer.add_child(drag_sprite)

	var sprite_size = drag_sprite.get_size()  # dynamically get size
	offset = sprite_size / 2

	drag_sprite.global_position = get_global_mouse_position() - offset
	drag_sprite.z_index = 1000


func end_drag():
	dragging = false
	if not drag_sprite:
		return

	if is_over_navbar():
		drag_sprite.queue_free()
	else:
		drag_sprite.global_position = snap_to_tilemap(get_global_mouse_position())

	drag_sprite = null

func is_over_navbar() -> bool:
	return nav_bar.get_global_rect().has_point(get_global_mouse_position())

func snap_to_tilemap(global_pos: Vector2) -> Vector2:
	var local_pos = tilemap.to_local(global_pos)
	var cell = tilemap.local_to_map(local_pos)
	var cell_origin = tilemap.map_to_local(cell)
	var snapped_pos = tilemap.to_global(cell_origin)

	snapped_pos += Vector2(TILE_SIZE, TILE_SIZE) / 2
	snapped_pos -= Vector2(SPRITE_SIZE, SPRITE_SIZE) / 2

	return snapped_pos

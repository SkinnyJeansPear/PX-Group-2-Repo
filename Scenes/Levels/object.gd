extends TextureRect

const TILE_SIZE = 64
const SPRITE_SIZE = 128

var dragging = false
var drag_sprite: TextureRect = null
var offset = Vector2.ZERO
var nav_bar_tween = null
@onready var game_manager: Node = $"../../../../../GameManager"


@onready var drag_layer: Control = get_tree().get_root().get_node("Main/CanvasLayer/DragLayer")
@onready var tilemap: TileMapLayer = get_tree().get_root().get_node("Main/Grid")
@onready var nav_bar: Control = get_tree().get_root().get_node("Main/NavBar")

func _ready():
	mouse_filter = MOUSE_FILTER_PASS

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		start_drag()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragging:
			end_drag()

func _process(_delta):
	if dragging and drag_sprite:
		drag_sprite.global_position = get_global_mouse_position() - offset

func slide_nav_bar(hide: bool):
	var start_pos = nav_bar.position
	var end_pos: Vector2

	if hide:
		end_pos = start_pos + Vector2(0, nav_bar.size.y + 120)  # Slide downward
	else:
		end_pos = Vector2(start_pos.x, 0)  # Return to top

	if nav_bar_tween and nav_bar_tween.is_running():
		nav_bar_tween.kill()

	nav_bar_tween = create_tween()
	nav_bar_tween.tween_property(nav_bar, "position", end_pos, 0.4) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	nav_bar.mouse_filter = MOUSE_FILTER_IGNORE if hide else MOUSE_FILTER_STOP

func start_drag():
	dragging = true
	drag_sprite = duplicate()
	drag_sprite.set_script(null)
	drag_layer.add_child(drag_sprite)

	var sprite_size = drag_sprite.get_size()
	offset = sprite_size / 2

	drag_sprite.global_position = get_global_mouse_position() - offset
	drag_sprite.z_index = 1000

	await get_tree().process_frame
	slide_nav_bar(true)

func end_drag():
	dragging = false
	if not drag_sprite:
		return

	var global_pos = get_global_mouse_position()
	var local_pos = tilemap.to_local(global_pos)
	var cell = tilemap.local_to_map(local_pos)
	var cell_key = "%d,%d" % [cell.x, cell.y]

	var game_manager = get_tree().get_root().get_node("Main/GameManager")

	# If dropped over NavBar — cancel
	if is_over_navbar():
		print("❌ Dropped on NavBar — canceled.")
		drag_sprite.queue_free()

	# If cell already has any object — cancel
	elif game_manager.placed_objects.has(cell_key):
		print("❌ Cell already occupied at:", cell_key)
		drag_sprite.queue_free()

	# Valid drop — store it and snap to grid
	else:
		game_manager.placed_objects[cell_key] = drag_sprite
		drag_sprite.global_position = snap_to_tilemap(global_pos)
		print("✅ Object placed at:", cell_key)
	drag_sprite = null
	slide_nav_bar(false)

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

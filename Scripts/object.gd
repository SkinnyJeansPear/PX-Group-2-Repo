extends TextureRect

const TILE_SIZE = 64
const SPRITE_SIZE = 128

var dragging = false
var drag_sprite: TextureRect = null
var offset = Vector2.ZERO
var nav_bar_tween = null

@export var max_count: int = 3
var current_count: int = 0

@export var object_scale: Vector2 = Vector2(1.0, 1.0)
@export var is_safe: bool = true  # <--- Added: define object safety for scoring

@onready var game_manager: Node = $"../../../../../GameManager"
@onready var drag_layer: Control = get_tree().get_root().get_node("Main/CanvasLayer/DragLayer")
@onready var tilemap: TileMapLayer = get_tree().get_root().get_node("Main/Grid")
@onready var nav_bar: Control = get_tree().get_root().get_node("Main/NavBar")

func _ready():
	mouse_filter = MOUSE_FILTER_PASS
	check_availability()

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_count < max_count:
			start_drag()
		else:
			print("No more of this item available!")

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
		end_pos = start_pos + Vector2(0, nav_bar.size.y + 120)
	else:
		end_pos = Vector2(start_pos.x, 0)
	if nav_bar_tween and nav_bar_tween.is_running():
		nav_bar_tween.kill()
	nav_bar_tween = create_tween()
	nav_bar_tween.tween_property(nav_bar, "position", end_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
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
	drag_sprite.scale = object_scale

	# Store safety type in metadata for scoring
	drag_sprite.set_meta("is_safe", is_safe)
	drag_sprite.set_meta("origin_object", self)  # Track source object if needed

	await get_tree().process_frame
	slide_nav_bar(true)

func end_drag():
	var submit_btn = get_tree().get_root().get_node("Main/CanvasLayer/SubmitButton")
	if submit_btn and not submit_btn.visible:
		submit_btn.visible = true

	dragging = false
	if not drag_sprite:
		return

	var global_pos = get_global_mouse_position()

	if is_over_navbar():
		drag_sprite.queue_free()
	else:
		# Save exact position instead of snapped cell
		game_manager.placed_objects[drag_sprite] = drag_sprite.global_position
		drag_sprite.global_position = global_pos - offset
		drag_sprite.scale = object_scale
		current_count += 1
		check_availability()
		print("Placed:", name, "at position:", drag_sprite.global_position)
		
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

func check_availability():
	if current_count >= max_count:
		modulate = Color(1, 1, 1, 0.4)
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		modulate = Color(1, 1, 1, 1)
		mouse_filter = MOUSE_FILTER_PASS

extends TextureRect

const TILE_SIZE = 64
const SPRITE_SIZE = 128

var dragging = false
var drag_sprite: TextureRect = null
var drag_container: Control = null
var offset = Vector2.ZERO
var nav_bar_tween = null

@export var max_count: int = 3
var current_count: int = 0
@export var object_scale: Vector2 = Vector2(1.0, 1.0)
@export var object_info: String = "This is a fence."
@export var object_key: String = "default_fence"
@export var category: String = "safe"
@export_file("*.tscn") var fence_scene_path: String 

@export var good_zones: Array[Rect2] = []
@export var bad_zones: Array[Rect2] = []

@onready var info_box: Control = get_tree().get_root().get_node("Main/InfoBoxLayer/InfoBox")
@onready var info_label: Label = info_box.get_node("Panel/Label")
@onready var game_manager: Node = get_tree().get_root().get_node("Main/GameManager")
@onready var drag_layer: Control = get_tree().get_root().get_node("Main/CanvasLayer/DragLayer")
@onready var tilemap: TileMapLayer = get_tree().get_root().get_node("Main/Grid")
@onready var nav_bar: Control = get_tree().get_root().get_node("Main/NavBarLayer/NavBar")

var NAVBAR_SHOWN_POS = Vector2(0, 0)
var NAVBAR_HIDDEN_POS: Vector2

func _ready():
	mouse_filter = MOUSE_FILTER_PASS
	NAVBAR_HIDDEN_POS = Vector2(0, nav_bar.size.y + 120)
	check_availability()
	self.mouse_entered.connect(Callable(self, "_on_mouse_entered"))
	self.mouse_exited.connect(Callable(self, "_on_mouse_exited"))

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
	if dragging and drag_container:
		drag_container.global_position = get_global_mouse_position()

func slide_nav_bar(hide: bool):
	if nav_bar_tween and nav_bar_tween.is_running():
		nav_bar_tween.kill()
	nav_bar_tween = create_tween()
	var end_pos = NAVBAR_HIDDEN_POS if hide else NAVBAR_SHOWN_POS
	nav_bar_tween.tween_property(nav_bar, "position", end_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	nav_bar.mouse_filter = MOUSE_FILTER_IGNORE if hide else MOUSE_FILTER_STOP

func start_drag():
	dragging = true
	drag_container = Control.new()
	drag_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_layer.add_child(drag_container)
	drag_container.z_index = 1000

	drag_sprite = duplicate()
	drag_sprite.set_script(null)
	drag_container.add_child(drag_sprite)
	drag_sprite.scale = object_scale
	drag_sprite.position = -drag_sprite.get_size() * drag_sprite.scale / 2

	drag_container.global_position = get_global_mouse_position()
	await get_tree().process_frame
	slide_nav_bar(true)

func end_drag():
	dragging = false
	if not drag_sprite or not drag_container:
		slide_nav_bar(false)
		return

	var global_pos = get_global_mouse_position()

	if is_over_navbar():
		drag_container.queue_free()
	else:
		# Fence-specific placement logic
		if is_near_fence_line(global_pos):
			replace_fence_line()
			current_count += 1
			check_availability()
			var object_placed_sound = get_tree().get_root().get_node("Main/NavBarLayer/NavBar/object_placed")
			object_placed_sound.play()
			
	# Determine good/bad/neutral status for scoring
	var center = drag_sprite.global_position + (drag_sprite.size * drag_sprite.scale) / 2
	var status = "neutral"
	for rect in good_zones:
		if rect.has_point(center):
			status = "good"
			break
	if status == "neutral":
		for rect in bad_zones:
			if rect.has_point(center):
				status = "bad"
				break

	ScoreManager.on_object_placed(drag_sprite, object_key, category, center, status)

	drag_container.queue_free()
	drag_sprite = null
	drag_container = null
	slide_nav_bar(false)

func replace_fence_line():
	for n in game_manager.current_fence_nodes:
		if is_instance_valid(n):
			n.queue_free()
	game_manager.current_fence_nodes.clear()

	if game_manager.current_fence_script:
		game_manager.current_fence_script.current_count = max(
			game_manager.current_fence_script.current_count - 1, 0
		)
		game_manager.current_fence_script.check_availability()

	var start = game_manager.fence_line_start
	var end = game_manager.fence_line_end
	var spacing = game_manager.fence_segment_spacing

	var direction = (end - start).normalized()
	var total_length = start.distance_to(end)
	var segment_count = int(total_length / spacing)

	var fence_scene = load(fence_scene_path)
	var placed_fences: Array = []

	for i in range(segment_count + 1):
		var fence_piece = fence_scene.instantiate()
		fence_piece.global_position = start + direction * spacing * i
		fence_piece.z_index = 0
		get_tree().current_scene.add_child(fence_piece)
		placed_fences.append(fence_piece)

	game_manager.current_fence_nodes = placed_fences
	game_manager.current_fence_type = object_key
	game_manager.current_fence_script = self

func is_near_fence_line(pos: Vector2) -> bool:
	var start = game_manager.fence_line_start
	var end = game_manager.fence_line_end
	var line_vec = end - start
	var point_vec = pos - start
	var t = clamp(point_vec.dot(line_vec) / line_vec.length_squared(), 0, 1)
	var projection = start + t * line_vec
	return pos.distance_to(projection) < 150

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

func _on_mouse_entered():
	info_label.text = object_info
	info_box.visible = true
	info_box.global_position = Vector2(5, 790)

func _on_mouse_exited():
	info_box.visible = false

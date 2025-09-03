extends TextureRect

const TILE_SIZE = 64
const SPRITE_SIZE = 128

var dragging = false
var drag_sprite: TextureRect = null
var offset = Vector2.ZERO
var nav_bar_tween = null

@export var max_count: int = 3
var current_count: int = 0

@onready var object_placed_sound: AudioStreamPlayer = get_tree().get_root().get_node("Main/NavBar/object_placed")
@export var object_scale: Vector2 = Vector2(1.0, 1.0)
@onready var game_manager: Node = $"../../../../../GameManager"
@onready var drag_layer: Control = get_tree().get_root().get_node("Main/CanvasLayer/DragLayer")
@onready var tilemap: TileMapLayer = get_tree().get_root().get_node("Main/Grid")
@onready var nav_bar: Control = get_tree().get_root().get_node("Main/NavBar")
@export var object_info: String = "Default info about this object"
@onready var info_box: Control = get_tree().get_root().get_node("Main/InfoBox")
@onready var info_label: Label = info_box.get_node("Panel/Label")

@export var object_key: String = "object"
@export var category: String = "neutral"  # "safe" | "unsafe" | "neutral"


func _ready():
	mouse_filter = MOUSE_FILTER_PASS
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
	drag_sprite.scale = object_scale
	var sprite_size = drag_sprite.get_size() * drag_sprite.scale
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

	if is_over_navbar():
		drag_sprite.queue_free()
	else:
		game_manager.placed_objects[drag_sprite] = drag_sprite.global_position
		drag_sprite.global_position = global_pos - offset
		drag_sprite.scale = object_scale
		current_count += 1
		check_availability()
		
		object_placed_sound.play()
		print("Placed:", name, "at position:", drag_sprite.global_position)
		
	# ...after you position the placed node and before drag_sprite = null
	ScoreManager.on_object_placed(drag_sprite, object_key, category, drag_sprite.global_position)

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

func _on_mouse_entered():
	info_label.text = object_info
	info_box.visible = true
	info_box.global_position = Vector2(0, 790)

func _on_mouse_exited():
	info_box.visible = false

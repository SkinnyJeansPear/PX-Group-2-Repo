extends Node

@export var use_proximity_scoring: bool = true
@export var default_max_distance: float = 128.0

var per_key_max_distance: Dictionary = {}
var safe_targets: Dictionary = {}

var score: int = 0
var placements_seen: Dictionary = {}
var current_fence_points: int = 0

signal score_changed(new_score:int)
signal points_awarded(delta:int, reason:String, at:Vector2, metadata:Dictionary)

func _ready() -> void:
	score = 0
	placements_seen.clear()
	emit_signal("score_changed", score)

func reset() -> void:
	score = 0
	placements_seen.clear()
	emit_signal("score_changed", score)

func set_safe_targets(target_map:Dictionary) -> void:
	safe_targets = target_map.duplicate(true)

func set_per_key_max_distance(map:Dictionary) -> void:
	per_key_max_distance = map.duplicate(true)

func max_distance_for_key(key:String) -> float:
	if key in per_key_max_distance:
		return float(per_key_max_distance[key])
	return default_max_distance

func on_object_placed(node:Node, object_key:String, category:String, world_pos:Vector2, zone_status:String = "neutral") -> int:
	if node:
		var iid: String = str(node.get_instance_id())
		if iid in placements_seen:
			return 0
		placements_seen[iid] = true
	
	var delta: int = 0
	match zone_status:
		"good":
			delta = 10
		"neutral":
			delta = 5
		"bad":
			delta = 0
	
	_add_points(delta, "placed_in_%s_zone" % zone_status, world_pos, {
		"object_key": object_key,
		"category": category,
		"zone_status": zone_status
	})
	
	return delta


func on_object_removed(object_key:String, category:String, world_pos:Vector2 = Vector2.ZERO) -> int:
	var delta: int = 0
	if category == "unsafe":
		delta = 10
	else:
		delta = 0
	
	if delta != 0:
		_add_points(delta, "removed_%s" % category, world_pos, {"object_key": object_key})
	return delta

func _add_points(delta:int, reason:String, at:Vector2, metadata:Dictionary) -> void:
	score += delta
	emit_signal("score_changed", score)
	emit_signal("points_awarded", delta, reason, at, metadata)

func _score_for_safe_placement(object_key:String, pos:Vector2) -> int:
	var targets: Array = []
	if object_key in safe_targets:
		targets = safe_targets[object_key]
	if targets.is_empty():
		return 10
	
	var md: float = max_distance_for_key(object_key)
	var best: float = 9999999.0
	for t in targets:
		if typeof(t) == TYPE_VECTOR2:
			var d: float = pos.distance_to(t)
			if d < best:
				best = d
	
	if best >= md:
		return 0
	
	var ratio: float = clamp(best / md, 0.0, 1.0)
	var pts: int = int(round(lerp(10.0, 0.0, ratio)))
	return pts

func load_targets_from_json(json_path:String) -> void:
	var f = FileAccess.open(json_path, FileAccess.READ)
	if f:
		var text: String = f.get_as_text()
		var parsed: Variant = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			var dict: Dictionary = parsed
			var m: Dictionary = {}
			for k in dict.keys():
				var arr: Array = []
				var pts_array: Array = dict[k]
				for p in pts_array:
					if typeof(p) == TYPE_ARRAY and p.size() == 2:
						arr.append(Vector2(float(p[0]), float(p[1])))
				m[k] = arr
			set_safe_targets(m)
			f.close()
		else:
			push_warning("ScoreManager: JSON at %s did not parse to a Dictionary." % json_path)
	else:
		push_warning("ScoreManager: Can't open %s" % json_path)

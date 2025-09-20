
extends Node
# NOTE: class_name intentionally omitted to avoid Autoload name collisions

## --- Configuration ---
@export var use_proximity_scoring: bool = true
@export var default_max_distance: float = 128.0

# Feedback requirements (configure per level in GameManager)
@export var required_safe_counts: Dictionary = {}
@export var required_unsafe_counts: Dictionary = {}
@export var required_safe_list: Array[String] = []
@export var required_unsafe_list: Array[String] = []

# Minimum points for a safe placement to count as "met"
@export var min_points_to_count_safe: int = 1

## --- Runtime state ---
var per_key_max_distance: Dictionary = {}
var safe_targets: Dictionary = {}

var score: int = 0
var placements_seen: Dictionary = {}
var current_fence_points: int = 0

# Progress tracking for dynamic feedback
var placed_safe_counts: Dictionary = {}
var removed_unsafe_counts: Dictionary = {}

signal score_changed(new_score:int)
signal points_awarded(delta:int, reason:String, at:Vector2, metadata:Dictionary)

func _ready() -> void:
    _reset_progress_only()
    emit_signal("score_changed", score)

func reset() -> void:
    score = 0
    current_fence_points = 0
    _reset_progress_only()
    emit_signal("score_changed", score)

func _reset_progress_only() -> void:
    placements_seen.clear()
    placed_safe_counts.clear()
    removed_unsafe_counts.clear()

    # Merge list requirements (+1 each) into counts
    var safe_counts: Dictionary = {}
    for k in required_safe_list:
        var key_s: String = str(k)
        safe_counts[key_s] = int(safe_counts.get(key_s, 0)) + 1
    for k in required_safe_counts.keys():
        var kk: String = str(k)
        safe_counts[kk] = int(safe_counts.get(kk, 0)) + int(required_safe_counts[kk])
    required_safe_counts = safe_counts

    var unsafe_counts: Dictionary = {}
    for k in required_unsafe_list:
        var key_u: String = str(k)
        unsafe_counts[key_u] = int(unsafe_counts.get(key_u, 0)) + 1
    for k in required_unsafe_counts.keys():
        var ku: String = str(k)
        unsafe_counts[ku] = int(unsafe_counts.get(ku, 0)) + int(required_unsafe_counts[ku])
    required_unsafe_counts = unsafe_counts

## --- Targets / distances ---
func set_safe_targets(target_map:Dictionary) -> void:
    safe_targets = target_map.duplicate(true)

func set_per_key_max_distance(map:Dictionary) -> void:
    per_key_max_distance = map.duplicate(true)

func max_distance_for_key(key:String) -> float:
    if per_key_max_distance.has(key):
        return float(per_key_max_distance[key])
    return default_max_distance

## --- Scoring entry points ---
# Call when an object is placed into the world
func on_object_placed(node:Node, object_key:String, category:String, world_pos:Vector2) -> int:
    if node != null:
        var iid: String = str(node.get_instance_id())
        if placements_seen.has(iid):
            return 0
        placements_seen[iid] = true

    var delta: int = 0
    match category:
        "safe":
            if use_proximity_scoring:
                delta = _score_for_safe_placement(object_key, world_pos)
            else:
                delta = 10
            if delta >= min_points_to_count_safe:
                _inc(placed_safe_counts, object_key, 1)
        "unsafe", "neutral":
            delta = 0
        _:
            delta = 0

    if delta != 0:
        _add_points(delta, "placed_%s" % category, world_pos, {"object_key": object_key})
    return delta

# Call when an object is removed (e.g., dumped into a bin)
func on_object_removed(object_key:String, category:String, world_pos:Vector2 = Vector2.ZERO) -> int:
    var delta: int = 0
    if category == "unsafe":
        delta = 10
        _inc(removed_unsafe_counts, object_key, 1)
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
    var targets:Array = []
    if safe_targets.has(object_key):
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
    var f := FileAccess.open(json_path, FileAccess.READ)
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
                m[str(k)] = arr
            set_safe_targets(m)
            f.close()
        else:
            push_warning("ScoreManager: JSON at %s did not parse to a Dictionary." % json_path)
    else:
        push_warning("ScoreManager: Can't open %s" % json_path)

## --- Feedback helpers ---
func _inc(d:Dictionary, key:String, add:int) -> void:
    var kk: String = str(key)
    d[kk] = int(d.get(kk, 0)) + add

func any_required_unsafe_left() -> bool:
    for k in required_unsafe_counts.keys():
        var need: int = int(required_unsafe_counts[k])
        var have: int = int(removed_unsafe_counts.get(k, 0))
        if have < need:
            return true
    return false

func any_required_safe_missed() -> bool:
    for k in required_safe_counts.keys():
        var need: int = int(required_safe_counts[k])
        var have: int = int(placed_safe_counts.get(k, 0))
        if have < need:
            return true
    return false

func missing_required_unsafe() -> Array[String]:
    var out: Array[String] = []
    for k in required_unsafe_counts.keys():
        var need: int = int(required_unsafe_counts[k])
        var have: int = int(removed_unsafe_counts.get(k, 0))
        var missing: int = max(0, need - have)
        if missing > 0:
            for i in range(missing):
                out.append(str(k))
    return out

func missing_required_safe() -> Array[String]:
    var out: Array[String] = []
    for k in required_safe_counts.keys():
        var need: int = int(required_safe_counts[k])
        var have: int = int(placed_safe_counts.get(k, 0))
        var missing: int = max(0, need - have)
        if missing > 0:
            for i in range(missing):
                out.append(str(k))
    return out

# Optional: debug
func debug_print_progress() -> void:
    print("REQ safe:", required_safe_counts, " PLACED:", placed_safe_counts)
    print("REQ unsafe:", required_unsafe_counts, " REMOVED:", removed_unsafe_counts)

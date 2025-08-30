# res://Scripts/level_init_score_reset.gd
extends Node

## Attach this to the ROOT node of each gameplay scene (e.g., Tutorial, ParkingLot).
## It resets the ScoreManager whenever the level loads, so previous runs don't leak.

func _ready() -> void:
	if has_node("/root/ScoreManager"):
		get_node("/root/ScoreManager").reset()
	else:
		push_warning("ScoreManager not found on level start; is the Autoload enabled?")

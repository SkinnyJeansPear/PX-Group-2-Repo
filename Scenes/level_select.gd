extends Label

func _ready():
	# Start invisible
	modulate.a = 0.0
	
	# Create a tween for fade-in
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.5) # fade in over Xs

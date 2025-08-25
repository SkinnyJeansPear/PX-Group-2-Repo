extends Button

@onready var game_manager = get_tree().get_root().get_node("Main/GameManager")

func _ready():
	self.text = "Submit"
	self.visible = false  # Initially hidden until at least one object is placed

func _on_SubmitButton_pressed():
	if game_manager and not game_manager.score_submitted:
		game_manager.submit_score()
		self.disabled = true
		self.text = "Submitted"

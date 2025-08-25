extends PopupPanel

@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)
	hide()

func show_score(score: int):
	label.text = "Your Score: %d" % score
	popup_centered()

func _on_close_button_pressed():
	hide()

extends HBoxContainer


@export var separator_text: String = "Separator"
@export var label_horizontal_margin: int = 5

@onready var label: Label = $MarginContainer/Label
@onready var margin_container = $MarginContainer



# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = separator_text
	margin_container.add_theme_constant_override("margin_left", label_horizontal_margin)
	margin_container.add_theme_constant_override("margin_right", label_horizontal_margin)

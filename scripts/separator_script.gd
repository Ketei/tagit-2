extends HBoxContainer


@export var separator_text: String = "Separator"
@export var label_horizontal_margin: int = 5
@export var is_title: bool = false

@onready var label: Label = $MarginContainer/Label
@onready var margin_container = $MarginContainer

@onready var left_container: VBoxContainer = $LeftContainer
@onready var right_container: VBoxContainer = $RightContainer



# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = separator_text
	margin_container.add_theme_constant_override("margin_left", label_horizontal_margin)
	margin_container.add_theme_constant_override("margin_right", label_horizontal_margin)
	if is_title:
		label.add_theme_font_size_override("font_size", 20)
		right_container.add_child(HSeparator.new())
		left_container.add_child(HSeparator.new())
	
	

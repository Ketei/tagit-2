class_name AngleViewContainer
extends PanelContainer

@export var texture: Texture2D

@onready var check_button: CheckBox = $VisualContainer/CheckButton
@onready var toggle_button: Button = $ToggleButton
@onready var texture_rect: TextureRect = $VisualContainer/TextureRect


func _ready():
	toggle_button.pressed.connect(on_button_pressed)
	if texture != null:
		texture_rect.texture = texture


func on_button_pressed() -> void:
	check_button.button_pressed = not check_button.button_pressed


func is_checked() -> bool:
	return check_button.button_pressed





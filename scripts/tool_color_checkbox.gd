class_name ColorCheckBox
extends CheckBox


@export var color_name: String = ""


func _ready():
	text = DumbUtils.capitalize(color_name)


func get_color() -> String:
	return color_name


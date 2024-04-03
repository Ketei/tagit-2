class_name WizardCheckBoxTag
extends CheckBox

@export var display_name: String = ""
@export var tag_name: String = ""


func _ready():
	text = display_name


func get_tag() -> String:
	return tag_name

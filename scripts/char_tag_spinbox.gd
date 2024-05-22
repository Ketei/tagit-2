class_name CharSpinBox
extends SpinBox


@export var element: String = ""
@export var exclude: Array[int] = []
@export var overwrite: Dictionary = {}


func get_tag() -> String:
	if exclude.has(int(value)):
		return ""
	
	if overwrite.has(int(value)):
		return overwrite[int(value)]
	
	var construct_string: String = ""
	
	construct_string += str(int(value))
	
	if value == 1:
		construct_string += element
	else:
		construct_string += DumbUtils.pluralize_word(element)
	
	return construct_string


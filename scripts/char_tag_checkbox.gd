class_name TagCheckBoxCharacter
extends CheckBox


@export var title: String = ""
@export var contains: Array[String] = []
@export var conditional_nodes: Array[Control] = []

var default := false


func _ready():
	text = DumbUtils.title_case(title)
	if not conditional_nodes.is_empty():
		toggled.connect(on_toggled)
		for node in conditional_nodes:
			node.visible = button_pressed
	default = button_pressed


func on_toggled(is_toggled: bool) -> void:
	for node in conditional_nodes:
		node.visible = is_toggled


func get_tags() -> Array[String]:
	var return_array: Array[String] = []
	for element in contains:
		if not element.is_empty():
			return_array.append(element)
	
	return return_array



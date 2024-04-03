class_name BodyPropsContianer
extends VBoxContainer


var color_containers: Array[ColorTypeContainer] = []


func _ready():
	iterate_children(self)


func iterate_children(parent_node: Node) -> void:
	for child in parent_node.get_children():
		if child is ColorTypeContainer:
			color_containers.append(child)
		else:
			iterate_children(child)


func get_tags() -> Array[String]:
	var return_array: Array[String] = []
	for color_type in color_containers:
		if color_type.is_pressed():
			return_array.append_array(color_type.get_tags())
	return return_array


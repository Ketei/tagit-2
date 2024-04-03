class_name WizardContainer
extends VBoxContainer


var checkboxes: Array[WizardCheckBoxTag] = []



func _ready():
	iterate_nodes(self)


func deselect_all() -> void:
	for check in checkboxes:
		check.button_pressed = false


func iterate_nodes(parent: Node) -> void:
	for child in parent.get_children():
		if child is WizardCheckBoxTag:
			checkboxes.append(child)
		else:
			iterate_nodes(child)


func get_tags() -> Array[String]:
	var tag_array: Array[String] = []
	
	for check in checkboxes:
		if check.button_pressed and not check.disabled:
			tag_array.append(check.get_tag())
	
	return tag_array












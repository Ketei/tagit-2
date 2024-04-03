class_name PoseContainer
extends VBoxContainer

var poses_nodes: Array[PoseCheckBox] = []


func _ready():
	iterate_children(self)


func iterate_children(container) -> void:
	for child in container.get_children():
		if child is PoseCheckBox:
			poses_nodes.append(child)
		else:
			iterate_children(child)


func get_tags() -> Array[String]:
	var return_array: Array[String] = []
	
	for pose in poses_nodes:
		if not pose.disabled and pose.button_pressed:
			return_array.append(pose.pose_tag)
	
	return return_array




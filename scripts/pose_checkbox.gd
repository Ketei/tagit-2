class_name PoseCheckBox
extends CheckBox

@export var pose_name: String = ""
@export var pose_tag: String = ""
@export var group_container: Array[Node] = []

var child_poses: Array[PoseCheckBox] = []


func _ready():
	text = pose_name
	if not group_container.is_empty():
		toggled.connect(on_group_toggled)
		for group in group_container:
			for child in group.get_children():
				if child is PoseCheckBox:
					child_poses.append(child)


func on_group_toggled(is_toggled: bool) -> void:
	for pose in child_poses:
		pose.disabled = not is_toggled


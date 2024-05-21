class_name TagCheckBoxCharacter
extends CheckBox


@export var title: String = ""
@export var contains: Array[String] = []
@export var conditional_nodes: Array[Control] = []

func _ready():
	text = DumbUtils.title_case(title)
	if not conditional_nodes.is_empty():
		toggled.connect(on_toggled)
		for node in conditional_nodes:
			node.visible = button_pressed


func on_toggled(is_toggled: bool) -> void:
	for node in conditional_nodes:
		node.visible = is_toggled


func get_tags() -> Array[String]:
	return contains



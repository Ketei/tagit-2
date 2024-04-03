class_name ColorTypeContainer
extends HBoxContainer

@export var type_title: String = ""
# Example
#var type_data: Array[Dictionary] = [{"name": "1 Color", "tags": ["monotone fur"]}]
@export var type_data: Array[Dictionary] = [
	{"name": "1 Color", "tags": ["monotone fur"]},
	{"name": "2 Colors", "tags": ["multicolored fur", "two tone fur"]},
	{"name": "3+ Colors", "tags": ["multicolored fur", "multi tone fur"]}
	]

@onready var type_box: CheckBox = $TypeBox
@onready var type_count_opt_btn: OptionButton = $TypeCountOptBtn


# Called when the node enters the scene tree for the first time.
func _ready():
	type_box.text = type_title
	var item_index: int = 0
	
	for item in type_data:
		type_count_opt_btn.add_item(item["name"])
		type_count_opt_btn.set_item_metadata(
			item_index,
			item["tags"]
		)
		item_index += 1
	type_box.toggled.connect(on_press_changed)


func on_press_changed(is_toggled: bool) -> void:
	type_count_opt_btn.disabled = not is_toggled


func is_pressed() -> bool:
	return type_box.button_pressed


func get_tags() -> Array:
	return type_count_opt_btn.get_item_metadata(type_count_opt_btn.selected)


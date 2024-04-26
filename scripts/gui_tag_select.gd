class_name TagMapBrowser
extends Control


signal tag_selected(tag_string: String)

var max_height: int = 400

@onready var type_option_button: OptionButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TagTypeContainer/TypeOptionButton
@onready var category_option_button: OptionButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CategoryContainer/CategoryOptionButton
@onready var tags_option_button: OptionButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TagsContainer/TagsOptionButton

@onready var type_info: TextEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TagTypeContainer/TypeInfo
@onready var category_info: TextEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CategoryContainer/CategoryInfo
@onready var tag_info: TextEdit =$CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TagsContainer/TagInfo

@onready var cancel_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonContainer/CancelButton
@onready var add_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ButtonContainer/AddButton


# Called when the node enters the scene tree for the first time.
func _ready():
	Tagger.shortcuts_disabled = true
	var type_index: int = 0
	type_option_button.get_popup().max_size.y = max_height
	category_option_button.get_popup().max_size.y = max_height
	tags_option_button.get_popup().max_size.y = max_height
	
	for type in Tagger.tag_map:
		type_option_button.add_item(Tagger.tag_map[type]["name"])
		type_option_button.set_item_metadata(
				type_index,
				type)
		type_index += 1
	
	if 0 < type_option_button.item_count:
		type_option_button.select(0)
		on_type_selected(0)
	type_option_button.item_selected.connect(on_type_selected)
	category_option_button.item_selected.connect(on_category_selected)
	tags_option_button.item_selected.connect(on_tag_selected)
	cancel_button.pressed.connect(on_cancel_pressed)
	add_button.pressed.connect(get_tag)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		on_cancel_pressed()


func on_type_selected(type_index: int) -> void:
	category_option_button.clear()
	var type_key: String = type_option_button.get_item_metadata(type_index)
	var category_index: int = 0
	
	type_info.text = Tagger.tag_map[type_key]["desc"]
	
	for category in Tagger.tag_map[type_key]["categories"]:
		category_option_button.add_item(
				Tagger.tag_map[type_key]["categories"][category]["name"])
		category_option_button.set_item_metadata(
				category_index,
				category)
		category_index += 1
	
	if 0 < category_option_button.item_count:
		category_option_button.select(0)
		on_category_selected(0)
	

func on_category_selected(category_index: int) -> void:
	tags_option_button.clear()
	var type_key: String = type_option_button.get_item_metadata(type_option_button.selected)
	var category_key: String = category_option_button.get_item_metadata(category_index)
	
	category_info.text = Tagger.tag_map[type_key]["categories"][category_key]["desc"]
	
	var tag_index: int = 0
	for tag in Tagger.tag_map[type_key]["categories"][category_key]["tags"]:
		tags_option_button.add_item(
				Tagger.tag_map[type_key]["categories"][category_key]["tags"][tag]["name"]
		)
		tags_option_button.set_item_metadata(
				tag_index,
				tag)
		tag_index += 1
	
	if 0 < tags_option_button.item_count:
		tags_option_button.select(0)
		on_tag_selected(0)


func on_tag_selected(tag_index: int) -> void:
	var type_key: String = type_option_button.get_item_metadata(type_option_button.selected)
	var category_key: String = category_option_button.get_item_metadata(category_option_button.selected)
	var tag_key: String = tags_option_button.get_item_metadata(tag_index)
	
	tag_info.text = Tagger.tag_map[type_key]["categories"][category_key]["tags"][tag_key]["desc"]


func get_tag() -> void:
	if type_option_button.selected == -1 or\
	category_option_button.selected == -1 or\
	tags_option_button.selected == -1:
		return
	
	var type_key: String = type_option_button.get_item_metadata(type_option_button.selected)
	var category_key: String = category_option_button.get_item_metadata(category_option_button.selected)
	var tag_key: String = tags_option_button.get_item_metadata(tags_option_button.selected)
	
	tag_selected.emit(Tagger.tag_map[type_key]["categories"][category_key]["tags"][tag_key]["tag"])


func on_cancel_pressed() -> void:
	Tagger.shortcuts_disabled = false
	queue_free()


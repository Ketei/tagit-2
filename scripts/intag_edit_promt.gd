class_name InTagEditor
extends Control


signal add_suggestions(suggestions: Array[String])
signal go_to_fetch(args: Dictionary)

signal list_changed

var tag_index: int = 0

var original_prio: int = 0
var original_cat :=  Tagger.Categories.GENERAL
var original_alt: int = 0

var tag_tree: TreeItem = null


@onready var tag_name_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagNameLabel

@onready var priority_spin_box: SpinBox = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/SmallData/PrioContainer/PrioritySpinBox

@onready var category_option_button: CategoryOptionButton = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/CatContaienr/CategoryOptionButton

@onready var suggestions_item_list: ItemList = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/SuggestionContainer/SuggestionsItemList

@onready var done_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/ButtonsContainer/DoneButton
@onready var add_selected_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/SuggestionContainer/AddSelectedButton
@onready var fetch_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/VBoxContainer/FetchButton
@onready var reset_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/VBoxContainer/ResetButton

@onready var alt_options: OptionButton = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/SmallData/VBoxContainer/AltOptions


func _ready():
	visible = false	
	done_button.pressed.connect(on_close_pressed)
	add_selected_button.pressed.connect(on_add_sugg_pressed)
	fetch_button.pressed.connect(on_fetch_pressed)
	reset_button.pressed.connect(on_reset_pressed)


func _unhandled_key_input(event):
	if event.is_action("ui_cancel"):
		on_close_pressed()
		get_viewport().set_input_as_handled()


func on_fetch_pressed() -> void:
	go_to_fetch.emit(tag_name_label.text)
	Tagger.shortcuts_disabled = false
	queue_free()


func on_add_sugg_pressed() -> void:
	var suggs_array: Array[String] = []
	
	for item_index in suggestions_item_list.get_selected_items():
		suggs_array.append(
				suggestions_item_list.get_item_text(item_index))
	
	if not suggs_array.is_empty():
		add_suggestions.emit(suggs_array)


func set_data_and_show(target_tree: TreeItem) -> void:
	var tag_exists: bool = Tagger.has_tag(target_tree.get_text(0))
	var tag_data: Dictionary = target_tree.get_metadata(0)
	
	tag_tree = target_tree
	tag_name_label.text = target_tree.get_text(0)
	priority_spin_box.value = tag_data["priority"]
	category_option_button.select_category(tag_data["category"])
	
	original_prio = int(tag_data["priority"])
	original_cat = tag_data["category"]
	original_alt = tag_data["alt_state"]
	
	alt_options.select(original_alt)
	
	for item in tag_data["suggestions"]:
		suggestions_item_list.add_item(item)
		
	fetch_button.visible = not tag_exists
	reset_button.visible = tag_exists
	
	Tagger.shortcuts_disabled = true
	visible = true


func on_close_pressed() -> void:
	var new_category: Tagger.Categories = category_option_button.get_category()
	var new_priority: int = int(priority_spin_box.value)
	var new_alt: int = alt_options.selected
	var tag_data: Dictionary = tag_tree.get_metadata(0)
	
	tag_data["category"] = new_category
	tag_data["priority"] = new_priority
	tag_data["alt_state"] = new_alt
	
	if new_alt != original_alt:
		var button_idx: int = tag_tree.get_button_by_id(0, TagTreeList.ALT_LIST_ID)
		tag_tree.set_button(0, button_idx, TagTreeList.get_list_texture(tag_data["alt_state"]))
		tag_tree.set_button_tooltip_text(0, button_idx, TagTreeList.get_list_tooltip(tag_data["alt_state"]))
	
	if new_category != original_cat or new_priority != original_prio or new_alt != original_alt:
		tag_tree.set_button_disabled(
				0,
				tag_tree.get_button_by_id(0,TagTreeList.RESET_DATA_ID),
				false)
		list_changed.emit()
	
	Tagger.shortcuts_disabled = false
	queue_free()


func on_reset_pressed() -> void:
	if not Tagger.has_tag(tag_name_label.text):
		category_option_button.select_category(Tagger.Categories.GENERAL)
		priority_spin_box.value = 0
	else:
		var tag_data: Tag = Tagger.get_tag(tag_name_label.text)
		category_option_button.select_category(tag_data.category)
		priority_spin_box.value = tag_data.tag_priority
		suggestions_item_list.clear()
		for item in tag_data.suggestions:
			suggestions_item_list.add_item(item)
	alt_options.select(0)

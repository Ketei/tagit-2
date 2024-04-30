class_name InTagEditor
extends Control


signal done_editing(tag_index: int, tag_data: Dictionary)
signal add_suggestions(suggestions: Array[String])
signal go_to_fetch(args: Dictionary)

var tag_index: int = 0

var original_prio: int = 0
var original_cat :=  Tagger.Categories.GENERAL


@onready var tag_name_label: Label = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagNameLabel
@onready var priority_spin_box: SpinBox = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/PrioContainer/PrioritySpinBox
@onready var category_option_button: CategoryOptionButton = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/CatContaienr/CategoryOptionButton
@onready var done_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/ButtonsContainer/DoneButton
@onready var suggestions_item_list: ItemList = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/SuggestionContainer/SuggestionsItemList
@onready var add_selected_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/SuggestionContainer/AddSelectedButton
@onready var fetch_button: Button = $CenterContainer/PanelContainer/MarginContainer/HBoxContainer/DataContainer/TagDataContainer/FetchButton


func _ready():
	visible = false
	done_button.pressed.connect(on_close_pressed)
	add_selected_button.pressed.connect(on_add_sugg_pressed)
	fetch_button.pressed.connect(on_fetch_pressed)


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


func set_data_and_show(item_index: int, tag_name: String, tag_data: Dictionary) -> void:
	tag_name_label.text = tag_name
	tag_index = item_index
	priority_spin_box.value = tag_data["priority"]
	original_prio = int(tag_data["priority"])
	category_option_button.select_category(tag_data["category"])
	original_cat = tag_data["category"]
	for item in tag_data["suggestions"]:
		suggestions_item_list.add_item(item)
	fetch_button.visible = not Tagger.has_tag(tag_name)
	Tagger.shortcuts_disabled = true
	visible = true


func update_data(new_cat: Tagger.Categories, new_prio: int) -> void:
	done_editing.emit(
			tag_index, 
			{
				"category": new_cat,
				"priority": new_prio
			})


func on_close_pressed() -> void:
	var new_category: Tagger.Categories = category_option_button.get_category()
	var new_priority: int = int(priority_spin_box.value)
	
	if new_category != original_cat or new_priority != original_prio:
		update_data(new_category, new_priority)
	Tagger.shortcuts_disabled = false
	queue_free()


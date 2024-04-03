class_name SmartTagEntry
extends Control


var suggestion_title: String = ""

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TitleLabel

@onready var smart_suggestion_item_list: TagItemList  = $PanelContainer/MarginContainer/VBoxContainer/SmartSuggestionItemList

@onready var suggestions_line_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/DataEntry/SuggestionLineEdit
#@onready var title_line_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TitleLineEdit

@onready var add_data_button: Button = $PanelContainer/MarginContainer/VBoxContainer/DataEntry/AddDataButton
@onready var sort_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SortButton


func _ready():
	title_label.text = suggestion_title
	title_label.tooltip_text = suggestion_title
	#title_line_edit.text = suggestion_title
	#title_line_edit.placeholder_text = suggestion_title
	add_data_button.pressed.connect(on_add_pressed)
	suggestions_line_edit.text_submitted.connect(on_data_submitted)
	smart_suggestion_item_list.list_emptied.connect(on_entries_emptied)
	sort_button.pressed.connect(
			smart_suggestion_item_list.sort_items_by_text)


func grab_line_focus() -> void:
	suggestions_line_edit.grab_focus()


func on_add_pressed() -> void:
	on_data_submitted(suggestions_line_edit.text)


func on_data_submitted(submitted_text: String) -> void:
	var entry_to_add: String = submitted_text.strip_edges().to_lower()
	if entry_to_add.is_empty():
		return
	suggestions_line_edit.clear()
	add_entry(entry_to_add)
	await get_tree().process_frame
	var scrollbar := smart_suggestion_item_list.get_v_scroll_bar()
	scrollbar.value = scrollbar.max_value


func add_entry(suggestion_text: String) -> void:
	if smart_suggestion_item_list.has_item(suggestion_text):
		return
	smart_suggestion_item_list.add_item(suggestion_text)


func on_entries_emptied() -> void:
	queue_free()


func get_all_entries() -> Array[String]:
	var return_array: Array[String] = []
	
	for item in range(smart_suggestion_item_list.item_count):
		return_array.append(smart_suggestion_item_list.get_item_text(item))
	
	return return_array


func get_data() -> Dictionary:
	#var new_title: String = title_line_edit.text.strip_edges()
	#
	#if not new_title.is_empty():
		#suggestion_title = new_title
	
	return {
		"title": suggestion_title,
		"data": {
			"type": "opt",
			"tags": get_all_entries()
		}
	}




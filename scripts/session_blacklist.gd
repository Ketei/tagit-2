class_name SessionBlacklist
extends Control

@onready var temp_group_list: TagItemList = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/GroupsBlackContainer/TempGroupList
@onready var temp_item_list: TagItemList = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SuggestionBlackContainer/TempItemList

@onready var temp_blacklist_line_edit: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SuggestionBlackContainer/HBoxContainer/TempBlacklistLineEdit

@onready var add_temp_blacklist_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SuggestionBlackContainer/HBoxContainer/AddTempBlacklistButton
@onready var done_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DoneButton


func _ready():
	done_button.pressed.connect(on_done_pressed)
	set_process_unhandled_key_input(false)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		on_done_pressed()


func on_done_pressed() -> void:
	visible = false
	Tagger.enable_shortcuts()
	set_process_unhandled_key_input(false)


func has_item(item_string: String) -> bool:
	return temp_item_list.has_item(item_string)


func has_group(group_title: String) -> bool:
	return temp_group_list.has_item(group_title)


func clear_blacklist() -> void:
	temp_item_list.clear()
	temp_group_list.clear()


func add_to_blacklist(tag_to_blacklist: String) -> void:
	if not temp_item_list.has_item(tag_to_blacklist):
		temp_item_list.add_item(tag_to_blacklist)


func add_to_group_blacklist(group_to_blacklist: String) -> void:
	if not temp_group_list.has_item(group_to_blacklist):
		temp_group_list.add_item(group_to_blacklist)


func get_blacklist_array() -> Array[String]:
	return temp_item_list.get_tag_array()


func show_blacklist() -> void:
	set_process_unhandled_key_input(true)
	Tagger.disable_shortcuts()
	visible = true

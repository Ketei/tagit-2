class_name TagFullSearch
extends Control


signal add_selected_pressed(selected_tags: Array[String])

@onready var search_item_list: ItemList = $CenterContainer/MarginContainer/VBoxContainer/SearchItemList
@onready var tag_line: LineEdit = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var search_tag: Button = $CenterContainer/MarginContainer/VBoxContainer/HBoxContainer/SearchTag
@onready var add_selected: Button = $CenterContainer/MarginContainer/VBoxContainer/ButtonsContainer/AddSelected
@onready var close_button: Button = $CenterContainer/MarginContainer/VBoxContainer/ButtonsContainer/CloseButton

@onready var api_cooldown: Timer = $APICooldown


func _ready():
	search_tag.pressed.connect(on_search_submitted)
	tag_line.text_submitted.connect(on_search_submitted)
	add_selected.pressed.connect(on_add_selected)
	close_button.pressed.connect(on_close_pressed)
	set_process_unhandled_key_input(false)


func show_searcher() -> void:
	set_process_unhandled_key_input(true)
	Tagger.shortcuts_disabled = true
	visible = true


func on_search_submitted(_ignored: String = "") -> void:
	search_item_list.clear()
	tag_line.editable = false
	search_tag.disabled = true
	
	var local_array: Array[String] = []
	var e_six_array: Array[String] = []
	
	var tag_to_search: String = tag_line.text.strip_edges().to_lower()
	
	var local_search: Array = Tagger.search_local(tag_to_search, -1, false)
	
	for item in local_search:
		if item is String:
			local_array.append(item)
		else:
			local_array.append(item[1])
	
	ESixRequester.request_prio(
		Tagger.get_tag_request_url(tag_to_search, Tagger.E621_CATEGORY.ALL, "count", 100)
	)
	
	var result_array = await ESixRequester.prio_get
	api_cooldown.start()
	
	# No 1 nor 6
	for item_dict in result_array:
		if item_dict["category"] == 1 or item_dict["category"] == 6:
			continue
		var tag_entry: String = item_dict["name"].replace("_", " ")
		
		if not local_array.has(tag_entry):
			e_six_array.append(tag_entry)
	
	var final_array: Array[String] = []
	
	final_array.append_array(local_array)
	final_array.append_array(e_six_array)
	
	for tag in final_array:
		search_item_list.add_item(tag)
	
	if api_cooldown.is_stopped():
		search_tag.disabled = false
		tag_line.editable = true
	else:
		await api_cooldown.timeout
		search_tag.disabled = false
		tag_line.editable = true


func on_add_selected() -> void:
	if not search_item_list.is_anything_selected():
		return
	var selected_tags: Array[String] = []
	for index in search_item_list.get_selected_items():
		selected_tags.append(
				search_item_list.get_item_text(index))
		search_item_list.set_item_custom_bg_color(
				index,
				Color(0.09, 0.243, 0.106))
	add_selected_pressed.emit(selected_tags)


func on_close_pressed() -> void:
	hide()
	set_process_unhandled_key_input(false)
	Tagger.shortcuts_disabled = false


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		on_close_pressed()


func grab_search_focus() -> void:
	tag_line.grab_focus()



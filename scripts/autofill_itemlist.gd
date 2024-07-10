class_name AutoFillList
extends ItemList


signal item_submited(item_text: String)
signal item_tabbed(item_text: String)
signal text_continued
signal cancel_pressed


func _ready():
	item_clicked.connect(on_item_clicked)
	item_activated.connect(on_item_activated)
	focus_neighbor_bottom = "."
	focus_neighbor_left = "."
	focus_neighbor_right = "."
	focus_neighbor_top = "."
	focus_next = "."
	focus_previous = "."


func _gui_input(event):
	if has_focus():
		if event.is_action("ui_focus_next") and is_anything_selected():
			item_tabbed.emit(get_item_text(get_selected_items()[0]))
			accept_event()
		elif event.is_action("ui_cancel"):
			cancel_pressed.emit()
			accept_event()
		elif DumbUtils.is_letter(event.as_text()):
			text_continued.emit()
			


func on_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		#item_submited.emit(get_item_text(index))
		item_submited.emit(get_tag_text(index))


func on_item_activated(item_index: int) -> void:
	item_submited.emit(get_tag_text(item_index))


func add_tag_item(tag: String, display: String = "") -> void:
	var add_index: int = add_item(
			tag if display.is_empty() else display
			)
	set_item_metadata(add_index, tag)


func get_tag_text(item_index: int) -> String:
	var metadata = get_item_metadata(item_index)
	if metadata != null and typeof(metadata) == TYPE_STRING:
		return metadata
	else:
		return get_item_text(item_index)


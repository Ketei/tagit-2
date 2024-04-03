extends TagItemList

signal last_alias_deleted
signal alias_deleted(alias_name, is_custom)


func _gui_input(_event):
	if has_focus() and Input.is_action_just_pressed("ui_text_delete") and is_anything_selected():
		var selected_items: PackedInt32Array = get_selected_items()
		selected_items.reverse()
		
		for index in selected_items:
			alias_deleted.emit(get_item_text(index), get_item_metadata(index))
			remove_item(index)
		if item_count == 0:
			list_emptied.emit()
		deselect_all()


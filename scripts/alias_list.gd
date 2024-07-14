class_name AliasItemList
extends TagItemList

#signal last_alias_deleted
signal alias_deleted(alias_name, is_custom, is_remove, index)


func _gui_input(_event):
	if has_focus() and Input.is_action_just_pressed("ui_text_delete") and is_anything_selected():
		var selected_items: PackedInt32Array = get_selected_items()
		
		selected_items.reverse()
		
		for index in selected_items:
			var item_metadata: Dictionary = get_item_metadata(index)
			alias_deleted.emit(get_item_text(index), item_metadata["custom"], item_metadata["remove"], index)
			#remove_item(index)
		if item_count == 0:
			list_emptied.emit()
		deselect_all()


func set_item_normal(item_index: int) -> void:
	set_item_icon(
			item_index,
			null)
	set_item_metadata(
			item_index,
			{"custom": false, "remove": false})


func reset_item_icon(item_index: int) -> void:
	set_item_icon(
			item_index,
			null)


func set_item_removed(item_index: int, is_removed: bool = true) -> void:
	if is_removed:
		set_item_icon(
				item_index,
				load("res://textures/status/bad.png"))
	
	get_item_metadata(item_index)["remove"] = is_removed


func set_item_custom(item_index: int, is_custom: bool = true) -> void:
	if is_custom:
		set_item_icon(
				item_index,
				load("res://textures/status/loaded.png")
		)
	
	get_item_metadata(item_index)["custom"] = is_custom


func is_item_custom(item_index: int) -> bool:
	if typeof(get_item_metadata(item_index)) != TYPE_DICTIONARY or\
			not get_item_metadata(item_index).has("custom"):
		return false 
	return get_item_metadata(item_index)["custom"]


func is_item_removed(item_index: int) -> bool:
	if typeof(get_item_metadata(item_index)) != TYPE_DICTIONARY or\
			not get_item_metadata(item_index).has("remove"):
		return false 
	return get_item_metadata(item_index)["remove"]

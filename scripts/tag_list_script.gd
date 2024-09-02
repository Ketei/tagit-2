class_name TagItemList
extends ItemList


signal item_deleted(item_text)
signal list_emptied

@export var deselect_on_focus_lost: bool = true
var delete_timer: Timer


func _ready():
	focus_exited.connect(on_focus_lost)
	delete_timer = Timer.new()
	delete_timer.wait_time = 0.1
	delete_timer.autostart = false
	delete_timer.one_shot = true
	add_child(delete_timer)


func _gui_input(_event):
	if has_focus():
		if Input.is_action_just_pressed("tag_delete") and is_anything_selected():
			remove_indexes(get_selected_items())
			delete_timer.start()
			deselect_all()
		elif Input.is_action_just_pressed("select_all_tags") and select_mode == SELECT_MULTI:
			for item in range(item_count):
				select(item, false)
		elif Input.is_action_just_pressed("deselect_all_tags") and is_anything_selected():
			deselect_all()


func get_alt_pressed() -> int:
	if Input.is_key_pressed(KEY_1):
		return 0
	elif Input.is_key_pressed(KEY_2):
		return 1
	elif Input.is_key_pressed(KEY_3):
		return 2
	else:
		return -1


func has_item(item_name: String) -> bool:
	for item in range(item_count):
		if get_item_text(item) == item_name:
			return true
	return false


func delete_item(item_name: String) -> void:
	for index in range(item_count):
		if get_item_text(index) == item_name:
			remove_item(index)
			break


func get_item_index(item_name: String) -> int:
	for item in range(item_count):
		if get_item_text(item) == item_name:
			return item
	return -1


func get_tag_array() -> Array[String]:
	var return_array: Array[String] = []
	for item in range(item_count):
		return_array.append(
				get_item_text(item))
	return return_array


func on_focus_lost() -> void:
	if deselect_on_focus_lost and is_anything_selected():
		deselect_all()


func remove_indexes(indexes_to_remove: Array[int]) -> void:
	var _indexes: Array[int] = []
	_indexes.assign(indexes_to_remove)
	_indexes.sort_custom(func(a, b): return a > b)
	for index in _indexes:
		item_deleted.emit(get_item_text(index))
		remove_item(index)
	if item_count == 0:
		list_emptied.emit()


func reset_all_tags() -> void:
	var tag_memory: Dictionary = {}
	var tag_metadata: Dictionary = {}
	
	for index in range(item_count):
		tag_metadata = get_item_metadata(index)
		if Tagger.has_tag(get_item_text(index)):
			tag_memory = Tagger.build_tag_meta(
					Tagger.get_tag(
							get_item_text(index)))
			for category in tag_metadata:
				if category == "alt_state":
					continue
				tag_metadata[category] = tag_memory[category]
			set_item_icon(
					index,
					load("res://textures/status/valid.png"))
			if not tag_memory["tooltip"].is_empty():
				set_item_tooltip(
						index,
						tag_memory["tooltip"]
				)
		elif Tagger.has_invalid_tag(get_item_text(index)):
			tag_memory = Tagger.get_empty_meta(false)
			for category in tag_metadata:
				if category == "alt_state":
					continue
				tag_metadata[category] = tag_memory[category]
			set_item_icon(
				index,
				load("res://textures/status/bad.png"))
			set_item_tooltip(
				index,
				"This is an invalid tag")
		else:
			tag_memory = Tagger.get_empty_meta()
			for category in tag_metadata:
				if category == "alt_state":
					continue
				tag_metadata[category] = tag_memory[category]
			set_item_icon(
					index,
					load("res://textures/status/generic.png"))


func set_tag_metadata(index: int, metadata: Dictionary) -> void:
	var new_meta: Dictionary = Tagger.get_empty_meta()
	new_meta.merge(metadata, true)
	set_item_metadata(index, new_meta)

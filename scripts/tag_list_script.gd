class_name TagItemList
extends ItemList


signal item_deleted(item_text)
signal list_emptied

const ALT_COLOR: Color = Color("f2875a")
const ALT_MAIN_COL: Color = Color("F4BF75")
const ALT_SUFFIX: String = " ★"
const ALT_MAIN_SUFFIX: String = " ☆"

@export var deselect_on_focus_lost: bool = true
@export var allow_alting: bool = false
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
		elif allow_alting and is_anything_selected() and (Input.is_action_just_pressed("set_alt_all") or Input.is_action_just_pressed("set_alt_main") or Input.is_action_just_pressed("set_alt_alt")):
			set_alt_on(get_selected_items(), get_alt_pressed())
		elif allow_alting and Input.is_action_just_pressed("toggle_alt"):
			toggle_alt_on(get_selected_items())


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
				tag_metadata[category] = tag_memory[category]
			set_item_icon(
					index,
					load("res://textures/status/generic.png"))


# Alt states:
# 0 = Generic Only
# 1 = Main Only
# 2 = Alt Only
func toggle_alt(item_idx: int) -> void:
	var item_dict: Dictionary = get_item_metadata(item_idx)
	
	item_dict["alt_state"] = (item_dict["alt_state"] + 1) % 3
	
	if item_dict["alt_state"] == 1:
		set_item_custom_fg_color(item_idx, ALT_MAIN_COL)
	elif item_dict["alt_state"] == 2:
		set_item_custom_fg_color(item_idx, ALT_COLOR)
	else:
		set_item_custom_fg_color(item_idx, Color.BLACK)

	if item_dict["alt_state"] == 0:
		set_item_text(item_idx, get_item_text(item_idx).trim_suffix(ALT_SUFFIX))
	elif item_dict["alt_state"] == 1:
		set_item_text(item_idx, get_item_text(item_idx) + ALT_MAIN_SUFFIX)
	elif item_dict["alt_state"] == 2:
		set_item_text(item_idx, get_item_text(item_idx).trim_suffix(ALT_MAIN_SUFFIX) + ALT_SUFFIX)


func set_alt_state(item_idx: int, alt_state: int) -> void:
	var item_dict: Dictionary = get_item_metadata(item_idx)
	
	if alt_state == item_dict["alt_state"]:
		return
	
	var prev_state: int = item_dict["alt_state"]
	var raw_text: String = get_item_text(item_idx)
	
	if prev_state == 1:
		raw_text = raw_text.trim_suffix(ALT_MAIN_SUFFIX)
	elif prev_state == 2:
		raw_text = raw_text.trim_suffix(ALT_SUFFIX)
	
	item_dict["alt_state"] = maxi(0, alt_state % 3)
	
	if item_dict["alt_state"] == 1:
		set_item_custom_fg_color(item_idx, ALT_MAIN_COL)
	elif item_dict["alt_state"] == 2:
		set_item_custom_fg_color(item_idx, ALT_COLOR)
	else:
		set_item_custom_fg_color(item_idx, Color.BLACK)

	if item_dict["alt_state"] == 0:
		set_item_text(item_idx, raw_text)
	elif item_dict["alt_state"] == 1:
		set_item_text(item_idx, raw_text + ALT_MAIN_SUFFIX)
	elif item_dict["alt_state"] == 2:
		set_item_text(item_idx, raw_text + ALT_SUFFIX)


func load_alt_state(item_idx: int) -> void:
	set_alt_state(
		item_idx,
		get_item_metadata(item_idx)["alt_state"]
	)


func set_alt_on(index_array: PackedInt32Array, toggle_option: int) -> void:
	for index in index_array:
		set_alt_state(index, toggle_option)


func toggle_alt_on(index_array: PackedInt32Array) -> void:
	for index in index_array:
		toggle_alt(index)



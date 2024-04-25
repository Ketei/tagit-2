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
	if has_focus() and Input.is_action_just_pressed("ui_text_delete") and is_anything_selected():
		remove_indexes(get_selected_items())
		#var selected_items: PackedInt32Array = get_selected_items()
		#selected_items.reverse()
		
		#for index in selected_items:
			#item_deleted.emit(get_item_text(index))
			#remove_item(index)
		#if item_count == 0:
			#list_emptied.emit()
		delete_timer.start()
		deselect_all()


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
		remove_item(index)


class_name TagReviewMenu
extends VBoxContainer

@export var input_line: LineEdit = null
@export var submit_button: Button = null
@export var tag_list: TagItemList = null

var exclusion: String = ""
var scroll_queued: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	submit_button.pressed.connect(on_add_pressed)
	input_line.text_submitted.connect(on_text_submitted)


func on_add_pressed() -> void:
	on_text_submitted(input_line.text)


func on_text_submitted(new_tag: String) -> void:
	new_tag = new_tag.strip_edges().to_lower()
	input_line.clear()
	
	if new_tag.is_empty() or tag_list.has_item(new_tag) or new_tag == exclusion:
		return
	
	tag_list.add_item(new_tag)
	
	if not scroll_queued:
		scroll_queued = true
		await get_tree().process_frame
		tag_list.get_v_scroll_bar().value = tag_list.get_v_scroll_bar().max_value
		scroll_queued = false


func get_all_items() -> Array[String]:
	var return_array: Array[String] = []
	
	for item_indx in range(tag_list.item_count):
		return_array.append(tag_list.get_item_text(item_indx))
	
	return return_array


func add_items(item_array: Array) -> void:
	for item in item_array:
		var item_text: String = item.replace("_", " ")
		if not tag_list.has_item(item_text):
			tag_list.add_item(item_text)

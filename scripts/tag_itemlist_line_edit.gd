extends LineEdit


var scroll_queued: bool = false

@export var tag_item_list: TagItemList
## Optional
@export var submit_button: Button
@export var scroll_to_bottom_on_add := true


func _ready():
	text_submitted.connect(on_text_submit)
	if submit_button != null:
		submit_button.pressed.connect(on_submit_pressed)


func on_submit_pressed() -> void:
	on_text_submit(text)


func on_text_submit(submitted_text: String) -> void:
	var formatted_text: String = submitted_text.strip_edges().to_lower()
	if not tag_item_list.has_item(formatted_text):
		tag_item_list.add_item(formatted_text)
	clear()
	if scroll_to_bottom_on_add and not scroll_queued:
		scroll_queued = true
		await get_tree().process_frame
		tag_item_list.get_v_scroll_bar().value = tag_item_list.get_v_scroll_bar().max_value
		scroll_queued = false


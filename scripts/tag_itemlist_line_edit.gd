extends LineEdit


@export var tag_item_list: TagItemList
## Optional
@export var submit_button: Button



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


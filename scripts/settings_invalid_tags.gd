extends Control


@onready var invalid_list: TagItemList = $VBoxContainer/InvalidList
@onready var invalid_add_line_edit: LineEdit = $VBoxContainer/LineContainer/InvalidAddLineEdit
@onready var add_invalid_button: Button = $VBoxContainer/LineContainer/AddInvalidButton



func _ready():
	for invalid in Tagger.invalid_tags:
		invalid_list.add_item(invalid)
	invalid_list.item_deleted.connect(on_tag_removed)
	add_invalid_button.pressed.connect(on_add_pressed)
	invalid_add_line_edit.text_submitted.connect(on_text_submitted)
	Tagger.invalid_added.connect(add_invalid_tag)


func on_add_pressed() -> void:
	on_text_submitted(invalid_add_line_edit.text)


func on_text_submitted(invalid_submit: String) -> void:
	invalid_submit = invalid_submit.strip_edges().to_lower()
	invalid_add_line_edit.clear()
	if Tagger.invalid_tags.has(invalid_submit):
		return
	add_invalid_tag(invalid_submit)
	Tagger.invalid_tags.append(invalid_submit)


func add_invalid_tag(tag_name: String) -> void:
	invalid_list.add_item(tag_name)


func on_tag_removed(tag_name: String) -> void:
	Tagger.invalid_tags.erase(tag_name)


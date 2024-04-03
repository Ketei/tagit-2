extends Control


@onready var constants_list: TagItemList = $VBoxContainer/ConstantsList
@onready var constant_add_line_edit: LineEdit = $VBoxContainer/LineContainer/ConstantAddLineEdit
@onready var constant_button: Button = $VBoxContainer/LineContainer/ConstantButton


func _ready():
	for constant in Tagger.constant_tags:
		constants_list.add_item(constant)
	constants_list.item_deleted.connect(on_tag_removed)
	constant_button.pressed.connect(on_add_pressed)
	constant_add_line_edit.text_submitted.connect(on_text_submitted)


func on_add_pressed() -> void:
	on_text_submitted(constant_add_line_edit.text)


func on_text_submitted(const_submit: String) -> void:
	const_submit = const_submit.strip_edges().to_lower()
	constant_add_line_edit.clear()
	if Tagger.constant_tags.has(const_submit):
		return
	constants_list.add_item(const_submit)
	Tagger.constant_tags.append(const_submit)


func on_tag_removed(tag_name: String) -> void:
	Tagger.constant_tags.erase(tag_name)


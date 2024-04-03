extends Control


@onready var sug_black_list: TagItemList = $VBoxContainer/SugBlackList
@onready var sug_black_add_line_edit: LineEdit = $VBoxContainer/LineContainer/SugBlackAddLineEdit
@onready var add_sug_black_button: Button = $VBoxContainer/LineContainer/AddSugBlackButton


func _ready():
	for black in Tagger.suggestion_blacklist:
		sug_black_list.add_item(black)
	sug_black_list.item_deleted.connect(on_tag_removed)
	add_sug_black_button.pressed.connect(on_add_pressed)
	sug_black_add_line_edit.text_submitted.connect(on_text_submitted)


func on_add_pressed() -> void:
	on_text_submitted(sug_black_add_line_edit.text)


func on_text_submitted(sug_submit: String) -> void:
	sug_submit = sug_submit.strip_edges().to_lower()
	sug_black_add_line_edit.clear()
	if Tagger.suggestion_blacklist.has(sug_submit):
		return
	sug_black_list.add_item(sug_submit)
	Tagger.suggestion_blacklist.append(sug_submit)


func on_tag_removed(tag_name: String) -> void:
	Tagger.suggestion_blacklist.erase(tag_name)


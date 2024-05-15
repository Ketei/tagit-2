class_name TagListImporter
extends Control


signal tags_converted(tags_array: Array[String])

@onready var tag_list_text_edit: TextEdit = $CenterContainer/PanelContainer/MarginContainer/InputSide/TagListTextEdit
@onready var divisor_line_edit: LineEdit = $CenterContainer/PanelContainer/MarginContainer/InputSide/LineEdits/DivisorLineEdit
@onready var whitespace_line_edit: LineEdit = $CenterContainer/PanelContainer/MarginContainer/InputSide/LineEdits/WhitespaceLineEdit
@onready var cancel_button: Button = $CenterContainer/PanelContainer/MarginContainer/InputSide/ButtonContainer/CancelButton
@onready var transfer_tags: Button = $CenterContainer/PanelContainer/MarginContainer/InputSide/ButtonContainer/TransferTags


func _ready():
	Tagger.disable_shortcuts()
	cancel_button.pressed.connect(on_close_pressed)
	transfer_tags.pressed.connect(convert_to_tags)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		on_close_pressed()


func convert_to_tags() -> void:
	var div_text: String = ""
	if divisor_line_edit.text.is_empty():
		div_text = "^"
	else:
		div_text =  divisor_line_edit.text
	
	var line_split: Array[String] = []
	var raw_array: Array = tag_list_text_edit.text.strip_edges()\
			.replace("\n", div_text).split(div_text)
	
	for tag_split in raw_array:
		line_split.append(
				tag_split.strip_edges().replace(
						whitespace_line_edit.text, " "))
	tags_converted.emit(line_split)


func on_close_pressed() -> void:
	Tagger.enable_shortcuts()
	queue_free()


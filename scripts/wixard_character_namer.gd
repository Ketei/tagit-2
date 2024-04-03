class_name WizardCharacterNamer
extends Control


signal finished

var name_selected: String = ""

@onready var char_name_line_edit: LineEdit = $CharcterPanel/MarginContainer/VBoxContainer/CharInfo/CharNameLineEdit
@onready var cancel_button: Button = $CharcterPanel/MarginContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var accept_button: Button = $CharcterPanel/MarginContainer/VBoxContainer/ButtonsContainer/AcceptButton


# Called when the node enters the scene tree for the first time.
func _ready():
	accept_button.pressed.connect(on_accept_pressed)
	cancel_button.pressed.connect(on_cancel_button_pressed)
	char_name_line_edit.text_submitted.connect(on_text_submitted)
	hide()


func on_accept_pressed() -> void:
	on_text_submitted(char_name_line_edit.text)


func on_text_submitted(text_submitted: String) -> void:
	name_selected = text_submitted.strip_edges().to_lower()
	finished.emit()


func on_cancel_button_pressed() -> void:
	finished.emit()


func clear() -> void:
	char_name_line_edit.clear()
	name_selected = ""


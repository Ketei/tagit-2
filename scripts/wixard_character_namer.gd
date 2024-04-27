class_name WizardCharacterNamer
extends Control


signal finished
signal character_created(character_name: String)

@onready var char_name_line_edit: LineEdit = $CharcterPanel/MarginContainer/VBoxContainer/CharInfo/CharNameLineEdit
@onready var cancel_button: Button = $CharcterPanel/MarginContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var accept_button: Button = $CharcterPanel/MarginContainer/VBoxContainer/ButtonsContainer/AcceptButton


# Called when the node enters the scene tree for the first time.
func _ready():
	accept_button.pressed.connect(on_accept_pressed)
	cancel_button.pressed.connect(on_cancel_button_pressed)
	char_name_line_edit.text_submitted.connect(on_text_submitted)
	hide()


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		hide_namer()


func show_namer() -> void:
	set_process_unhandled_key_input(true)
	visible = true


func hide_namer() -> void:
	set_process_unhandled_key_input(false)
	visible = false


func grab_line_focus() -> void:
	char_name_line_edit.grab_focus()


func on_accept_pressed() -> void:
	on_text_submitted(char_name_line_edit.text)


func on_text_submitted(text_submitted: String) -> void:
	character_created.emit(text_submitted.strip_edges().to_lower())
	hide_namer()
	clear()


func on_cancel_button_pressed() -> void:
	hide_namer()
	clear()


func clear() -> void:
	char_name_line_edit.clear()


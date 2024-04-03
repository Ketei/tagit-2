class_name SaveDataPromptWindow
extends Window


signal save_pressed
signal no_save_pressed
signal cancel_pressed


@onready var save_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/SaveButton
@onready var dont_save_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/DontSaveButton
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/CancelButton


func _ready():
	save_button.pressed.connect(on_save_pressed)
	dont_save_button.pressed.connect(on_no_save_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)


func on_save_pressed() -> void:
	save_pressed.emit()


func on_no_save_pressed() -> void:
	no_save_pressed.emit()


func on_cancel_pressed() -> void:
	cancel_pressed.emit()



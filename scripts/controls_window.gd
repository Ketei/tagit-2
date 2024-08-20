class_name ControlsWindow
extends Control


signal close_pressed

@onready var close_button: Button = $ControlsContainer/VBoxContainer/ButtonsContainer/CloseButton


func _ready():
	close_button.pressed.connect(on_close_pressed)


func on_close_pressed() -> void:
	Tagger.shortcuts_disabled = false
	close_pressed.emit()

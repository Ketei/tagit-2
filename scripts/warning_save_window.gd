class_name UnsavedWorkWindow
extends Control


signal process_continued
signal process_cancelled

const SAVE_WINDOW = preload("res://scenes/save_window.tscn")

var save_data: Dictionary = {}

var save_window: SaveWindow

@onready var save_confirm_window: SaveDataPromptWindow = $SaveConfirmWindow


func _ready():
	save_confirm_window.cancel_pressed.connect(on_save_cancel)
	save_confirm_window.close_requested.connect(on_save_cancel)
	save_confirm_window.save_pressed.connect(on_save_pressed)
	save_confirm_window.no_save_pressed.connect(on_save_success)


func on_save_pressed() -> void:
	save_confirm_window.hide()
	save_window = SAVE_WINDOW.instantiate()
	save_window.save_data = save_data
	save_window.mode = 0
	save_window.file_saved.connect(on_save_success)
	save_window.window_closed.connect(on_save_cancel)
	add_child(save_window)


func on_save_success() -> void:
	process_continued.emit()
	#queue_free()


func on_save_cancel() -> void:
	process_cancelled.emit()
	#queue_free()




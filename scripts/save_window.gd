class_name SaveWindow
extends Control


signal file_saved
signal file_loaded(file_data: Dictionary)
signal window_closed

const SAVE_DATA_ENTRY = preload("res://scenes/save_data_entry.tscn")

@export_enum("SAVE", "LOAD") var mode: int = 0

var save_idx: int = -1
var save_title: String = ""
var save_data: Dictionary = {}
var save_triggered: bool = false

@onready var save_entries_container: VBoxContainer = $CenterContainer/ExistingSavesWindow/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/SmoothScrollContainer/SaveEntriesContainer
@onready var save_name_edit: LineEdit = $CenterContainer/ExistingSavesWindow/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/DataContainer/SaveNameEdit
@onready var cancel_button: Button = $CenterContainer/ExistingSavesWindow/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var save_button: Button = $CenterContainer/ExistingSavesWindow/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ButtonsContainer/SaveButton
@onready var overwrite_dialog: ConfirmationDialog = $ConfirmationDialog

@onready var save_data_fields: HBoxContainer = $CenterContainer/ExistingSavesWindow/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/DataContainer


func _ready():
	Tagger.disable_shortcuts()
	if mode == 0:
		save_button.text = "Save"
		overwrite_dialog.confirmed.connect(on_overwirte_close.bind(true))
		overwrite_dialog.canceled.connect(on_overwirte_close.bind(false))
		save_button.pressed.connect(on_save_pressed)
		save_name_edit.text_submitted.connect(on_save_submitted)
	elif mode == 1:
		save_button.text = "Load"
		save_button.hide()
		save_data_fields.hide()

	cancel_button.pressed.connect(on_close_pressed)
	
	for save in Tagger.saves:
		var _new_entry: SaveDataEntry = SAVE_DATA_ENTRY.instantiate()
		_new_entry.save_title = save["title"]
		_new_entry.mode = mode
		_new_entry.save_data = save["data"]
		if mode == 0:
			_new_entry.save_pressed.connect(on_overwrite_pressed)
		elif mode == 1:
			_new_entry.save_pressed.connect(on_load_pressed)
		save_entries_container.add_child(_new_entry)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		on_close_pressed()


func on_load_pressed(_name: String, node_ref: SaveDataEntry) -> void:
	file_loaded.emit(node_ref.save_data)


func on_overwrite_pressed(title_name: String, node_ref: SaveDataEntry) -> void:
	var save_index = node_ref.get_index()
	#Tagger.saves[save_index]["data"] = save_data
	Tagger.save_slot(save_data, title_name, save_index)
	node_ref.signal_saved_or_loaded()
	file_saved.emit()


func on_save_pressed() -> void:
	on_save_submitted(save_name_edit.text)


func on_save_submitted(save_name: String, _prompt_overwrite: bool = true) -> void:
	#if save_data["main"].is_empty() and save_data["suggs"].is_empty() and save_data["blacklist"].is_empty():
		#return # If there is no data to save, save nothing.
	
	save_title = save_name.strip_edges()
	save_idx = -1
	
	if save_title.is_empty():
		return
	
	for save_index in range(Tagger.saves.size()):
		if Tagger.saves[save_index]["title"] == save_name:
			if _prompt_overwrite:
				save_idx = save_index
				overwrite_dialog.show()
				return

	save_file(save_title, save_idx)


func on_overwirte_close(is_confirmed: bool) -> void:
	if is_confirmed:
		save_file(save_title, save_idx)


func save_file(title: String, index:int = -1):
	#if index != -1:
		#Tagger.saves.remove_at(index)
	
	save_name_edit.clear()
	
	#Tagger.saves.append({"title": title, "data": save_data})
	Tagger.save_slot(save_data, title, index)
	
	if index == -1:
		var _new_entry: SaveDataEntry = SAVE_DATA_ENTRY.instantiate()
		_new_entry.save_title = title
		_new_entry.mode = mode
		_new_entry.save_data = save_data
		_new_entry.save_pressed.connect(on_overwrite_pressed)
		save_entries_container.add_child(_new_entry)

	save_triggered = true
	file_saved.emit()


func on_close_pressed() -> void:
	window_closed.emit()
	close_window()


func close_window() -> void:
	Tagger.enable_shortcuts()
	queue_free()



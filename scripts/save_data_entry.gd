class_name SaveDataEntry
extends HBoxContainer


signal save_pressed(save_title: String, node_ref)

@export_enum("SAVE", "LOAD") var mode: int = 0

var save_title: String = ""
var save_data: Dictionary = {}

@onready var title_label: Label = $TitleLabel
@onready var select_button: Button = $SelectButton
@onready var delete_save_button: Button = $DeleteSaveButton


# Called when the node enters the scene tree for the first time.
func _ready():
	title_label.text = save_title
	if mode == 0:
		select_button.text = "Overwrite"
	elif mode == 1:
		select_button.text = "Load"
	
	select_button.pressed.connect(on_save_pressed)
	delete_save_button.pressed.connect(on_delete_pressed)


func on_save_pressed() -> void:
	print("Select pressed for: " + save_title)
	save_pressed.emit(save_title, self)


func on_delete_pressed() -> void:
	var index: int = get_index()
	Tagger.erase_slot(index)
	queue_free()


func signal_saved_or_loaded() -> void:
	select_button.disabled = true
	var prev_text: String = select_button.text
	if mode == 0:
		select_button.text = "Saved"
	elif  mode == 1:
		select_button.text = "Loaded"
	
	await get_tree().create_timer(1.0).timeout
	select_button.disabled = false
	select_button.text = prev_text


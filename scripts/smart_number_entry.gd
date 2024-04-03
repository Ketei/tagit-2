class_name SmartNumberEntry
extends Control


var tag_title: String = ""
var tag_format: String = ""
var min_value: float = 0.0
var max_value: float = 0.0


@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var form_label: Label = $PanelContainer/MarginContainer/VBoxContainer/FormContainer/FormLabel
@onready var min_spinbox: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/MinContainer/MinSpinbox
@onready var max_spinbox: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/MaxContainer/MaxSpinbox
@onready var delete_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/DeleteButton


func _ready():
	title_label.text = tag_title
	form_label.text = tag_format + "(s/es)"
	min_spinbox.value = min_value
	max_spinbox.value = max_value
	delete_button.pressed.connect(on_delete_pressed)
	#min_spinbox.value_changed.connect(on_min_value_changed)


#func on_min_value_changed(new_min: float) -> void:
	#max_spinbox.min_value = new_min


func on_delete_pressed() -> void:
	queue_free()


func get_data() -> Dictionary:
	return {
		"title": title_label.text,
		"data": {
			"type": "nbr", 
			"format": tag_format, 
			"max": int(max_spinbox.value),
			"min": int(min_spinbox.value)}
	}


class_name TemplateLoaderItem
extends PanelContainer

signal load_pressed(index: int)
signal overwrite_pressed(index: int)
signal delete_pressed(index: int)

enum ContainerMode{
	SAVE,
	LOAD
}

var template_index: int = 0
var template_name: String = "": set = set_template_name
var mode := ContainerMode.SAVE

@onready var action_button: Button = $HBoxContainer/ButtonContainer/ActionButton
@onready var delete: Button = $HBoxContainer/ButtonContainer/Delete

@onready var template_label: Label = $HBoxContainer/TemplateLabel


func _ready():
	action_button.pressed.connect(_on_action_pressed)
	delete.pressed.connect(_on_delete_pressed)


func set_template_name(new_name: String) -> void:
	template_label.text = new_name
	template_name = new_name


func get_template_name() -> String:
	return template_name


func save_mode() -> void:
	action_button.text = "Overwrite"
	mode = ContainerMode.SAVE


func load_mode() -> void:
	action_button.text = "Load"
	mode = ContainerMode.LOAD


func _on_delete_pressed() -> void:
	delete_pressed.emit(template_index)
	queue_free()


func _on_action_pressed() -> void:
	if mode == ContainerMode.SAVE:
		overwrite_pressed.emit(template_index)
	elif mode == ContainerMode.LOAD:
		load_pressed.emit(template_index)


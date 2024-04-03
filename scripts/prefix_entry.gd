class_name PrefixEntry
extends PanelContainer

var prefix_key: String = ""
var prefix_format: String = ""

@onready var key_symbol_line_edit: LineEdit = $MarginContainer/PrefixContainer/KeySymbolLineEdit
@onready var string_format_line_edit: LineEdit = $MarginContainer/PrefixContainer/StringFormatLineEdit
@onready var update_button: Button = $MarginContainer/PrefixContainer/ButtonContainer/UpdateButton
@onready var delete_button: Button = $MarginContainer/PrefixContainer/ButtonContainer/DeleteButton


# Called when the node enters the scene tree for the first time.
func _ready():
	key_symbol_line_edit.text = prefix_key
	string_format_line_edit.text = prefix_format
	update_button.pressed.connect(on_update_pressed)
	delete_button.pressed.connect(on_delete_pressed)


func on_update_pressed() -> void:
	Tagger.prefixes[prefix_key] = string_format_line_edit.text.strip_edges()
	update_button.disabled = true
	update_button.text = "Done!"
	await get_tree().create_timer(2.0).timeout
	update_button.disabled = false
	update_button.text = "Update"


func on_delete_pressed() -> void:
	Tagger.prefixes.erase(prefix_key)
	Tagger.prefix_sorting.erase(prefix_key)
	queue_free()


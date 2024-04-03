class_name PromptTagWindow
extends Control


signal prompt_selected(prompt_value)
signal prompt_cancelled

const ES_SUFFIXES: Array[String] = ["s", "x", "z", "sh", "ch"]

enum PromptMode {
	OPTION,
	NUMBER
}

var mode := PromptMode.OPTION
var string_format: String = "nipple"

@onready var title_label: Label = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/TitleLabel
@onready var amount_spin_box: SpinBox = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/AmountSpinBox
@onready var tag_option_button: OptionButton = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/TagOptionButton
@onready var cancel_button: Button = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/ButtonsConainer/CancelButton
@onready var add_button: Button = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/ButtonsConainer/AddButton


func _ready():
	add_button.pressed.connect(on_accept_button)
	cancel_button.pressed.connect(on_cancel_button)
	tag_option_button.get_popup().max_size.y = 300


func show_option_menu(title: String, options: Array[String]) -> void:
	tag_option_button.clear()
	title_label.text = title
	for option in options:
		tag_option_button.add_item(option)
	tag_option_button.show()
	amount_spin_box.hide()
	mode = PromptMode.OPTION
	show()
	tag_option_button.grab_focus()


func show_spinbox_menu(title: String, single_form_tag: String, min_value: int = 0, max_value: int = -1) -> void:
	title_label.text = title
	string_format = single_form_tag
	amount_spin_box.min_value = min_value
	
	amount_spin_box.allow_greater = max_value < 0

	amount_spin_box.max_value = maxf(min_value, max_value)
	
	amount_spin_box.show()
	tag_option_button.hide()
	mode = PromptMode.NUMBER
	show()
	amount_spin_box.get_line_edit().grab_focus()


func on_accept_button() -> void:
	if mode == PromptMode.OPTION:
		prompt_selected.emit(
				tag_option_button.get_item_text(
						tag_option_button.selected))
	
	elif mode == PromptMode.NUMBER:
		var string_build: String = str(int(amount_spin_box.value)) + " " + string_format
		
		if 1 != amount_spin_box.value:
			if ES_SUFFIXES.has(string_format.right(1)) or ES_SUFFIXES.has(string_format.right(2)):
				string_build += "es"
			else:
				string_build += "s"
		
		prompt_selected.emit(string_build)
	hide()

func on_cancel_button():
	prompt_cancelled.emit()
	hide()


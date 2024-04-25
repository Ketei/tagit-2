class_name PromptTagWindow
extends Control


signal prompt_selected(prompt_value)
signal multiple_selected(value_array: Array[String])
signal prompt_cancelled

const ES_SUFFIXES: Array[String] = ["s", "x", "z", "sh", "ch"]

enum PromptMode {
	OPTION,
	NUMBER
}

var mode := PromptMode.OPTION
var string_format: String = ""
var selected_index: int = 0

@onready var title_label: Label = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/TitleLabel
@onready var amount_spin_box: SpinBox = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/AmountSpinBox
@onready var tag_option_button: OptionButton = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/DropdownContainer/TagOptionButton

@onready var cancel_button: Button = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/ButtonsConainer/CancelButton
@onready var cancel_multi_add: Button = $CenterContainer/MultiPanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CancelMultiAdd
@onready var confirm_multi_add: Button = $CenterContainer/MultiPanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ConfirmMultiAdd
@onready var multiple_button: Button = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/DropdownContainer/MultipleButton
@onready var add_button: Button = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/ButtonsConainer/AddButton

@onready var dropdown_container: HBoxContainer = $CenterContainer/TagDropdownAdd/MarginContainer/VBoxContainer/DropdownContainer

@onready var multi_panel_container: PanelContainer = $CenterContainer/MultiPanelContainer
@onready var tag_dropdown_add: PanelContainer = $CenterContainer/TagDropdownAdd

@onready var items_container: VBoxContainer = $CenterContainer/MultiPanelContainer/MarginContainer/VBoxContainer/SmoothScrollContainer/ItemsContainer


func _ready():
	if multi_panel_container.visible:
		multi_panel_container.visible = false
	add_button.pressed.connect(on_accept_button)
	cancel_button.pressed.connect(on_cancel_button)
	tag_option_button.get_popup().max_size.y = 300
	multiple_button.pressed.connect(_show_multiple_selector)
	cancel_multi_add.pressed.connect(on_multi_select_cancel)
	confirm_multi_add.pressed.connect(on_multi_select_submit)


func _show_multiple_selector() -> void:
	multi_panel_container.show()
	tag_dropdown_add.hide()


func on_multi_select_cancel() -> void:
	for child:CheckBox in items_container.get_children():
		if child.button_pressed:
			child.button_pressed = false
	multi_panel_container.hide()
	tag_dropdown_add.show()


func on_multi_select_submit() -> void:
	var return_array: Array[String] = []
	for child:CheckBox in items_container.get_children():
		if child.button_pressed:
			return_array.append(child.text)
		child.queue_free()
	multiple_selected.emit(return_array)
	hide()


func show_option_menu(title: String, options: Array[String], index: int) -> void:
	if not tag_dropdown_add.visible:
		tag_dropdown_add.visible = true
	if multi_panel_container.visible:
		multi_panel_container.visible = false
	
	selected_index = index
	tag_option_button.clear()
	title_label.text = title
	
	for option in options:
		tag_option_button.add_item(option)
		var _new_multi: CheckBox = CheckBox.new()
		_new_multi.text = option
		items_container.add_child(_new_multi)
		
	dropdown_container.show()
	
	amount_spin_box.hide()
	mode = PromptMode.OPTION
	show()
	tag_option_button.grab_focus()


func show_spinbox_menu(title: String, single_form_tag: String, min_value: int = 0, max_value: int = -1) -> void:
	if not tag_dropdown_add.visible:
		tag_dropdown_add.visible = true
	if multi_panel_container.visible:
		multi_panel_container.visible = false
	
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


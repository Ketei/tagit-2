class_name ReviewSmartEntries
extends Control


const SMART_SUGGESTION_ENTRY = preload("res://scenes/smart_suggestion_entry.tscn")
const SMART_NUMBER_ENTRY = preload("res://scenes/smart_number_entry.tscn")

@onready var entries_container: HFlowContainer = $TabContainer/Lists/MarginContainer/SmoothScrollContainer/HFlowContainer
@onready var title_line_edit: LineEdit = $TabContainer/Lists/AddData/TitleLineEdit
@onready var entry_line_edit: LineEdit = $TabContainer/Lists/AddData/EntryLineEdit
@onready var add_group_button: Button = $TabContainer/Lists/AddData/AddGroupButton

@onready var title_n_line_edit: LineEdit = $TabContainer/Amounts/AddData/LineEdits/TitleLineEdit
@onready var entry_n_line_edit: LineEdit = $TabContainer/Amounts/AddData/LineEdits/EntryLineEdit
@onready var min_spin_box: SpinBox = $TabContainer/Amounts/AddData/SpinBoxes/MinSpinBox
@onready var max_spin_box: SpinBox = $TabContainer/Amounts/AddData/SpinBoxes/MaxSpinBox
@onready var add_n_group_button: Button = $TabContainer/Amounts/AddData/AddGroupButton
@onready var number_hflow: HFlowContainer = $TabContainer/Amounts/MarginContainer/SmoothScrollContainer/NumberHflow

@onready var scc_entry: SmoothScrollContainer = $TabContainer/Lists/MarginContainer/SmoothScrollContainer
@onready var scc_number: SmoothScrollContainer = $TabContainer/Amounts/MarginContainer/SmoothScrollContainer


func _ready():
	title_line_edit.text_submitted.connect(on_entry_submitted)
	entry_line_edit.text_submitted.connect(on_entry_submitted)
	add_group_button.pressed.connect(on_entry_submitted)
	add_n_group_button.pressed.connect(on_number_entry_submitted)
	title_n_line_edit.text_submitted.connect(on_number_entry_submitted)
	entry_n_line_edit.text_submitted.connect(on_number_entry_submitted)


func on_entry_submitted(_ignored_text: String = "") -> void:
	var title_edit: String = title_line_edit.text.strip_edges()
	var entry_edit: String = entry_line_edit.text.strip_edges().to_lower()
	
	if title_edit.is_empty() or entry_edit.is_empty():
		return
	
	title_line_edit.clear()
	entry_line_edit.clear()
	add_entry(title_edit, entry_edit)


func on_number_entry_submitted(_ignored_text: String = "") -> void:
	var title: String = title_n_line_edit.text.strip_edges()
	var single_format: String = entry_n_line_edit.text.strip_edges().to_lower()
	
	if single_format.is_empty() or title.is_empty():
		return
	
	add_number_entry(title, single_format, min_spin_box.value, max_spin_box.value)
	
	title_n_line_edit.clear()
	entry_n_line_edit.clear()
	min_spin_box.value = 0
	max_spin_box.value = 0


func add_entry(title: String, entry: String, focus_entry: bool = true) -> void:
	for entry_group:SmartTagEntry in entries_container.get_children():
		if entry_group.suggestion_title == title:
			entry_group.add_entry(entry)
			return
	
	var _new_node: SmartTagEntry = SMART_SUGGESTION_ENTRY.instantiate()
	_new_node.suggestion_title = title
	entries_container.add_child(_new_node)
	_new_node.add_entry(entry)
	if focus_entry:
		await get_tree().process_frame
		scc_entry.scroll_to_bottom()
		_new_node.grab_line_focus()


func add_number_entry(title: String, format: String, min_val: float, max_val: float, focus_entry: bool = true) -> void:
	for entry_numb:SmartNumberEntry in number_hflow.get_children():
		if entry_numb.tag_title == title:
			entry_numb.tag_format = format
			entry_numb.min_spinbox.value = min_val
			entry_numb.max_spinbox.value = max_val
			return
	
	var _new_numb_entry := SMART_NUMBER_ENTRY.instantiate()
	_new_numb_entry.tag_title = title
	_new_numb_entry.tag_format = format
	_new_numb_entry.min_value = min_val
	_new_numb_entry.max_value = max_val
	number_hflow.add_child(_new_numb_entry)
	if focus_entry:
		await get_tree().process_frame
		scc_number.scroll_to_bottom()


func add_entries(title: String, entry_data: Dictionary) -> void:
	if entry_data["type"] == "opt":
		for tag_entry in entry_data["tags"]:
			add_entry(title, tag_entry, false)
	elif entry_data["type"] == "nbr":
		add_number_entry(
				title,
				entry_data["format"],
				entry_data["min"],
				entry_data["max"],
				false)


func get_entries() -> Array[Dictionary]:
	var return_array: Array[Dictionary] = []
	
	for entry_group:SmartTagEntry in entries_container.get_children():
		return_array.append(
			entry_group.get_data()
		)
	
	for entry_numb:SmartNumberEntry in number_hflow.get_children():
		return_array.append(
			entry_numb.get_data()
		)

	return return_array


func has_entries() -> bool:
	return 0 < entries_container.get_child_count() or 0 < number_hflow.get_child_count()


func disable_manual_input() -> void:
	title_line_edit.editable = false
	entry_line_edit.editable = false
	add_group_button.disabled = true
	title_n_line_edit.editable = false
	entry_n_line_edit.editable = false
	add_n_group_button.disabled = true


func enable_manual_input() -> void:
	title_line_edit.editable = true
	entry_line_edit.editable = true
	add_group_button.disabled = false
	title_n_line_edit.editable = true
	entry_n_line_edit.editable = true
	add_n_group_button.disabled = false


func clear_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()
	
	for n_child in number_hflow.get_children():
		n_child.queue_free()


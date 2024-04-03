extends Control

const PREFIX_ENTRY = preload("res://scenes/prefix_entry.tscn")

@onready var node_container: VBoxContainer = $ToolContainer/ListContainer/PanelContainer/SmoothScrollContainer/NodeContainer

@onready var create_button: Button = $ToolContainer/ListContainer/VBoxContainer/CreateContainer/CreateButton
@onready var test_button: Button = $ToolContainer/MarginContainer/RightSide/TestContainer/TestButton

@onready var create_prefix_line_edit: LineEdit = $ToolContainer/ListContainer/VBoxContainer/CreateContainer/CreatePrefixLineEdit
@onready var format_line_edit: LineEdit = $ToolContainer/ListContainer/VBoxContainer/CreateContainer/FormatLineEdit
@onready var test_out_line_edit: LineEdit = $ToolContainer/MarginContainer/RightSide/TestOutLineEdit
@onready var test_line_edit: LineEdit = $ToolContainer/MarginContainer/RightSide/TestContainer/TestLineEdit


func _ready():
	create_button.pressed.connect(on_create_submitted)
	create_prefix_line_edit.text_submitted.connect(on_create_submitted)
	format_line_edit.text_submitted.connect(on_create_submitted)
	test_button.pressed.connect(on_test_pressed)
	test_line_edit.text_submitted.connect(on_test_submitted)
	
	for prefix in Tagger.prefixes:
		var new_entry: PrefixEntry = PREFIX_ENTRY.instantiate()
		new_entry.prefix_key = prefix
		new_entry.prefix_format = Tagger.prefixes[prefix]
		node_container.add_child(new_entry)


func on_create_submitted(_ignored: String = "") -> void:
	var prefix_key: String = create_prefix_line_edit.text.strip_edges()
	var format_key: String = format_line_edit.text.strip_edges()
	
	if Tagger.prefixes.has(prefix_key):
		return
	
	Tagger.prefixes[prefix_key] = format_key
	Tagger.sort_prefixes()
	
	var new_entry: PrefixEntry = PREFIX_ENTRY.instantiate()
	new_entry.prefix_key = prefix_key
	new_entry.prefix_format = format_key
	node_container.add_child(new_entry)


func on_test_pressed() -> void:
	on_test_submitted(test_line_edit.text)


func on_test_submitted(text_to_test: String) -> void:
	var prefixed_string = text_to_test.strip_edges()
	var prefix_found: String = ""
	
	for prefix in Tagger.prefix_sorting:
		if prefixed_string.begins_with(prefix):
			prefix_found = prefix
			break
	
	if not prefix_found.is_empty():
		prefixed_string = prefixed_string.trim_prefix(prefix_found)
		test_out_line_edit.text = Tagger.convert_prefix(prefix_found, prefixed_string)
	else:
		test_out_line_edit.text = prefixed_string


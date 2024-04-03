class_name WebsiteCreatorTool
extends Control


@onready var web_name_line_edit: LineEdit = $MarginContainer/VBoxContainer/WebNameLineEdit
@onready var web_url_line_edit: LineEdit = $MarginContainer/VBoxContainer/WebUrlLineEdit
@onready var web_id_line_edit: LineEdit = $MarginContainer/VBoxContainer/WebIDLineEdit
@onready var whitespace_line_edit: TextEdit = $MarginContainer/VBoxContainer/WhiteSepContainer/WhitespaceLineEdit
@onready var separator_line_edit: TextEdit = $MarginContainer/VBoxContainer/WhiteSepContainer/SeparatorLineEdit
@onready var website_desc: TextEdit = $MarginContainer/VBoxContainer/TextEdit
@onready var clear_button: Button = $MarginContainer/VBoxContainer/ButtonsContainer/ClearButton
@onready var export_button: Button = $MarginContainer/VBoxContainer/ButtonsContainer/ExportButton

@onready var web_save_file_dialog: FileDialog = $WebSaveFileDialog


func _ready():
	web_save_file_dialog.file_selected.connect(on_file_selected)
	export_button.pressed.connect(on_save_pressed)
	clear_button.pressed.connect(clear_all)


func clear_all() -> void:
	web_name_line_edit.clear()
	web_url_line_edit.clear()
	web_id_line_edit.clear()
	whitespace_line_edit.clear()
	separator_line_edit.clear()
	website_desc.clear()


func on_save_pressed() -> void:
	web_save_file_dialog.show()


func on_file_selected(file_path: String) -> void:
	var website_source := WebsiteResource.new()
	var file_target: String = file_path.replace("\\", "/")
	if not file_target.ends_with(".tres"):
		file_target += ".tres"
	
	website_source.website_id = web_id_line_edit.text.strip_edges().to_lower()
	website_source.website_name = web_name_line_edit.text.strip_edges()
	website_source.website_desc = website_desc.text
	website_source.website_address = web_url_line_edit.text.strip_edges()
	website_source.website_whitespace = whitespace_line_edit.text
	website_source.website_separator = separator_line_edit.text
	
	ResourceSaver.save(website_source, file_target)



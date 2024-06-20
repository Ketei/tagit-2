extends Control


signal template_loaded(template_index: int)
signal template_saved(template_index: int, template_name: String)
signal template_cancelled

const TEMPLATE_ELEMENT = preload("res://scenes/template_element.tscn")

var entry_titles: Array[String] = []

@onready var templates_container: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/SmoothScrollContainer/MarginContainer/TemplatesContainer
@onready var template_le: LineEdit = $CenterContainer/PanelContainer/VBoxContainer/TemplateName/TemplateLE

@onready var save_button: Button = $CenterContainer/PanelContainer/VBoxContainer/TemplateName/SaveButton
@onready var cancel_button: Button = $CenterContainer/PanelContainer/VBoxContainer/TemplateName/CancelButton


func _ready():
	visible = false
	listen_for_input(false)
	save_button.pressed.connect(on_save_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		template_cancelled.emit()
		get_viewport().set_input_as_handled()


func _on_cancel_pressed() -> void:
	template_cancelled.emit()


func listen_for_input(is_listening: bool) -> void:
	set_process_unhandled_key_input(is_listening)


func load_entries(save_mode: bool) -> void:
	DumbUtils.signal_disconnect_all(template_le.text_submitted)
	
	if save_mode:
		save_button.text = "Save"
		template_le.text_submitted.connect(on_save_pressed)
	else:
		save_button.text = "Load"
		template_le.text_submitted.connect(on_load_text)
	
	for template_index in range(Tagger.templates.size()):
		var new_template: TemplateLoaderItem = TEMPLATE_ELEMENT.instantiate()
		templates_container.add_child(new_template)
		new_template.template_name = Tagger.templates[template_index]["title"]
		entry_titles.append(Tagger.templates[template_index]["title"])
		new_template.delete_pressed.connect(_on_template_deleted)
		if save_mode:
			new_template.save_mode()
			new_template.overwrite_pressed.connect(on_overwrite_pressed)
		else:
			new_template.load_mode()
			new_template.load_pressed.connect(on_load_pressed)


func clear_entries() -> void:
	template_le.clear()
	entry_titles.clear()
	for entry in templates_container.get_children():
		entry.visible = false
		entry.queue_free()


func on_overwrite_pressed(slot_title: String) -> void:
	template_saved.emit(
		Tagger.get_template_idx_with_title(slot_title),
		template_le.text.strip_edges())


func on_save_pressed(_ignore := "") -> void:
	var save_title: String = template_le.text.strip_edges()
	
	if save_title.is_empty():
		return
	
	var entry_index: int = Tagger.get_template_idx_with_title(save_title)
	
	template_saved.emit(entry_index, save_title)


func on_load_text(_ignored: String = "") -> void:
	var find: int = Tagger.get_template_idx_with_title(
			template_le.text.strip_edges())
	
	if find == -1:
		return
	
	template_loaded.emit(find)


func on_load_pressed(slot_title: String):
	template_loaded.emit(
			Tagger.get_template_idx_with_title(slot_title)
	)


func _on_template_deleted(template_title: String) -> void:
	for template_idx in range(Tagger.templates.size()):
		if Tagger.templates[template_idx]["title"] == template_title:
			Tagger.erase_template(template_idx)
			return
	Tagger.log_message("Error deleting template: " + template_title, Tagger.LoggingLevel.ERROR)

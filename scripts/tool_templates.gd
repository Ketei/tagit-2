class_name ToolTemplates
extends Control

@onready var desc_text_edit: TextEdit = $MarginContainer/VBoxContainer/DescriptionContainer/DescTextEdit

@onready var normal_tags_item: TagItemList = $MarginContainer/VBoxContainer/TemplateTags/NormalContainer/NomalTagsItem
@onready var suggestions: TagItemList = $MarginContainer/VBoxContainer/TemplateTags/SuggestionsContainer/Suggestions

@onready var tags_line_edit: LineEdit = $MarginContainer/VBoxContainer/TemplateTags/NormalContainer/InputContainer/AutoSearch
@onready var suggestions_line_edit: LineEdit = $MarginContainer/VBoxContainer/TemplateTags/SuggestionsContainer/InputContainer/AutoSearch

@onready var add_tag_button: Button = $MarginContainer/VBoxContainer/TemplateTags/NormalContainer/InputContainer/AddTagButton
@onready var add_suggestion_button: Button = $MarginContainer/VBoxContainer/TemplateTags/SuggestionsContainer/InputContainer/AddSuggestionButton
@onready var save_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/SaveButton
@onready var load_button: Button = $MarginContainer/VBoxContainer/ButtonContainer/LoadButton
@onready var clear_button: Button = $MarginContainer/VBoxContainer/DescriptionContainer/Label/ClearButton


@onready var template_selector = $TemplateSelector


func _ready():
	save_button.pressed.connect(on_save_pressed)
	load_button.pressed.connect(on_load_pressed)
	
	add_tag_button.pressed.connect(on_add_tag_pressed)
	tags_line_edit.text_submitted.connect(on_add_tag_submitted)
	
	add_suggestion_button.pressed.connect(on_add_sugg_pressed)
	suggestions_line_edit.text_submitted.connect(on_add_sugg_submitted)
	
	template_selector.template_saved.connect(_on_template_overwrite)
	template_selector.template_loaded.connect(_on_template_loaded)
	template_selector.template_cancelled.connect(_on_selector_cancelled)
	clear_button.pressed.connect(clear_all)


func on_add_sugg_pressed() -> void:
	on_add_sugg_submitted(suggestions_line_edit.text)


func on_add_sugg_submitted(suggestion_submitted: String) -> void:
	var suggestion: String = Tagger.get_alias(suggestion_submitted.strip_edges().to_lower())
	
	if not suggestions.has_item(suggestion):
		suggestions.add_item(suggestion)
	suggestions_line_edit.clear()	


func on_add_tag_pressed() -> void:
	on_add_tag_submitted(tags_line_edit.text)


func on_add_tag_submitted(tag_submited: String) -> void:
	var final_tag: String = Tagger.get_alias(tag_submited.strip_edges().to_lower())
	if not normal_tags_item.has_item(final_tag):
		normal_tags_item.add_item(final_tag)
	tags_line_edit.clear()


func show_save_selector() -> void:
	template_selector.clear_entries()
	template_selector.load_entries(true)
	template_selector.listen_for_input(true)
	template_selector.visible = true


func show_load_selector() -> void:
	template_selector.clear_entries()
	template_selector.load_entries(false)
	template_selector.listen_for_input(true)
	template_selector.visible = true


func on_save_pressed() -> void:
	save_button.release_focus()
	show_save_selector()
	#save_button.text = "Template Created"
	#save_button.disabled = true
	#Tagger.save_template(get_data())
	#clear_all()
	#await get_tree().create_timer(1.0).timeout
	#save_button.disabled = false
	#save_button.text = "Save Template"


func on_load_pressed() -> void:
	load_button.release_focus()
	show_load_selector()


func _on_template_overwrite(template_index: int, template_name: String) -> void:
	template_selector.listen_for_input(false)
	template_selector.visible = false
	Tagger.save_template(get_data(template_name), template_index)
	Tagger.queue_notification("Template Saved")


func _on_template_loaded(template_index: int) -> void:
	template_selector.listen_for_input(false)
	template_selector.visible = false
	normal_tags_item.clear()
	suggestions.clear()
	var template_data: Dictionary = Tagger.templates[template_index]
	desc_text_edit.text = template_data["desc"]
	for main_tag in template_data["main"]:
		normal_tags_item.add_item(main_tag)
	for sugg_tag in template_data["suggs"]:
		suggestions.add_item(sugg_tag)


func _on_selector_cancelled() -> void:
	template_selector.visible = false
	template_selector.listen_for_input(false)


func clear_all() -> void:
	desc_text_edit.clear()
	normal_tags_item.clear()
	suggestions.clear()
	tags_line_edit.clear()
	suggestions_line_edit.clear()


func get_data(template_name: String) -> Dictionary:
	return {
		"title": template_name.strip_edges(),
		"desc": desc_text_edit.text.strip_edges(),
		"main": normal_tags_item.get_tag_array(),
		"suggs": suggestions.get_tag_array()
	}


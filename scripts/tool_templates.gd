class_name ToolTemplates
extends Control

@onready var desc_text_edit: TextEdit = $MarginContainer/VBoxContainer/DescriptionContainer/DescTextEdit

@onready var normal_tags_item: TagItemList = $MarginContainer/VBoxContainer/TemplateTags/NormalContainer/NomalTagsItem
@onready var suggestions: TagItemList = $MarginContainer/VBoxContainer/TemplateTags/SuggestionsContainer/Suggestions

@onready var name_line_edit: LineEdit = $MarginContainer/VBoxContainer/NameContainer/NameLineEdit
@onready var tags_line_edit: LineEdit = $MarginContainer/VBoxContainer/TemplateTags/NormalContainer/InputContainer/TagsLineEdit
@onready var suggestions_line_edit: LineEdit = $MarginContainer/VBoxContainer/TemplateTags/SuggestionsContainer/InputContainer/SuggestionsLineEdit

@onready var add_tag_button: Button = $MarginContainer/VBoxContainer/TemplateTags/NormalContainer/InputContainer/AddTagButton
@onready var add_suggestion_button: Button = $MarginContainer/VBoxContainer/TemplateTags/SuggestionsContainer/InputContainer/AddSuggestionButton
@onready var save_button: Button = $MarginContainer/VBoxContainer/SaveButton


func _ready():
	save_button.pressed.connect(on_save_pressed)
	
	add_tag_button.pressed.connect(on_add_tag_pressed)
	tags_line_edit.text_submitted.connect(on_add_tag_submitted)
	
	add_suggestion_button.pressed.connect(on_add_sugg_pressed)
	suggestions_line_edit.text_submitted.connect(on_add_sugg_submitted)


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


func on_save_pressed() -> void:
	save_button.text = "Template Created"
	save_button.disabled = true
	Tagger.save_template(get_data())
	clear_all()
	await get_tree().create_timer(1.0).timeout
	save_button.disabled = false
	save_button.text = "Save Template"


func clear_all() -> void:
	desc_text_edit.clear()
	normal_tags_item.clear()
	suggestions.clear()
	name_line_edit.clear()
	tags_line_edit.clear()
	suggestions_line_edit.clear()
	


func get_data() -> Dictionary:
	return {
		"title": name_line_edit.text.strip_edges(),
		"desc": desc_text_edit.text.strip_edges(),
		"main": normal_tags_item.get_tag_array(),
		"suggs": suggestions.get_tag_array()
	}


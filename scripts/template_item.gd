class_name TemplateItem
extends Control


signal template_selected(tags: Array[String], suggs: Array[String])
signal template_deleted(template_name: String)

var template_name: String = ""
var template_desc: String = ""
var template_tags: Array[String] = []
var template_sugs: Array[String] = []


@onready var template_name_label: Label = $PanelContainer/MarginContainer/TemplateInfo/TemplateNameLabel
@onready var template_desc_text_edit: TextEdit = $PanelContainer/MarginContainer/TemplateInfo/TemplateDescTextEdit
@onready var template_tags_line_edit: LineEdit = $PanelContainer/MarginContainer/TemplateInfo/TemplateTagsLineEdit
@onready var template_suggestions_line_edit: LineEdit = $PanelContainer/MarginContainer/TemplateInfo/TemplateSuggestionsLineEdit
@onready var delete_template_button: Button = $PanelContainer/MarginContainer/TemplateInfo/TemplateButtons/DeleteTemplateButton
@onready var load_template_button: Button = $PanelContainer/MarginContainer/TemplateInfo/TemplateButtons/LoadTemplateButton


func _ready():
	template_name_label.text = template_name
	template_desc_text_edit.text = template_desc
	template_tags_line_edit.text = ", ".join(template_tags)
	template_suggestions_line_edit.text = ", ".join(template_sugs)
	
	load_template_button.pressed.connect(on_load_pressed)
	delete_template_button.pressed.connect(on_delete_pressed)


func on_load_pressed() -> void:
	template_selected.emit(template_tags, template_sugs)


func on_delete_pressed() -> void:
	var item_index: int = get_index()
	Tagger.erase_template(item_index)
	template_deleted.emit(template_name)
	queue_free()



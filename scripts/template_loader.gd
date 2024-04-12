class_name TemplateLoader
extends Control

signal template_selected(main_tags: Array[String], suggestions: Array[String])
signal create_template_pressed

const TEMPLATE_ITEM = preload("res://scenes/template_item.tscn")

@onready var template_list: VBoxContainer = $MarginContainer/VBoxContainer/SmoothScrollContainer/TemplateList
@onready var template_container: SmoothScrollContainer = $MarginContainer/VBoxContainer/SmoothScrollContainer
@onready var no_templates_found: VBoxContainer = $MarginContainer/VBoxContainer/NoTemplatesFound

@onready var back_button: Button = $MarginContainer/VBoxContainer/MarginContainer/ButtonContainer/BackButton
@onready var go_create_template_button: Button = $MarginContainer/VBoxContainer/NoTemplatesFound/GoCreateTemplateButton


# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.pressed.connect(on_return_pressed)
	go_create_template_button.pressed.connect(on_create_template_pressed)
	
	for template:Dictionary in Tagger.templates:
		var _new_template: TemplateItem = TEMPLATE_ITEM.instantiate()
		_new_template.template_name = template["title"]
		_new_template.template_desc = template["desc"]
		_new_template.template_tags.assign(template["main"])
		_new_template.template_sugs.assign(template["suggs"])
		_new_template.template_selected.connect(on_template_selected)
		_new_template.template_deleted.connect(on_template_deleted)
		template_list.add_child(_new_template)
	
	template_container.visible = not Tagger.templates.is_empty()
	no_templates_found.visible = Tagger.templates.is_empty()
	


func on_template_deleted(_temp_title: String) -> void:
	if Tagger.templates.is_empty():
		template_container.hide()
		no_templates_found.show()


func on_create_template_pressed() -> void:
	create_template_pressed.emit()
	queue_free()


func on_template_selected(main_tags: Array[String], suggestions: Array[String]):
	template_selected.emit(main_tags, suggestions)


func on_return_pressed() -> void:
	queue_free()


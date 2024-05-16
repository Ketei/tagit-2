class_name BatchTagCreator
extends Control


var standard_color_nodes: Array[ColorCheckBox] = []

@onready var name_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/BasicsContainer/LineContainer/NameLineEdit
@onready var parent_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/ParentsContainer/ParentLineEdit
@onready var suggestion_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/SuggestionContainer/SuggestionLineEdit
@onready var custom_meta_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/MetaContainer/CustomMetaContainer/CustomMetaLineEdit
@onready var tooltip_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TooltipContainer/TooltipLineEdit

@onready var category_option_button: CategoryOptionButton = $MarginContainer/MainContainer/FieldsContainer/DataContainer/BasicsContainer/CatContainer/CategoryOptionButton


@onready var wiki_text_edit: TextEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/WikiInfo/TextEdit

@onready var parents_tag_item_list: TagItemList = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/ParentsContainer/ParentsTagItemList
@onready var suggestions_tag_item_list: TagItemList = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/SuggestionContainer/SuggestionsTagItemList
@onready var meta_item_list: TagItemList = $MarginContainer/MainContainer/FieldsContainer/MetaContainer/CustomMetaContainer/MetaItemList

@onready var standard_col_container: VBoxContainer = $MarginContainer/MainContainer/FieldsContainer/MetaContainer/StandardColContainer

@onready var generate_button: Button = $MarginContainer/MainContainer/ButtonsContainer/GenerateButton



func _ready():
	explore_for_colors(standard_col_container)
	generate_button.pressed.connect(on_generate_clicked)


func on_generate_clicked() -> void:
	var meta_array: Array[String] = []
	for color_node:ColorCheckBox in standard_color_nodes:
		if color_node.button_pressed:
			meta_array.append(color_node.get_color())
	for custom_meta in meta_item_list.get_tag_array():
		if meta_array.has(custom_meta):
			continue
		meta_array.append(custom_meta)
	
	for item in meta_array:
		var tag_data: Dictionary = generate_tag_data(item)
		var new_tag := Tag.new()
		new_tag.tag = tag_data["tag"]
		new_tag.category = tag_data["category"]
		new_tag.parents = tag_data["parents"].duplicate()
		new_tag.suggestions = tag_data["suggestions"].duplicate()
		new_tag.tooltip = tag_data["tooltip"]
		new_tag.save_default()
		Tagger.register_tag(
				new_tag.tag,
				Tagger.get_default_tag_filepath(new_tag.tag))
		Tagger.tag_updated.emit(new_tag.tag)


func generate_tag_data(tag_meta: String) -> Dictionary:
	var return_dict: Dictionary = {
		"tag": "",
		"wiki": "",
		"tooltip": "",
		"parents": [],
		"suggestions": [],
		"category": category_option_button.get_category()
	}
	
	return_dict["tag"] = name_line_edit.text.strip_edges().to_lower().format([tag_meta])
	return_dict["wiki"] = wiki_text_edit.text.strip_edges().format([tag_meta])
	return_dict["tooltip"] = tooltip_line_edit.text.strip_edges().format([tag_meta])
	for parent_item in parents_tag_item_list.get_tag_array():
		return_dict["parents"].append(parent_item.format([tag_meta]))
	for suggestion_item in suggestions_tag_item_list.get_tag_array():
		return_dict["suggestions"].append(
				suggestion_item.format([tag_meta]))
	
	return return_dict


func explore_for_colors(parent_node: Node) -> void:
	for child in parent_node.get_children():
		if child is ColorCheckBox:
			standard_color_nodes.append(child)
		else:
			explore_for_colors(child)



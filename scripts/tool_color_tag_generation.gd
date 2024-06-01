class_name BatchTagCreator
extends Control


var standard_color_nodes: Array[ColorCheckBox] = []

@onready var name_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/BasicsContainer/LineContainer/NameLineEdit
@onready var parent_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/ParentsContainer/ParentLineEdit
@onready var suggestion_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/SuggestionContainer/SuggestionLineEdit
@onready var custom_meta_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/MetaContainer/CustomMetaContainer/CustomMetaLineEdit
@onready var tooltip_line_edit: LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TooltipContainer/TooltipLineEdit
@onready var alias_line_edit:LineEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/AliasesContainer/AliasLineEdit

@onready var category_option_button: CategoryOptionButton = $MarginContainer/MainContainer/FieldsContainer/DataContainer/BasicsContainer/CatContainer/CategoryOptionButton


@onready var wiki_text_edit: TextEdit = $MarginContainer/MainContainer/FieldsContainer/DataContainer/WikiInfo/TextEdit

@onready var parents_tag_item_list: TagItemList = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/ParentsContainer/ParentsTagItemList
@onready var suggestions_tag_item_list: TagItemList = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/SuggestionContainer/SuggestionsTagItemList
@onready var meta_item_list: TagItemList = $MarginContainer/MainContainer/FieldsContainer/MetaContainer/CustomMetaContainer/MetaItemList
@onready var alias_tag_item_list: TagItemList = $MarginContainer/MainContainer/FieldsContainer/DataContainer/TagsContainer/AliasesContainer/AliasTagItemList

@onready var standard_col_container: VBoxContainer = $MarginContainer/MainContainer/FieldsContainer/MetaContainer/StandardColContainer

@onready var generate_button: Button = $MarginContainer/MainContainer/ButtonsContainer/GenerateButton

@onready var prio_spin_box: SpinBox = $MarginContainer/MainContainer/FieldsContainer/DataContainer/BasicsContainer/PriorityContainer/PrioSpinBox



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
	
	var replace_confirmation: TaggerConfirmationDialog = Tagger.create_confirmation_dialog()
	
	for item in meta_array:
		var tag_data: Dictionary = generate_tag_data(item)
		if Tagger.has_tag(tag_data["tag"]):
			replace_confirmation.set_data(
					"Replace Existing Tag",
					"The tag {0} already exists in your local database.\nReplace it with the generated one?".format([tag_data["tag"]]),
					"Replace",
					"Skip")
			replace_confirmation.visible = true
			await get_tree().process_frame
			# Wait a frame to move to center
			replace_confirmation.move_to_center()
			var replace_tag: bool = await replace_confirmation.dialog_confirmed
			if not replace_tag:
				continue
			replace_confirmation.visible = false

		var new_tag := Tag.new()
		new_tag.tag = tag_data["tag"]
		new_tag.category = tag_data["category"]
		new_tag.parents.assign(tag_data["parents"])
		new_tag.suggestions.assign(tag_data["suggestions"])
		new_tag.tooltip = tag_data["tooltip"]
		new_tag.wiki_entry = tag_data["wiki"]
		new_tag.aliases.assign(tag_data["aliases"])
		new_tag.tag_priority = tag_data["priority"]
		Tagger.register_tag(
				new_tag.tag,
				new_tag.save())
		Tagger.tag_updated.emit(new_tag.tag)
		Tagger.log_message("Tag \"" + new_tag.tag + "\" created.")
	
	replace_confirmation.queue_free()
	Tagger.queue_notification(
			"All tags successfully created.",
			"Tags Created"
	)
	clear_fields()


func generate_tag_data(tag_meta: String) -> Dictionary:
	var return_dict: Dictionary = {
		"tag": "",
		"wiki": "",
		"tooltip": "",
		"parents": [],
		"suggestions": [],
		"aliases": [],
		"category": category_option_button.get_category(),
		"priority": int(prio_spin_box.value)
	}
	
	return_dict["tag"] = name_line_edit.text.strip_edges().to_lower().replace(Tagger.WILDCARD_CHAR, tag_meta)
	return_dict["wiki"] = wiki_text_edit.text.strip_edges().replace(Tagger.WILDCARD_CHAR, tag_meta)
	
	var tag_tooltip_text: String = tooltip_line_edit.text.strip_edges()
	if tag_tooltip_text.begins_with("*"):
		return_dict["tooltip"] = DumbUtils.capitalize(tag_tooltip_text.replace(Tagger.WILDCARD_CHAR, tag_meta))
	else:
		return_dict["tooltip"] = tag_tooltip_text.replace(Tagger.WILDCARD_CHAR, tag_meta)
	
	for parent_item in parents_tag_item_list.get_tag_array():
		return_dict["parents"].append(parent_item.replace(Tagger.WILDCARD_CHAR, tag_meta))
	for suggestion_item in suggestions_tag_item_list.get_tag_array():
		return_dict["suggestions"].append(
				suggestion_item.replace(Tagger.WILDCARD_CHAR, tag_meta))
	for alias_item in alias_tag_item_list.get_tag_array():
		return_dict["aliases"].append(
				alias_item.replace(Tagger.WILDCARD_CHAR, tag_meta)
		)
	return return_dict


func explore_for_colors(parent_node: Node) -> void:
	for child in parent_node.get_children():
		if child is ColorCheckBox:
			standard_color_nodes.append(child)
		else:
			explore_for_colors(child)


func clear_fields() -> void:
	name_line_edit.clear()
	category_option_button.select(0)
	wiki_text_edit.clear()
	tooltip_line_edit.clear()
	parents_tag_item_list.clear()
	suggestions_tag_item_list.clear()
	parent_line_edit.clear()
	suggestion_line_edit.clear()
	for checkbox in standard_color_nodes:
		checkbox.button_pressed = false
	meta_item_list.clear()
	custom_meta_line_edit.clear()
	alias_tag_item_list.clear()
	alias_line_edit.clear()


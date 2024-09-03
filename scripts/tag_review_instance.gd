class_name ReviewWindow
extends Control


signal groups_cleared

var tag_id: int = 0
var loaded_tag: String = ""

var _implication_get: bool = true
var _wiki_get: bool = true
var _suggestion_get: bool = true
var _parents_get: bool = true

@onready var tag_name_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/NameContainer/TagNameLineEdit
@onready var tooltip_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/WikiContainer/TooltipLineEdit
@onready var title_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Groups/TabContainer/Lists/AddData/TitleLineEdit
@onready var entry_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Groups/TabContainer/Lists/AddData/EntryLineEdit
@onready var title_number_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Groups/TabContainer/Amounts/AddData/LineEdits/TitleLineEdit
@onready var entry_number_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Groups/TabContainer/Amounts/AddData/LineEdits/EntryLineEdit
@onready var alias_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Aliases/InputContainer/AliasLineEdit
@onready var parents_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Parents/InputContainer/ParentsLineEdit
@onready var suggestion_line_edit: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Suggestions/InputContainer/SuggestionLineEdit

@onready var min_spin_box: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Groups/TabContainer/Amounts/AddData/SpinBoxes/MinSpinBox
@onready var max_spin_box: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Groups/TabContainer/Amounts/AddData/SpinBoxes/MaxSpinBox

@onready var fetch_status: Label = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TopMenu/FetchStatus

@onready var category_option_button: CategoryOptionButton = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/Props/CategoryContainer/CategoryOptionButton

@onready var priority_spin_box: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/Props/PriorityContainer/PrioritySpinBox

@onready var parents_item_list: TagItemList = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Parents/ParentsItemList
@onready var suggestion_item_list: TagItemList = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Suggestions/SuggestionItemList
@onready var alias_item_list: TagItemList = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Aliases/AliasItemList

@onready var wiki_text_edit: TextEdit = $MarginContainer/VBoxContainer/HBoxContainer/WikiContainer/TabContainer/Write/WikiTextEdit

@onready var wiki_rich_label: RichTextLabel = $MarginContainer/VBoxContainer/HBoxContainer/WikiContainer/TabContainer/Preview/WikiRichLabel

@onready var fetch_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/NameContainer/FetchButton
@onready var clear_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TopMenu/ClearButton
@onready var load_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/NameContainer/LoadButton
@onready var save_button: Button = $MarginContainer/VBoxContainer/ButtonsContainer/SaveButton
@onready var delete_button: Button = $MarginContainer/VBoxContainer/ButtonsContainer/DeleteButton

@onready var parents_list: TagReviewMenu = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Parents
@onready var suggestions_list: TagReviewMenu = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Suggestions
@onready var aliases_list: TagReviewMenu = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Aliases

@onready var groups_list: ReviewSmartEntries = $MarginContainer/VBoxContainer/HBoxContainer/SearchContainer/TabContainer/Groups


func _ready():
	fetch_button.pressed.connect(on_fetch_pressed)
	clear_button.pressed.connect(on_clear_pressed)
	load_button.pressed.connect(on_load_pressed)
	tag_name_line_edit.text_submitted.connect(on_search_submit)
	save_button.pressed.connect(on_save_pressed)
	delete_button.pressed.connect(on_delete_pressed)


func on_clear_pressed() -> void:
	clear_all()


func on_load_pressed() -> void:
	on_search_submit(tag_name_line_edit.text)


func on_search_submit(tag_string: String) -> void:
	tag_name_line_edit.editable = false
	load_button.disabled = true
	fetch_button.disabled = true
	var tag_search: String = tag_string.strip_edges().to_lower()
	#var tag_search: String = Tagger.get_alias(
			#tag_string.strip_edges().to_lower())
	
	clear_all(false)
	groups_list.disable_manual_input()
	while groups_list.has_entries():
		await get_tree().process_frame
	groups_list.enable_manual_input()
	
	if tag_search.is_empty() or not Tagger.has_tag(tag_search):
		tag_name_line_edit.editable = true
		load_button.disabled = false
		fetch_button.disabled = false
		return
	
	var tag_load: Tag = Tagger.get_tag(tag_search)
	
	#tag_name_line_edit.text = tag_search
	#tag_name_line_edit.caret_column = tag_name_line_edit.text.length()
	
	category_option_button.select_category(tag_load.category)
	priority_spin_box.value = tag_load.tag_priority
	wiki_text_edit.text = tag_load.wiki_entry
	#wiki_rich_label.text = tag_load.wiki_entry
	wiki_rich_label.parse_bbcode(tag_load.wiki_entry)
	tooltip_line_edit.text = tag_load.tooltip
	loaded_tag = tag_search
	delete_button.text = "Delete \"" + tag_search + "\""
	delete_button.show()
	
	for parent in tag_load.parents:
		parents_item_list.add_item(parent)
	for suggestion in tag_load.suggestions:
		suggestion_item_list.add_item(suggestion)
	for alias in tag_load.aliases:
		alias_item_list.add_item(alias)
	for smart_suggest in tag_load.smart_tags:
		groups_list.add_entries(smart_suggest["title"], smart_suggest["data"])
	tag_name_line_edit.editable = true
	load_button.disabled = false
	fetch_button.disabled = false


func on_fetch_pressed() -> void:
	var tag_fetch: String = tag_name_line_edit.text.strip_edges().replace(" ", "_").to_lower()
	if tag_fetch.is_empty():
		return
	fetch_status.text = "Fetching e621 info for: " + tag_fetch
	fetch_button.disabled = true
	clear_button.disabled = true
	load_button.disabled = true
	save_button.disabled = true
	_implication_get = false
	_wiki_get = false
	_suggestion_get = false
	_parents_get = false
	ESixRequester.queue_job(
			Tagger.get_wiki_request_url(tag_fetch),
			self,
			ESixRequester.JOB_TYPES.WIKI)
	ESixRequester.queue_job(
			Tagger.get_alias_request_url(tag_fetch),
			self,
			ESixRequester.JOB_TYPES.ALIAS)
	ESixRequester.queue_job(
			Tagger.get_parents_request_url(tag_fetch),
			self,
			ESixRequester.JOB_TYPES.PARENTS)
	ESixRequester.queue_job(
			Tagger.get_tag_request_url(
					tag_fetch,
					Tagger.E621_CATEGORY.ALL,
					"date",
					1), 
			self,
			ESixRequester.JOB_TYPES.SUGGESTION)


func on_exit_pressed() -> void:
	hide()


func process_response(response: Array, request_type: ESixRequester.JOB_TYPES) -> void:
	if request_type == ESixRequester.JOB_TYPES.WIKI: # 
		if not response.is_empty():
			wiki_text_edit.text = ESixRequester.convert_from_wiki(response[0]["body"])
			wiki_rich_label.text = wiki_text_edit.text
			tag_id = response[0]["id"]
			if category_option_button.get_item_metadata(category_option_button.selected) == Tagger.Categories.GENERAL:
				category_option_button.select_category(
						Tagger.get_category_equivalent(
								response[0]["category_id"]))
		_wiki_get = true
	elif request_type == ESixRequester.JOB_TYPES.ALIAS:
		if not response.is_empty():
			for implication:Dictionary in response:
				if implication["status"] != "active":
					continue
				var implication_string: String = implication["antecedent_name"].replace("_", " ")
				if not alias_item_list.has_item(implication_string):
					alias_item_list.add_item(implication_string)
		_implication_get = true
	
	elif request_type == ESixRequester.JOB_TYPES.SUGGESTION:
		if not response.is_empty():
			if response[0]["related_tags"] != "[]":
				var strength_dict: Dictionary = ESixRequester.parse_tag_strength(response[0]["related_tags"])
				for strength in strength_dict:
					if Tagger.suggestion_confidence <= int(strength):
						for tag in strength_dict[strength]:
							var suggestion: String = tag.replace("_", " ")
							if not suggestion_item_list.has_item(suggestion) and\
							not parents_item_list.has_item(suggestion) and\
							not Tagger.suggestion_blacklist.has(suggestion):
								suggestion_item_list.add_item(suggestion)
		_suggestion_get = true
	elif request_type == ESixRequester.JOB_TYPES.PARENTS:
		if not response.is_empty():
			for dict_response in response:
				if dict_response["status"] == "active":
					var parent_tag: String = dict_response["consequent_name"].replace("_", " ")
					if not parents_item_list.has_item(parent_tag):
						parents_item_list.add_item(parent_tag)
		_parents_get = true
	
	if _wiki_get and _implication_get and _suggestion_get and _parents_get:
		fetch_status.text = ""
		fetch_button.disabled = false
		clear_button.disabled = false
		load_button.disabled = false
		save_button.disabled = false


func on_save_pressed() -> void:
	var tag_title: String = tag_name_line_edit.text.strip_edges().to_lower()
	
	loaded_tag = tag_title
	delete_button.text = "Delete \"" + tag_title + "\""
	delete_button.visible = true
	
	if tag_title.is_empty():
		return
	
	save_button.disabled = true
	save_button.text = "Saved"
	
	var tag_resource := Tag.new()
	tag_resource.tag = tag_title
	tag_resource.tag_id = tag_id
	tag_resource.tag_priority = int(priority_spin_box.value)
	tag_resource.category = category_option_button.get_category()
	tag_resource.tooltip = tooltip_line_edit.text.strip_edges()
	tag_resource.wiki_entry = wiki_text_edit.text
	tag_resource.parents = parents_list.get_all_items()
	tag_resource.suggestions = suggestions_list.get_all_items()
	#tag_resource.aliases = aliases_list.get_all_items()
	tag_resource.smart_tags = groups_list.get_entries()
	
	var parent_recursion = tag_resource.parents.find(tag_title)
	var alias_recursion = tag_resource.aliases.find(tag_title)
	
	if parent_recursion != -1:
		tag_resource.parents.remove_at(parent_recursion)
	if alias_recursion != -1:
		tag_resource.aliases.remove_at(alias_recursion)	
	
	
	
	# Validation to prevent self-referencing
	var aliases: Array[String] = aliases_list.get_all_items()
	DumbUtils.array_remove_all(aliases, tag_title)
	tag_resource.aliases = aliases
	
	tag_resource.save()
	Tagger.register_tag(
			tag_resource.tag,
			Tagger.get_tag_filepath(tag_title))
	Tagger.tag_updated.emit(tag_resource.tag)
	await get_tree().create_timer(2.5).timeout
	save_button.text = "Save"
	save_button.disabled = false


func clear_all(include_line := true) -> void:
	if include_line:
		tag_name_line_edit.clear()
	priority_spin_box.value = 0
	category_option_button.select(0)
	parents_item_list.clear()
	suggestion_item_list.clear()
	alias_item_list.clear()
	wiki_text_edit.clear()
	#wiki_rich_label.clear()
	#wiki_rich_label.text = ""
	tooltip_line_edit.clear()
	title_line_edit.clear()
	entry_line_edit.clear()
	alias_line_edit.clear()
	parents_line_edit.clear()
	suggestion_line_edit.clear()
	title_number_line_edit.clear()
	entry_number_line_edit.clear()
	min_spin_box.value = 0
	max_spin_box.value = -1
	delete_button.hide()
	loaded_tag = ""
	groups_list.clear_entries()


func on_delete_pressed() -> void:
	if not Tagger.has_tag(loaded_tag):
		return

	OS.move_to_trash(Tagger.get_tag_filepath(loaded_tag))
	Tagger.remove_tag(loaded_tag)
	Tagger.tag_deleted.emit(loaded_tag)
	clear_all()

class_name ToolDuplicateCleaner
extends Control


signal tag_erased(erased_path: String)

var duplicates: Array[Array] = []

var left_path: String = ""
var right_path: String = ""

var left_tag: Tag = null
var right_tag: Tag = null

@onready var section_option_button: OptionButton = $MarginContainer/AllItems/HBoxContainer/SectionOptionButton
@onready var left_tab_container: TabContainer = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer
@onready var rigth_tab_container: TabContainer = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer

@onready var h_title_separator = $MarginContainer/AllItems/HTitleSeparator
@onready var transfer_menu_button: MenuButton = $MarginContainer/AllItems/KeepButtons/TransferMenuButton

@onready var reload_left_button: Button = $MarginContainer/AllItems/HBoxContainer/ReloadLeftButton
@onready var reload_right_button: Button = $MarginContainer/AllItems/HBoxContainer/ReloadRightButton

@onready var search_duplicates_button: Button = $MarginContainer/Explanation/VBoxContainer/SearchDuplicatesButton
@onready var duplicate_label_status: Label = $MarginContainer/Explanation/VBoxContainer/DuplicateLabelStatus


# Root nodes
@onready var dupe_remover_window = $MarginContainer/AllItems
@onready var searcher_window = $MarginContainer/Explanation


# Left fields
@onready var left_category_label: Label = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/BasicInfo/BasicData/CatContainer/CategoryLabel
@onready var left_prio_label: Label = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/BasicInfo/BasicData/PrioContainer/PrioLabel
@onready var left_groups_rich_text_label: RichTextLabel = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/BasicInfo/GroupsAliasesContainer/GroupsContainer/SmoothScrollContainer/PanelContainer/GroupsRichTextLabel
@onready var left_parents_item_list: ItemList = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/BasicInfo/ParentsSuggestions/ParentsContainer/ParentsItemList
@onready var left_suggs_item_list: ItemList = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/BasicInfo/ParentsSuggestions/SuggsContainer/SuggsItemList
@onready var left_alias_item_list: ItemList = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/BasicInfo/GroupsAliasesContainer/AliasContainer/AliasItemList
@onready var left_wiki_rich_text_label: RichTextLabel = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/WikiToolTipContainer/SmoothScrollContainer/PanelContainer/WikiRichTextLabel
@onready var left_tooltip_line_edit: LineEdit = $MarginContainer/AllItems/DataContainer/LeftTagFields/LeftTabContainer/WikiToolTipContainer/TooltipLineEdit
@onready var keep_left_button: Button = $MarginContainer/AllItems/KeepButtons/KeepLeftButton


# Right fields
@onready var right_category_label: Label = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/BasicInfo/BasicData/CatContainer/CategoryLabel
@onready var right_prio_label: Label = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/BasicInfo/BasicData/PrioContainer/PrioLabel
@onready var right_groups_rich_text_label: RichTextLabel = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/BasicInfo/GroupsAliasesContainer/GroupsContainer/SmoothScrollContainer/PanelContainer/GroupsRichTextLabel
@onready var right_parents_item_list: ItemList = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/BasicInfo/ParentsSuggestions/ParentsContainer/ParentsItemList
@onready var right_suggs_item_list: ItemList = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/BasicInfo/ParentsSuggestions/SuggsContainer/SuggsItemList
@onready var right_alias_item_list: ItemList = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/BasicInfo/GroupsAliasesContainer/AliasContainer/AliasItemList
@onready var right_wiki_rich_text_label = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/WikiToolTipContainer/SmoothScrollContainer/PanelContainer/WikiRichTextLabel
@onready var right_tooltip_line_edit = $MarginContainer/AllItems/DataContainer/RightTagFields/RightTabContainer/WikiToolTipContainer/TooltipLineEdit
@onready var keep_right_button: Button = $MarginContainer/AllItems/KeepButtons/KeepRightButton


func _ready():
	section_option_button.item_selected.connect(on_option_selected)
	transfer_menu_button.transfer_right_pressed.connect(transfer_to_right)
	transfer_menu_button.transfer_left_pressed.connect(transfer_to_left)
	reload_left_button.pressed.connect(reload_left)
	reload_right_button.pressed.connect(reload_right)
	search_duplicates_button.pressed.connect(on_search_dupes_pressed)
	keep_left_button.pressed.connect(on_keep_left_pressed)
	keep_right_button.pressed.connect(on_keep_right_pressed)
	if not searcher_window.visible:
		searcher_window.visible = true
	if dupe_remover_window.visible:
		dupe_remover_window.visible = false


func search_for_dupliactes() -> void:
	duplicates.clear()
	
	var tags_found: Dictionary = {}
	
	var directories := DirAccess.get_directories_at(Tagger.database_path + Tagger.TAGS_PATH)

	for file in DirAccess.get_files_at(Tagger.database_path + Tagger.TAGS_PATH):
		if file.get_extension() != "tres":
			Tagger.log_message(
					"File " + file +  " is not a resource file. Skipping -",
					Tagger.LoggingLevel.WARNING
			)
			continue
		
		var tag: Resource = load(Tagger.database_path + Tagger.TAGS_PATH + file)
		
		if not tag is Tag:
			Tagger.log_message(
					"File " + file +  " is not a Tag file. Skipping -",
					Tagger.LoggingLevel.WARNING
			)
			continue
		
		if not tags_found.has(tag.tag):
			tags_found[tag.tag] = []
		
		tags_found[tag.tag].append(Tagger.database_path + Tagger.TAGS_PATH + file)
	
	for directory in directories:
		for tag_file in DirAccess.get_files_at(Tagger.database_path + Tagger.TAGS_PATH + directory + "/"):
			if tag_file.get_extension() != "tres":
				Tagger.log_message(
						"File \"" + tag_file +  "\" is not a resource file. Skipping",
						Tagger.LoggingLevel.WARNING
				)
				continue
			
			var tag: Resource = load(Tagger.database_path + Tagger.TAGS_PATH + directory + "/" + tag_file)
			
			if not tag is Tag:
				Tagger.log_message(
						"File \"" + tag_file +  "\" is not a Tag file. Skipping",
						Tagger.LoggingLevel.WARNING
				)
				continue
			if not tags_found.has(tag.tag):
				tags_found[tag.tag] = []
		
			tags_found[tag.tag].append(Tagger.database_path + Tagger.TAGS_PATH + directory + "/" + tag_file)
	
	for tag_name in tags_found:
		if 1 < tags_found[tag_name].size():
			duplicates.append(tags_found[tag_name])


func on_option_selected(index: int) -> void:
	left_tab_container.current_tab = index
	rigth_tab_container.current_tab = index


func load_tags(path_left: String, path_right: String, duplicate_count: int) -> void:
	clear_all()
	var groups_string: String = ""
	left_path = path_left
	right_path = path_right
	left_tag = load(path_left)
	right_tag = load(path_right)
	h_title_separator.set_title_name(DumbUtils.title_case(left_tag.tag) + str(" (", duplicate_count, ")"))
	
	# Left Loading
	left_category_label.text = Tagger.get_category_name(left_tag.category)
	left_prio_label.text = str(left_tag.tag_priority)
	for parent in left_tag.parents:
		left_parents_item_list.add_item(parent)
	for suggestion in left_tag.suggestions:
		left_suggs_item_list.add_item(suggestion)
	for group in left_tag.smart_tags:
		groups_string += "[color=LIGHT_SALMON]" + group["title"] + "[/color]: "
		if group["data"]["type"] == "opt":
			for group_tag in group["data"]["tags"]:
				groups_string += group_tag
				if group_tag != group["data"]["tags"][-1]:
					groups_string += ", "
				else:
					groups_string += "\n"
		else:
			groups_string += "#\n"
	
	left_groups_rich_text_label.text = groups_string
	
	for alias in left_tag.aliases:
		left_alias_item_list.add_item(alias)
	
	left_wiki_rich_text_label.text = left_tag.wiki_entry
	left_tooltip_line_edit.text = left_tag.tooltip
	
	groups_string = ""
	
	# Right Loading
	right_category_label.text = Tagger.get_category_name(right_tag.category)
	right_prio_label.text = str(right_tag.tag_priority)
	for parent in right_tag.parents:
		right_parents_item_list.add_item(parent)
	for suggestion in right_tag.suggestions:
		right_suggs_item_list.add_item(suggestion)
	
	for group in right_tag.smart_tags:
		groups_string += "[color=LIGHT_SALMON]" + group["title"] + "[/color]: "
		if group["data"]["type"] == "opt":
			for group_tag in group["data"]["tags"]:
				groups_string += group_tag
				if group_tag != group["data"]["tags"][-1]:
					groups_string += ", "
				else:
					groups_string += "\n"
		else:
			groups_string += "#\n"
	
	right_groups_rich_text_label.text = groups_string
	
	for alias in right_tag.aliases:
		right_alias_item_list.add_item(alias)
	
	right_wiki_rich_text_label.text = right_tag.wiki_entry
	right_tooltip_line_edit.text = right_tag.tooltip


func reload_left() -> void:
	if left_path.is_empty():
		return
	var groups_string: String = ""
	clear_left()
	left_tag = load(left_path)
	left_category_label.text = Tagger.get_category_name(left_tag.category)
	left_prio_label.text = str(left_tag.tag_priority)
	for parent in left_tag.parents:
		left_parents_item_list.add_item(parent)
	for suggestion in left_tag.suggestions:
		left_suggs_item_list.add_item(suggestion)

	for group in left_tag.smart_tags:
		groups_string += "[color=LIGHT_SALMON]" + group["title"] + "[/color]: "
		if group["data"]["type"] == "opt":
			for group_tag in group["data"]["tags"]:
				groups_string += group_tag
				if group_tag != group["data"]["tags"][-1]:
					groups_string += ", "
				else:
					groups_string += "\n"
		else:
			groups_string += "#\n"
	
	left_groups_rich_text_label.text = groups_string
	
	for alias in left_tag.aliases:
		left_alias_item_list.add_item(alias)
	
	left_wiki_rich_text_label.text = left_tag.wiki_entry
	left_tooltip_line_edit.text = left_tag.tooltip


func reload_right() -> void:
	if right_path.is_empty():
		return
	right_tag = load(right_path)
	clear_right()
	var groups_string: String = ""
	right_category_label.text = Tagger.get_category_name(right_tag.category)
	right_prio_label.text = str(right_tag.tag_priority)
	for parent in right_tag.parents:
		right_parents_item_list.add_item(parent)
	for suggestion in right_tag.suggestions:
		right_suggs_item_list.add_item(suggestion)
	
	for group in right_tag.smart_tags:
		groups_string += "[color=LIGHT_SALMON]" + group["title"] + "[/color]: "
		if group["data"]["type"] == "opt":
			for group_tag in group["data"]["tags"]:
				groups_string += group_tag
				if group_tag != group["data"]["tags"][-1]:
					groups_string += ", "
				else:
					groups_string += "\n"
		else:
			groups_string += "#\n"
	
	right_groups_rich_text_label.text = groups_string
	
	for alias in right_tag.aliases:
		right_alias_item_list.add_item(alias)
	
	right_wiki_rich_text_label.text = right_tag.wiki_entry
	right_tooltip_line_edit.text = right_tag.tooltip


func clear_left() -> void:
	left_category_label.text = ""
	left_prio_label.text = ""
	left_groups_rich_text_label.text = ""
	left_parents_item_list.clear()
	left_suggs_item_list.clear()
	left_alias_item_list.clear()
	left_wiki_rich_text_label.text = ""
	left_tooltip_line_edit.clear()


func clear_right() -> void:
	right_category_label.text = ""
	right_prio_label.text = ""
	right_groups_rich_text_label.text = ""
	right_parents_item_list.clear()
	right_suggs_item_list.clear()
	right_alias_item_list.clear()
	right_wiki_rich_text_label.text = ""
	right_tooltip_line_edit.clear()


func clear_all() -> void:
	clear_left()
	clear_right()


func transfer_to_left(what: String) -> void:
	if what == "category":
		left_tag.category = right_tag.category
		left_category_label.text = Tagger.get_category_name(left_tag.category)
	elif what == "priority":
		left_tag.tag_priority = right_tag.tag_priority
		left_prio_label.text = str(left_tag.tag_priority)
	elif what == "parents":
		left_tag.parents = right_tag.parents
		left_parents_item_list.clear()
		for new_parent in left_tag.parents:
			left_parents_item_list.add_item(new_parent)
	elif what == "suggestions":
		left_tag.suggestions = right_tag.suggestions
		left_suggs_item_list.clear()
		for new_sugg in left_tag.suggestions:
			left_suggs_item_list.add_item(new_sugg)
	elif what == "groups":
		left_tag.smart_tags = right_tag.smart_tags
		var groups_string: String = ""
		for group in left_tag.smart_tags:
			groups_string += "[color=LIGHT_SALMON]" + group["title"] + "[/color]: "
			if group["data"]["type"] == "opt":
				for group_tag in group["data"]["tags"]:
					groups_string += group_tag
					if group_tag != group["data"]["tags"][-1]:
						groups_string += ", "
					else:
						groups_string += "\n"
			else:
				groups_string += "#\n"
	
		left_groups_rich_text_label.text = groups_string
		
	elif what == "aliases":
		left_tag.aliases = right_tag.aliases
		left_alias_item_list.clear()
		for new_alias in left_tag.aliases:
			left_alias_item_list.add_item(new_alias)
	elif what == "wiki":
		left_tag.wiki_entry = right_tag.wiki_entry
		left_wiki_rich_text_label.text = left_tag.wiki_entry
	elif what == "tooltip":
		left_tag.tooltip = right_tag.tooltip
		left_tooltip_line_edit.text = left_tag.tooltip


func transfer_to_right(what: String) -> void:
	if what == "category":
		right_tag.category = left_tag.category
		right_category_label.text = Tagger.get_category_name(right_tag.category)
	elif what == "priority":
		right_tag.tag_priority = left_tag.tag_priority
		right_prio_label.text = str(right_tag.tag_priority)
	elif what == "parents":
		right_tag.parents = left_tag.parents
		right_parents_item_list.clear()
		for new_parent in right_tag.parents:
			right_parents_item_list.add_item(new_parent)
	elif what == "suggestions":
		right_tag.suggestions = left_tag.suggestions
		right_suggs_item_list.clear()
		for new_sugg in right_tag.suggestions:
			right_suggs_item_list.add_item(new_sugg)
	elif what == "groups":
		right_tag.smart_tags = left_tag.smart_tags
		var groups_string: String = ""
		for group in right_tag.smart_tags:
			groups_string += "[color=LIGHT_SALMON]" + group["title"] + "[/color]: "
			if group["data"]["type"] == "opt":
				for group_tag in group["data"]["tags"]:
					groups_string += group_tag
					if group_tag != group["data"]["tags"][-1]:
						groups_string += ", "
					else:
						groups_string += "\n"
			else:
				groups_string += "#\n"
	
		right_groups_rich_text_label.text = groups_string
		
	elif what == "aliases":
		right_tag.aliases = left_tag.aliases
		right_alias_item_list.clear()
		for new_alias in right_tag.aliases:
			left_alias_item_list.add_item(new_alias)
	elif what == "wiki":
		right_tag.wiki_entry = left_tag.wiki_entry
		right_wiki_rich_text_label.text = right_tag.wiki_entry
	elif what == "tooltip":
		right_tag.tooltip = left_tag.tooltip
		right_tooltip_line_edit.text = right_tag.tooltip


func on_keep_left_pressed() -> void:
	OS.move_to_trash(right_path)
	ResourceSaver.save(
			left_tag,
			left_path
	)
	tag_erased.emit(right_path)


func on_keep_right_pressed() -> void:
	OS.move_to_trash(left_path)
	ResourceSaver.save(
			left_tag,
			right_path
	)
	tag_erased.emit(left_path)


func on_search_dupes_pressed() -> void:
	search_for_dupliactes()
	print(duplicates)
	
	if 0 == duplicates.size():
		duplicate_label_status.text = "No duplicates found!"
		return
	Tagger.disable_shortcuts()
	Tagger.disable_menus()
	
	if not duplicate_label_status.text.is_empty():
		duplicate_label_status.text = ""
	
	searcher_window.hide()
	dupe_remover_window.show()
	
	var tracker: Array = []
	
	for path_array in duplicates: # Array with Arrays
		tracker = path_array.duplicate()
		
		while can_continue_comparing(tracker):
			load_tags(
				tracker[0],
				tracker[1],
				tracker.size()
			)
			tracker.erase(
				await tag_erased
			)
	
	Tagger.reload_tags()
	Tagger.enable_shortcuts()
	Tagger.enable_menus()
	Tagger.queue_notification("All duplicates have been processed", "Duplicates processed")
	searcher_window.show()
	dupe_remover_window.hide()


func can_continue_comparing(array_to_count: Array) -> bool:
	return 1 < array_to_count.size()


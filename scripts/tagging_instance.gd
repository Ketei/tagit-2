class_name TaggerWindow
extends Control


signal tag_searched(tag_name)
signal window_switch_signaled(window_id: int, args: Dictionary)

const TEMPLATE_LOADER = preload("res://scenes/template_loader.tscn")
const SAVE_WINDOW = preload("res://scenes/save_window.tscn")
const TAG_LIST_IMPORTER = preload("res://scenes/tag_list_importer.tscn")
const WIZARD_INSTANCE = preload("res://scenes/wizard_instance.tscn")
const IN_TAG_EDITOR = preload("res://scenes/intag_editor.tscn")
const TAG_MAP_BROWSER = preload("res://scenes/gui_tag_select.tscn")
const UNSAVED_WINDOW = preload("res://scenes/unsaved_window.tscn")

var scroll_called: bool = false
var prompt_save_on_new: bool = false

var prefix_recursion_protection: Array[String] = []

var template_loader: TemplateLoader
var save_window: SaveWindow
var load_window: SaveWindow
var tag_importer: TagListImporter
var tag_wizard: WizardInstance
var in_tag_editor: InTagEditor
var tag_map_browser: TagMapBrowser
var unsaved_work_window: UnsavedWorkWindow


@onready var sites_option_menu = $MarginContainer/MainContainer/Final/Platform/SitesOptionMenu
@onready var final_tags: TextEdit = $MarginContainer/MainContainer/Final/FinalTags

@onready var tag_items: TagTreeList = $MarginContainer/MainContainer/MainTags/TagTreeList
@onready var suggestion_list: TagItemList = $MarginContainer/MainContainer/Suggests/SuggestionList
@onready var smart_list: TagItemList = $MarginContainer/MainContainer/Suggests/SmartList

#@onready var auto_fill: ItemList = $MarginContainer/MainContainer/MainTags/Interact/AddTag/VBoxContainer/AutoFill

@onready var add_tag_line_edit: LineEdit = $MarginContainer/MainContainer/MainTags/Interact/AutoSearch

@onready var full_search_button: Button = $MarginContainer/MainContainer/MainTags/Interact/FullSearchButton
@onready var select_tag_button: Button = $MarginContainer/MainContainer/MainTags/Interact/SelectTagButton
@onready var add_current_button: Button = $MarginContainer/MainContainer/MainTags/Interact/AddButton
@onready var generate_button: Button = $MarginContainer/MainContainer/Final/Buttons/GeneratorButtons/GenerateButton
@onready var export_button: Button = $MarginContainer/MainContainer/Final/Buttons/ExtraOptions/ExportButton
@onready var copy_button: Button = $MarginContainer/MainContainer/Final/Buttons/ExtraOptions/CopyButton
@onready var template_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/TemplateButton
@onready var load_tag_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/LoadTagButton
@onready var wizard_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/WizardButton
@onready var new_list_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/NewListButton
@onready var save_list_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/SaveListButton
@onready var load_list_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/LoadListButton
@onready var generator_toggle = $MarginContainer/MainContainer/Final/Buttons/GeneratorButtons/GeneratorToggle

@onready var special_tag_window: PromptTagWindow = $SpecialTagWindow
@onready var tag_full_search: TagFullSearch = $TagFullSearch
@onready var session_blacklist: SessionBlacklist = $SessionBlacklist

@onready var export_file_dialog: FileDialog = $ExportFileDialog


func _ready():
	add_current_button.pressed.connect(on_add_current_pressed)
	add_tag_line_edit.text_submitted.connect(on_tag_submitted)
	suggestion_list.item_activated.connect(on_suggestion_activated)
	smart_list.item_activated.connect(on_special_tag_activated)
	special_tag_window.prompt_selected.connect(on_special_submitted)
	special_tag_window.multiple_selected.connect(on_multiple_special_submitted)
	template_button.pressed.connect(display_template_loader)
	generate_button.pressed.connect(generate_full_tags)
	copy_button.pressed.connect(on_copy_pressed)
	#auto_fill.item_submited.connect(on_tag_submitted)
	suggestion_list.item_deleted.connect(
			session_blacklist.add_to_blacklist)
	smart_list.item_deleted.connect(
			session_blacklist.add_to_group_blacklist)
	export_file_dialog.file_selected.connect(on_save_dialog_ok)
	export_button.pressed.connect(on_export_pressed)
	load_tag_button.pressed.connect(open_taglist_importer)
	wizard_button.pressed.connect(summon_wizard)
	tag_items.tag_activated.connect(on_item_activated)
	tag_items.wiki_tag_pressed.connect(on_tag_button_wiki_activated)
	tag_items.list_changed.connect(on_main_list_changed)
	select_tag_button.pressed.connect(on_tag_map_open)
	tag_full_search.add_selected_pressed.connect(on_full_search_add)
	tag_full_search.full_search_closed.connect(on_full_search_closed)
	full_search_button.pressed.connect(on_full_search_open)
	new_list_button.pressed.connect(new_list)
	save_list_button.pressed.connect(open_save_window)
	load_list_button.pressed.connect(open_load_window)
	Tagger.tag_updated.connect(on_tag_updated)


func on_full_search_add(tags: Array[String]) -> void:
	var prev_text: String = add_tag_line_edit.text
	load_tag_array(tags)
	add_tag_line_edit.text = prev_text


func on_special_submitted(tag_string: String) -> void:
	on_tag_submitted(tag_string)
	if Tagger.remove_after_use:
		smart_list.remove_item(special_tag_window.selected_index)
		if Tagger.blacklist_after_remove:
			session_blacklist.add_to_group_blacklist(special_tag_window.title_label.text)
	Tagger.enable_shortcuts()


func on_multiple_special_submitted(tag_array: Array[String]) -> void:
	load_tag_array(tag_array)
	if Tagger.remove_after_use:
		smart_list.remove_item(special_tag_window.selected_index)
		if Tagger.blacklist_after_remove:
			session_blacklist.add_to_group_blacklist(special_tag_window.title_label.text)
	Tagger.enable_shortcuts()


func sort_tags_alphabetically() -> void:
	tag_items.sort_tags_by_text()


func sort_tags_by_alt_state() -> void:
	tag_items.sort_tags_by_alt_state()


func on_full_search_open() -> void:
	tag_full_search.show_searcher()
	tag_full_search.grab_search_focus()


func on_tag_map_open() -> void:
	if tag_map_browser != null:
		return
	
	tag_map_browser = TAG_MAP_BROWSER.instantiate()
	tag_map_browser.tag_selected.connect(on_map_selected)
	add_child(tag_map_browser)
	select_tag_button.release_focus()


func on_map_selected(tag_to_add: String) -> void:
	if tag_to_add.is_empty():
		return
	on_tag_submitted(tag_to_add)


func summon_wizard() -> void:
	if wizard_button.has_focus():
		wizard_button.release_focus()
	tag_wizard = WIZARD_INSTANCE.instantiate()
	tag_wizard.wizard_finished.connect(on_wizard_orgasm)
	add_child(tag_wizard)


func on_go_to_fetch_pressed(tag_name: String) -> void:
	window_switch_signaled.emit(1, {"tag": tag_name})


func on_create_template_pressed() -> void:
	window_switch_signaled.emit(2, {"tool_id": 1})


func on_wizard_orgasm(tag_data: Dictionary) -> void:
	var _online_suggs: bool = Tagger.search_online_suggestions
	
	Tagger.search_online_suggestions = false
	
	for tag in tag_data["tags"]:
		on_tag_submitted(tag)
	
	for sugg in tag_data["suggestions"]:
		if not tag_items.has_tag(sugg) and not suggestion_list.has_item(sugg):
			suggestion_list.add_item(sugg)
	
	Tagger.search_online_suggestions = _online_suggs
	Tagger.enable_shortcuts()
	tag_wizard.close_wizard()


func on_item_activated(tag_tree: TreeItem) -> void:
	if Input.is_action_pressed("shift_key") and Tagger.has_tag(tag_tree.get_text(0)):
		window_switch_signaled.emit(0, {"tag": tag_tree.get_text(0)})
		return
	
	if in_tag_editor != null:
		return
	
	Tagger.disable_shortcuts()
	in_tag_editor = IN_TAG_EDITOR.instantiate()
	#in_tag_editor.done_editing.connect(on_tag_edited)
	in_tag_editor.add_suggestions.connect(on_intag_suggestions)
	in_tag_editor.go_to_fetch.connect(on_go_to_fetch_pressed)
	#in_tag_editor.alt_edited.connect(on_alt_edited)
	add_child(in_tag_editor)
	in_tag_editor.set_data_and_show(tag_tree)


func on_tag_button_wiki_activated(tag_string: String) -> void:
	window_switch_signaled.emit(0, {"tag": tag_string})


func on_intag_suggestions(suggs:Array[String]) -> void:
	for sug_to_tag in suggs:
		on_tag_submitted(sug_to_tag)


func open_taglist_importer() -> void:
	if tag_importer != null:
		return
	tag_importer = TAG_LIST_IMPORTER.instantiate()
	tag_importer.tags_converted.connect(on_tags_imported)
	add_child(tag_importer)


func on_tags_imported(tags_loaded: Array[String]) -> void:
	var _sugg_load: bool = Tagger.search_online_suggestions
	Tagger.search_online_suggestions = false
	
	for tag in tags_loaded:
		on_tag_submitted(tag)
	
	Tagger.search_online_suggestions = _sugg_load
	
	tag_importer.queue_free()


func load_tag_array(array_to_load: Array[String]) -> void:
	for tag in array_to_load:
		on_tag_submitted(tag)


func clear_main_list() -> void:
	if tag_items.tag_count() == 0:
		return
	var warning_window: TaggerConfirmationDialog = Tagger.create_confirmation_dialog()
	warning_window.set_data(
			"Clear all tags",
			"Clear all tags from tag list?",
			"Clear")
	warning_window.visible = true
	var confirm: bool = await warning_window.dialog_confirmed
	if confirm:
		tag_items.clear_tags()
	warning_window.queue_free()


func open_session_blacklist() -> void:
	session_blacklist.show_blacklist()


func open_load_window() -> void:
	if load_window != null:
		return
	
	if load_list_button.has_focus():
		load_list_button.release_focus()
	
	if prompt_save_on_new:
		Tagger.disable_shortcuts()
		var warning_window: TaggerConfirmationDialog = Tagger.create_confirmation_dialog()
		warning_window.set_data(
			"Unsaved Changes...",
			"You have unsaved changes.\nDo you wish to save before loading?",
			"Save",
			"Don't save")
		warning_window.visible = true
		
		var save_before_load: bool = await warning_window.dialog_confirmed
		
		warning_window.visible = false
		warning_window.queue_free()
		
		if save_before_load:
			open_save_window()
			await save_window.window_closed
			if not save_window.save_triggered:
				Tagger.enable_shortcuts()
				return # Cancel load as save was canceled

		Tagger.enable_shortcuts()
		
	load_window = SAVE_WINDOW.instantiate()
	load_window.mode = 1
	load_window.file_loaded.connect(on_load_pressed)
	add_child(load_window)
	

func on_load_pressed(load_data: Dictionary) -> void:
	clear_all()
	
	var _load_sugg: bool = Tagger.search_online_suggestions
	
	Tagger.search_online_suggestions = false
	
	for main_tag in load_data["main"]:
		var metadata: Dictionary = Tagger.get_empty_meta()
		metadata.merge(load_data["main"][main_tag], true)
		tag_items.add_tag(main_tag, metadata, true)
	
	for suggestion in load_data["suggs"]:
		var _sugg_index: int = suggestion_list.add_item(suggestion)
		if Tagger.has_tag(suggestion):
			var _tool: String = Tagger.get_tag(suggestion).tooltip
			if not _tool.is_empty():
				suggestion_list.set_item_tooltip(
					_sugg_index,
					_tool)
		
	for smart in load_data["smart"]:
		var smart_index: int = smart_list.add_item(smart)
		smart_list.set_item_metadata(
				smart_index,
				load_data["smart"][smart])
	for black in load_data["blacklist"]:
		session_blacklist.add_to_blacklist(black)
	load_window.close_window()
	
	Tagger.search_online_suggestions = _load_sugg


func open_save_window() -> void:
	if save_window != null:
		return
	if save_list_button.has_focus():
		save_list_button.release_focus()
	save_window = SAVE_WINDOW.instantiate()
	save_window.mode = 0
	save_window.file_saved.connect(on_file_saved)
	save_window.save_data = get_save_data()
	add_child(save_window)


func is_system_open() -> bool:
	return template_loader != null or save_window != null or\
	tag_importer != null or tag_wizard != null or in_tag_editor != null or\
	tag_map_browser != null


func new_list() -> void:
	#if is_system_open():
		#return
	
	if prompt_save_on_new:
		unsaved_work_window = UNSAVED_WINDOW.instantiate()
		unsaved_work_window.save_data = get_save_data()
		unsaved_work_window.process_continued.connect(on_save_continue)
		unsaved_work_window.process_cancelled.connect(on_save_cancelled)
		add_child(unsaved_work_window)
	else:
		clear_all()


func on_save_continue() -> void:
	Tagger.enable_shortcuts()
	unsaved_work_window.queue_free()
	clear_all()


func on_save_cancelled() -> void:
	Tagger.enable_shortcuts()
	unsaved_work_window.queue_free()


func on_file_saved() -> void:
	prompt_save_on_new = false


func on_special_tag_activated(tag_index: int) -> void:
	if not smart_list.delete_timer.is_stopped():
		return
	Tagger.disable_shortcuts()
	var medatada: Dictionary = smart_list.get_item_metadata(tag_index)
	
	if medatada["type"] == "opt":
		special_tag_window.show_option_menu(
			smart_list.get_item_text(tag_index),
			medatada["tags"],
			tag_index)
	
	elif medatada["type"] == "nbr":
		special_tag_window.show_spinbox_menu(
			smart_list.get_item_text(tag_index),
			medatada["format"],
			tag_index,
			medatada["min"],
			medatada["max"])


func on_add_current_pressed() -> void:
	on_tag_submitted(add_tag_line_edit.text)


func on_tag_submitted(tag_text: String) -> void:
	if not prompt_save_on_new:
		prompt_save_on_new = true
	
	tag_text = tag_text.strip_edges().to_lower()
	
	var prefix_found: String = ""
	
	for prefix in Tagger.prefix_sorting:
		if tag_text.begins_with(prefix):
			prefix_found = prefix
			break
	
	if not prefix_found.is_empty():
		if prefix_recursion_protection.has(tag_text):
			return
		else:
			prefix_recursion_protection.append(tag_text)
		var prefixed_string: String = tag_text.trim_prefix(prefix_found)
		var conv_tags: Array[String] = Tagger.split_and_strip(Tagger.convert_prefix(prefix_found, prefixed_string), "|")
		for tag in conv_tags:
			on_tag_submitted(tag)
		prefix_recursion_protection.erase(tag_text)
		return
	
	var end_tag: String = Tagger.get_alias(tag_text)

	add_tag_line_edit.clear()
	
	if end_tag.is_empty() or tag_items.has_tag(end_tag):
		return

	if suggestion_list.has_item(end_tag):
		suggestion_list.delete_item(end_tag)

	var tag_metadata: Dictionary = {}
	
	if Tagger.has_tag(end_tag):
		var tag_load: Tag = Tagger.get_tag(end_tag)
		tag_metadata = Tagger.build_tag_meta(tag_load)
		
		for smart:Dictionary in tag_load.smart_tags:
			if not smart_list.has_item(smart["title"]) and not session_blacklist.has_group(smart["title"]):
				var smart_index: int = smart_list.add_item(smart["title"])
				smart_list.set_item_metadata(
						smart_index,
						smart["data"])
		
		for sugg in tag_load.suggestions:
			if not suggestion_list.has_item(sugg) and\
			not tag_items.has_tag(sugg) and\
			not session_blacklist.has_item(sugg) and\
			not Tagger.suggestion_blacklist.has(sugg):
				var suggestion_index: int = suggestion_list.add_item(sugg)
				if Tagger.has_tag(sugg):
					var _tool: String = Tagger.get_tag(sugg).tooltip
					if not _tool.is_empty():
						suggestion_list.set_item_tooltip(
							suggestion_index,
							_tool
						)
		
		var extra_suggs: Dictionary = Tagger.get_suggestions(
				Tagger.get_parents(end_tag))
		
		for suggestion in extra_suggs["suggestions"]: # Key
			if not suggestion_list.has_item(suggestion) and\
			not tag_items.has_tag(suggestion) and\
			not session_blacklist.has_item(suggestion):
				suggestion_list.add_item(suggestion)
		
		for smart_suggestion in extra_suggs["smart"]:
			if not smart_list.has_item(smart_suggestion) and not session_blacklist.has_group(smart_suggestion):
				var smart_indx: int = smart_list.add_item(smart_suggestion)
				smart_list.set_item_metadata(
						smart_indx,
						extra_suggs["smart"][smart_suggestion]["data"]
				)
	else:
		tag_metadata = Tagger.get_empty_meta(not Tagger.has_invalid_tag(end_tag))

	var tag_item: TreeItem = tag_items.add_tag(end_tag, tag_metadata)
	
	if Tagger.search_online_suggestions:
		ESixRequester.queue_job(
				Tagger.get_tag_request_url(
						end_tag,
						Tagger.E621_CATEGORY.ALL,
						"date",
						1),
				self,
				ESixRequester.JOB_TYPES.SUGGESTION)
	
	if not scroll_called: # Scrolling only once.
		scroll_called = true
		await get_tree().process_frame
		tag_items.scroll_to_item(tag_item)
		scroll_called = false


func process_response(response: Array, response_type: ESixRequester.JOB_TYPES) -> void:
	if response_type != ESixRequester.JOB_TYPES.SUGGESTION or response.is_empty():
		return
	
	if response[0]["category"] == 6 and tag_items.has_tag(response[0]["name"]):
		var relevant_item: TreeItem = tag_items.get_tag_tree(response[0]["name"])
		relevant_item.set_icon(0, load("res://textures/status/bad.png"))
		relevant_item.set_tooltip_text(0, "This is an invalid tag on e621\nConsider removing or replacing.")
		relevant_item.get_metadata(0)["valid"] = false
	
	var suggestion_array: Dictionary = ESixRequester.parse_tag_strength(
			response[0]["related_tags"])
	
	for strength in suggestion_array:
		if Tagger.suggestion_confidence <= int(strength):
			for item: String in suggestion_array[strength]:
				var tag_string: String = item.replace("_", " ")
				if not suggestion_list.has_item(tag_string) and\
				not tag_items.has_tag(tag_string) and\
				not session_blacklist.has_item(tag_string) and\
				not Tagger.suggestion_blacklist.has(tag_string):
					suggestion_list.add_item(tag_string)


func on_tag_updated(tag_name: String) -> void:
	tag_items.update_tag(tag_name)


func on_suggestion_activated(sugg_index: int) -> void:
	if not suggestion_list.delete_timer.is_stopped():
		return
	
	var tags_to_add: Array[String] = []
	var selected_indexes: Array[int] = []
	
	for index in suggestion_list.get_selected_items():
		tags_to_add.append(
				suggestion_list.get_item_text(index)
		)
		selected_indexes.append(index)
	if not selected_indexes.has(sugg_index):
		selected_indexes.append(sugg_index)
		tags_to_add.insert(
			sugg_index,
			suggestion_list.get_item_text(sugg_index))
	suggestion_list.remove_indexes(selected_indexes)
	load_tag_array(tags_to_add)


func on_template_loaded(mains: Array[String], suggs: Array[String]):
	for tag in mains:
		on_tag_submitted(tag)
	for tag in suggs:
		if not suggestion_list.has_item(tag):
			suggestion_list.add_item(tag)
	Tagger.enable_shortcuts()
	template_loader.queue_free()


func display_template_loader() -> void:
	if template_loader != null:
		return
	template_loader = TEMPLATE_LOADER.instantiate()
	template_loader.template_selected.connect(on_template_loaded)
	template_loader.create_template_pressed.connect(on_create_template_pressed)
	add_child(template_loader)


func clear_all() -> void:
	tag_items.clear_tags()
	suggestion_list.clear()
	smart_list.clear()
	final_tags.clear()
	session_blacklist.clear_blacklist()
	prompt_save_on_new = false


func get_save_data() -> Dictionary:
	var save_return: Dictionary = {
		"main": {},
		"suggs": [],
		"suggs_tooltip": [],
		"smart": {},
		"blacklist": [],
	}
	
	for main_tag:TreeItem in tag_items.get_tag_treeitems():
		var tag_text: String = main_tag.get_text(0)
		var metadata: Dictionary = main_tag.get_metadata(0)
	
		save_return["main"][tag_text] = metadata.duplicate()
	
	for sugg_tag in range(suggestion_list.item_count):
		save_return["suggs"].append(suggestion_list.get_item_text(sugg_tag))
	
	for smart_tag in range(smart_list.item_count):
		save_return["smart"][smart_list.get_item_text(smart_tag)] = smart_list.get_item_metadata(smart_tag)
	
	save_return["blacklist"].assign(session_blacklist.get_blacklist_array())
	
	return save_return


func generate_full_tags() -> void:
	var use_alts: bool = generator_toggle.use_alts()
	
	final_tags.clear()
	
	var priority_dictionary: Dictionary = {}
	var priority_numbers: Array[int] = []
	
	var final_array: Array[String] = []
	
	# We'll just add tags in bulk without worring if they are duplicate for now.
	
	var added_tags: Array[String] = tag_items.get_tag_array()
	
	for main_tag:TreeItem in tag_items.get_tag_treeitems():
		var metadata: Dictionary = main_tag.get_metadata(0)
		var tag_text: String = main_tag.get_text(0)
		
		if metadata["alt_state"] == 2 and not use_alts: # We skip the alt exclusives
			continue
		elif metadata["alt_state"] == 1 and use_alts: # We skip the main exclusives
			continue
		if not metadata["valid"] and not Tagger.include_invalid:
			continue
		
		if not priority_dictionary.has(str(metadata["priority"])):
			priority_dictionary[str(int(metadata["priority"]))] = []
			priority_numbers.append(int(metadata["priority"]))
		
		priority_dictionary[str(metadata["priority"])].append(tag_text)
		
		# Get all the connected parents to this tag
		var parents: Dictionary = Tagger.get_prioritized_parents(tag_text)
		#print(priority_dictionary)
		
		for prio in parents: # Prio is a int as string
			for parent_tag in parents[prio]:
				if added_tags.has(parent_tag): # If we added it don't include it
					continue
				
				if not priority_dictionary.has(prio):
					priority_dictionary[prio] = []
					priority_numbers.append(int(prio))
				
				if not priority_dictionary[prio].has(parent_tag):
					priority_dictionary[prio].append(parent_tag)
				
			#priority_dictionary[prio].append_array(parents[prio])
	
	priority_numbers.sort_custom(func(a, b): return b < a)
	
	var selected_site_key: String = sites_option_menu.get_selected_site_key()
	var whitespace: String = Tagger.loaded_sites[selected_site_key]["whitespace"]
	
	for priority in priority_numbers:
		for tag:String in priority_dictionary[str(priority)]:
			var format_tag: String = tag.replace(" ", whitespace)
			if not final_array.has(format_tag):
				final_array.append(format_tag)
	
	for constant in Tagger.constant_tags:
		var format_tag: String = constant.replace(" ", whitespace)
		if not final_array.has(format_tag):
			final_array.append(format_tag)
	
	final_tags.text = Tagger.loaded_sites[selected_site_key]["separator"].join(final_array)


func on_copy_pressed() -> void:
	DisplayServer.clipboard_set(final_tags.text)


func on_export_pressed() -> void:
	if final_tags.text.is_empty():
		return
	if export_file_dialog.current_file.is_empty():
		export_file_dialog.current_file = "new_tag_list.txt"
	export_file_dialog.show()


func on_save_dialog_ok(file_path: String) -> void:
	if not file_path.ends_with(".txt"):
		file_path += ".txt"
	
	var export_file := FileAccess.open(file_path, FileAccess.WRITE)
	
	if export_file == null:
		return
	
	export_file.store_string(final_tags.text)
	export_file.close()


func is_saving() -> bool:
	return save_window != null or unsaved_work_window != null


func reset_tag_data() -> void:
	Tagger.disable_shortcuts()
	var reset_warning: TaggerConfirmationDialog = Tagger.create_confirmation_dialog()
	reset_warning.set_data(
			"Reset all custom data?",
			"This will reset all custom data\nfrom your current tag list.\nProceed?",
			"Reset Data",
			"Cancel")
	reset_warning.visible = true
	var confirmed: bool = await reset_warning.dialog_confirmed
	if confirmed:
		tag_items.reset_all_tags()
	reset_warning.visible = false
	reset_warning.queue_free()
	Tagger.enable_shortcuts()
	prompt_save_on_new = true


func on_full_search_closed() -> void:
	add_tag_line_edit.grab_focus()
	add_tag_line_edit.caret_column = add_tag_line_edit.text.length()


func sort_tags_by_priority() -> void:
	tag_items.sort_tags_by_priority()


func collapse_tags() -> void:
	tag_items.collapse_all_tags()


func on_main_list_changed():
	prompt_save_on_new = true

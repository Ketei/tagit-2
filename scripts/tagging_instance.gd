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

var template_loader: TemplateLoader
var save_window: SaveWindow
var tag_importer: TagListImporter
var tag_wizard: WizardInstance
var in_tag_editor: InTagEditor
var tag_map_browser: TagMapBrowser
var unsaved_work_window: UnsavedWorkWindow


@onready var sites_option_menu = $MarginContainer/MainContainer/Final/Platform/SitesOptionMenu
@onready var final_tags: TextEdit = $MarginContainer/MainContainer/Final/FinalTags

@onready var tag_items: TagItemList = $MarginContainer/MainContainer/MainTags/TagItems
@onready var suggestion_list: TagItemList = $MarginContainer/MainContainer/Suggests/SuggestionList
@onready var smart_list: TagItemList = $MarginContainer/MainContainer/Suggests/SmartList

#@onready var auto_fill: ItemList = $MarginContainer/MainContainer/MainTags/Interact/AddTag/VBoxContainer/AutoFill

@onready var add_tag_line_edit: LineEdit = $MarginContainer/MainContainer/MainTags/Interact/AutoSearch

@onready var full_search_button: Button = $MarginContainer/MainContainer/MainTags/Interact/FullSearchButton
@onready var select_tag_button: Button = $MarginContainer/MainContainer/MainTags/Interact/SelectTagButton
@onready var add_current_button: Button = $MarginContainer/MainContainer/MainTags/Interact/AddButton
@onready var generate_button: Button = $MarginContainer/MainContainer/Final/Buttons/GenerateButton
@onready var export_button: Button = $MarginContainer/MainContainer/Final/Buttons/ExtraOptions/ExportButton
@onready var copy_button: Button = $MarginContainer/MainContainer/Final/Buttons/ExtraOptions/CopyButton
@onready var template_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/TemplateButton
@onready var load_tag_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/LoadTagButton
@onready var wizard_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/WizardButton
@onready var new_list_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/NewListButton
@onready var save_list_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/SaveListButton
@onready var load_list_button: Button = $MarginContainer/MainContainer/MainTags/HBoxContainer/LoadListButton


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
	tag_items.item_activated.connect(on_item_activated)
	select_tag_button.pressed.connect(on_tag_map_open)
	tag_full_search.add_selected_pressed.connect(load_tag_array)
	full_search_button.pressed.connect(on_full_search_open)
	new_list_button.pressed.connect(new_list)
	save_list_button.pressed.connect(open_save_window)
	load_list_button.pressed.connect(open_load_window)
	Tagger.tag_updated.connect(on_tag_updated)


func on_special_submitted(tag_string: String) -> void:
	on_tag_submitted(tag_string)
	if Tagger.remove_after_use:
		smart_list.remove_item(special_tag_window.selected_index)
		if Tagger.blacklist_after_remove:
			session_blacklist.add_to_group_blacklist(special_tag_window.title_label.text)
	Tagger.shortcuts_disabled = false


func on_multiple_special_submitted(tag_array: Array[String]) -> void:
	load_tag_array(tag_array)
	if Tagger.remove_after_use:
		smart_list.remove_item(special_tag_window.selected_index)
		if Tagger.blacklist_after_remove:
			session_blacklist.add_to_group_blacklist(special_tag_window.title_label.text)
	Tagger.shortcuts_disabled = false


func sort_tags_alphabetically() -> void:
	tag_items.sort_items_by_text()


func on_full_search_open() -> void:
	tag_full_search.show_searcher()


func on_tag_map_open() -> void:
	if tag_map_browser != null:
		return
	
	Tagger.shortcuts_disabled = true
	tag_map_browser = TAG_MAP_BROWSER.instantiate()
	tag_map_browser.tag_selected.connect(on_map_selected)
	add_child(tag_map_browser)
	select_tag_button.release_focus()


func on_map_selected(tag_to_add: String) -> void:
	if tag_to_add.is_empty():
		return
	on_tag_submitted(tag_to_add)


func summon_wizard() -> void:
	Tagger.shortcuts_disabled = true
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
		if not tag_items.has_item(sugg) and not suggestion_list.has_item(sugg):
			suggestion_list.add_item(sugg)
	
	Tagger.search_online_suggestions = _online_suggs
	Tagger.shortcuts_disabled = false
	tag_wizard.close_wizard()


func on_item_activated(item_index: int) -> void:
	if in_tag_editor != null:
		return
	Tagger.shortcuts_disabled = true
	in_tag_editor = IN_TAG_EDITOR.instantiate()
	in_tag_editor.done_editing.connect(on_tag_edited)
	in_tag_editor.add_suggestions.connect(on_intag_suggestions)
	in_tag_editor.go_to_fetch.connect(on_go_to_fetch_pressed)
	add_child(in_tag_editor)
	in_tag_editor.set_data_and_show(
			item_index,
			tag_items.get_item_text(item_index),
			tag_items.get_item_metadata(item_index))


func on_intag_suggestions(suggs:Array[String]) -> void:
	for sug_to_tag in suggs:
		on_tag_submitted(sug_to_tag)


func on_tag_edited(tag_index: int, tag_data: Dictionary) -> void:
	var tag_name: String = tag_items.get_item_text(tag_index)
	
	tag_items.get_item_metadata(tag_index).merge(tag_data, true)
	
	if Tagger.has_tag(tag_name):
		tag_items.set_item_icon(
				tag_index,
				load("res://textures/status/valid_custom.png"))
	elif Tagger.has_invalid_tag(tag_name):
		tag_items.set_item_icon(
				tag_index,
				load("res://textures/status/bad_custom.png"))
	else:
		tag_items.set_item_icon(
				tag_index,
				load("res://textures/status/generic_custom.png"))
	Tagger.shortcuts_disabled = false
	#in_tag_editor.queue_free()


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
	tag_items.clear()


func open_session_blacklist() -> void:
	session_blacklist.show_blacklist()


func open_load_window() -> void:
	if save_window != null:
		return
	Tagger.shortcuts_disabled = true
	if load_list_button.has_focus():
		load_list_button.release_focus()
	save_window = SAVE_WINDOW.instantiate()
	save_window.mode = 1
	save_window.file_loaded.connect(on_load_pressed)
	add_child(save_window)
	

func on_load_pressed(load_data: Dictionary) -> void:
	clear_all()
	
	var _load_sugg: bool = Tagger.search_online_suggestions
	
	Tagger.search_online_suggestions = false
	
	for main_tag in load_data["main"]:
		#on_tag_submitted(main_tag)	
		var tag_index: int = tag_items.add_item(main_tag)
		tag_items.set_item_metadata(tag_index, load_data["main"][main_tag])
		
		if load_data["main"][main_tag]["valid"]:
			if Tagger.has_tag(main_tag):
				tag_items.set_item_icon(
						tag_index,
						load("res://textures/status/valid_custom.png"))
			else:
				tag_items.set_item_icon(
						tag_index,
						load("res://textures/status/generic_custom.png"))
		else:
			tag_items.set_item_icon(tag_index, load("res://textures/status/bad_custom.png"))
	for suggestion in load_data["suggs"]:
		suggestion_list.add_item(suggestion)
	for smart in load_data["smart"]:
		var smart_index: int = smart_list.add_item(smart)
		smart_list.set_item_metadata(
				smart_index,
				load_data["smart"][smart])
	for black in load_data["blacklist"]:
		session_blacklist.add_to_blacklist(black)
	save_window.close_window()
	
	Tagger.search_online_suggestions = _load_sugg


func open_save_window() -> void:
	if save_window != null:
		return
	Tagger.shortcuts_disabled = true
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
	Tagger.shortcuts_disabled = false
	unsaved_work_window.queue_free()
	clear_all()


func on_save_cancelled() -> void:
	Tagger.shortcuts_disabled = false
	unsaved_work_window.queue_free()


func on_file_saved() -> void:
	prompt_save_on_new = false


func on_special_tag_activated(tag_index: int) -> void:
	if not smart_list.delete_timer.is_stopped():
		return
	Tagger.shortcuts_disabled = true
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
		tag_text = Tagger.convert_prefix(
			prefix_found, 
			tag_text.trim_prefix(prefix_found))
	
	var end_tag: String = Tagger.get_alias(tag_text)

	add_tag_line_edit.clear()
	
	if end_tag.is_empty() or tag_items.has_item(end_tag):
		return

	if suggestion_list.has_item(end_tag):
		suggestion_list.delete_item(end_tag)
	
	var item_index: int = tag_items.add_item(end_tag)
	var status_icon: String = "res://textures/status/generic.png"
	
	if Tagger.has_tag(end_tag):
		status_icon = "res://textures/status/valid.png"
		var tag_load: Tag = Tagger.get_tag(end_tag)
		
		tag_items.set_item_metadata(
				item_index,
				Tagger.build_tag_meta(tag_load))
		
		tag_items.set_item_tooltip(
				item_index,
				tag_load.tooltip)
		
		for smart:Dictionary in tag_load.smart_tags:
			if not smart_list.has_item(smart["title"]) and not session_blacklist.has_group(smart["title"]):
				var smart_index: int = smart_list.add_item(smart["title"])
				smart_list.set_item_metadata(
						smart_index,
						smart["data"])
		
		for sugg in tag_load.suggestions:
			if not suggestion_list.has_item(sugg) and\
			not tag_items.has_item(sugg) and\
			not session_blacklist.has_item(sugg) and\
			not Tagger.suggestion_blacklist.has(sugg):
				suggestion_list.add_item(sugg)
		
		var extra_suggs: Dictionary = Tagger.get_suggestions(
				Tagger.get_parents(end_tag))
		
		for suggestion in extra_suggs["suggestions"]: # Key
			if not suggestion_list.has_item(suggestion) and\
			not tag_items.has_item(suggestion) and\
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
		if Tagger.invalid_tags.has(end_tag):
			status_icon = "res://textures/status/bad.png"
			tag_items.set_item_tooltip(
					item_index,
					"This is an invalid tag")
			tag_items.set_item_metadata(
				item_index,
				Tagger.get_empty_meta(false))
		else:
			tag_items.set_item_metadata(
				item_index,
				Tagger.get_empty_meta())
	
	tag_items.set_item_icon(
			item_index,
			load(status_icon))
	
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
		tag_items.get_v_scroll_bar().value = tag_items.get_v_scroll_bar().max_value
		scroll_called = false


func process_response(response: Array, response_type: ESixRequester.JOB_TYPES) -> void:
	if response_type != ESixRequester.JOB_TYPES.SUGGESTION or response.is_empty():
		return
	
	if response[0]["category"] == 6 and tag_items.has_item(response[0]["name"]):
		var item_index: int = tag_items.get_item_index(response[0]["name"])
		tag_items.set_item_icon(
				item_index,
				load("res://textures/status/bad.png"))
		tag_items.set_item_tooltip(
				item_index,
				"This is an invalid tag on e621\nConsider removing or replacing.")
		tag_items.get_item_metadata(item_index)["valid"] = false
		#return
	
	var suggestion_array: Dictionary = ESixRequester.parse_tag_strength(
			response[0]["related_tags"])
	
	for strength in suggestion_array:
		if Tagger.suggestion_confidence <= int(strength):
			for item: String in suggestion_array[strength]:
				var tag_string: String = item.replace("_", " ")
				if not suggestion_list.has_item(tag_string) and\
				not tag_items.has_item(tag_string) and\
				not session_blacklist.has_item(tag_string) and\
				not Tagger.suggestion_blacklist.has(tag_string):
					suggestion_list.add_item(tag_string)


func on_tag_updated(tag_name: String) -> void:
	var item_index: int = tag_items.get_item_index(tag_name)
	
	if item_index == -1:
		return
	
	tag_items.set_item_metadata(
			item_index,
			Tagger.build_tag_meta(Tagger.get_tag(tag_name)))
	
	if Tagger.has_tag(tag_name):
		tag_items.set_item_icon(
				item_index,
				load("res://textures/status/valid.png"))
		for suggestion in Tagger.get_tag(tag_name).suggestions:
			if not suggestion_list.has_item(suggestion) and\
			not tag_items.has_item(suggestion) and\
			not session_blacklist.has_item(suggestion):
				suggestion_list.add_item(suggestion)
	else:
		tag_items.set_item_icon(
				item_index,
				load("res://textures/status/generic.png"))


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
	Tagger.shortcuts_disabled = false
	template_loader.queue_free()


func display_template_loader() -> void:
	if template_loader != null:
		return
	Tagger.shortcuts_disabled = true
	template_loader = TEMPLATE_LOADER.instantiate()
	template_loader.template_selected.connect(on_template_loaded)
	template_loader.create_template_pressed.connect(on_create_template_pressed)
	add_child(template_loader)


func clear_all() -> void:
	tag_items.clear()
	suggestion_list.clear()
	smart_list.clear()
	final_tags.clear()
	session_blacklist.clear_blacklist()
	prompt_save_on_new = false


func get_save_data() -> Dictionary:
	var save_return: Dictionary = {
		"main": {},
		"suggs": [],
		"smart": {},
		"blacklist": []
	}
	
	for main_tag in range(tag_items.item_count):
		#save_return["main"].append(tag_items.get_item_text(main_tag))
		save_return["main"][tag_items.get_item_text(main_tag)] = tag_items.get_item_metadata(main_tag)
	
	for sugg_tag in range(suggestion_list.item_count):
		save_return["suggs"].append(suggestion_list.get_item_text(sugg_tag))
	
	for smart_tag in range(smart_list.item_count):
		save_return["smart"][smart_list.get_item_text(smart_tag)] = smart_list.get_item_metadata(smart_tag)
	
	save_return["blacklist"].assign(session_blacklist.get_blacklist_array())
	
	return save_return


func generate_full_tags() -> void:
	final_tags.clear()
	
	var priority_dictionary: Dictionary = {}
	var priority_numbers: Array[int] = []
	
	var final_array: Array[String] = []
	
	# We'll just add tags in bulk without worring if they are duplicate for now.
	for main_tag in range(tag_items.item_count):
		var metadata: Dictionary = tag_items.get_item_metadata(main_tag)
		
		if not metadata["valid"] and not Tagger.include_invalid:
			continue
		
		if not priority_dictionary.has(str(metadata["priority"])):
			priority_dictionary[str(int(metadata["priority"]))] = []
			priority_numbers.append(int(metadata["priority"]))
		
		priority_dictionary[str(metadata["priority"])].append(
				tag_items.get_item_text(main_tag))
		
		# Get all the connected parents to this tag
		var parents: Dictionary = Tagger.get_prioritized_parents(tag_items.get_item_text(main_tag))
		
		for prio in parents: # Prio is a int as string
			if not priority_dictionary.has(prio):
				priority_dictionary[prio] = []
				priority_numbers.append(int(prio))
			priority_dictionary[prio].append_array(parents[prio])
	
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




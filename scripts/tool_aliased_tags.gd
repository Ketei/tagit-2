extends Control


const TAG_ALIAS_INSTANCE = preload("res://scenes/tag_alias_instance.tscn")

var search_results: Array[TagAliasInstance] = []

@onready var alias_container: HFlowContainer = $VBoxContainer/SmoothScrollContainer/AliasFlowContainer

@onready var search_line_edit: LineEdit = $VBoxContainer/SearchContainer/SearchLineEdit
@onready var search_alias_button: Button = $VBoxContainer/SearchContainer/SearchAliasButton

@onready var create_alias_button: Button = $VBoxContainer/HBoxContainer/CreateAliasButton

@onready var from_alias_line_edit: LineEdit = $VBoxContainer/HBoxContainer/HBoxContainer/FromAliasLineEdit
@onready var to_alias_line_edit: LineEdit = $VBoxContainer/HBoxContainer/HBoxContainer/ToAliasLineEdit

@onready var searching_label: Label = $VBoxContainer/SearchContainer/SearchFilters/SearchingLabel
@onready var clear_search_button: Button = $VBoxContainer/SearchContainer/SearchFilters/ClearSearchButton

@onready var custom_only_check_button: CheckButton = $VBoxContainer/SearchContainer/CustomOnlyCheckButton

#@onready var reload_tag_button: Button = $"../../LeftSettings/ButtonsContainer/VBoxContainer/ReloadTagButton"

func _ready():
	search_alias_button.pressed.connect(on_search_pressed)
	search_line_edit.text_submitted.connect(on_search_submitted)
	create_alias_button.pressed.connect(on_create_alias_pressed)
	clear_search_button.pressed.connect(on_search_filter_cleared)
	from_alias_line_edit.text_submitted.connect(text_alias_submitted)
	to_alias_line_edit.text_submitted.connect(text_alias_submitted)
	Tagger.tag_updated.connect(on_tag_updated)
	Tagger.aliases_reloaded.connect(reload_aliases)	
	custom_only_check_button.toggled.connect(on_custom_only_toggled)
	
	for c_index in Tagger.custom_aliases:
		for c_alias in Tagger.custom_aliases[c_index]:
			load_alias(c_alias, Tagger.custom_aliases[c_index][c_alias], true)
	for index in Tagger._loaded_aliases:
		for alias in Tagger._loaded_aliases[index]:
			load_alias(alias, Tagger._loaded_aliases[index][alias])
	for char_index in Tagger.removed_aliases:
		for alias in Tagger.removed_aliases[char_index]:
			set_alias_deleted(alias, Tagger.removed_aliases[char_index][alias])


func reload_aliases() -> void:
	Tagger.log_message(
			"Reloading aliases",
			Tagger.LoggingLevel.NORMAL
	)
	for child:TagAliasInstance in alias_container.get_children():
		child.queue_free()
	
	while 0 < alias_container.get_child_count():
		await get_tree().process_frame
	
	for c_index in Tagger.custom_aliases:
		for c_alias in Tagger.custom_aliases[c_index]:
			load_alias(c_alias, Tagger.custom_aliases[c_index][c_alias], true)
	
	for index in Tagger._loaded_aliases:
		for alias in Tagger._loaded_aliases[index]:
			load_alias(alias, Tagger._loaded_aliases[index][alias])
	
	for char_index in Tagger.removed_aliases:
		for alias in Tagger.removed_aliases[char_index]:
			set_alias_deleted(alias, Tagger.removed_aliases[char_index][alias])
	
	#reload_tag_button.disabled = false


func set_alias_deleted(from: String, to: String) -> void:
	#if Tagger.alias_list.has(from.left(1)) and\
	#Tagger.alias_list[from.left(1)].has(from) and\
	#Tagger.alias_list[from.left(1)][from] == to:
	for alias_box: TagAliasInstance in alias_container.get_children():
		if alias_box.parent_alias == to:
			alias_box.set_alias_removed(from)
			return


func add_alias(old_name: String, new_name: String, is_custom: bool = false) -> void:
	for alias_box:TagAliasInstance in alias_container.get_children():
		if alias_box.parent_alias == new_name:
			alias_box.add_alias(old_name, is_custom)
			return
	
	var _new_instance: TagAliasInstance = TAG_ALIAS_INSTANCE.instantiate()
	_new_instance.parent_alias = new_name
	alias_container.add_child(_new_instance)
	_new_instance.add_alias(old_name, is_custom)


func on_custom_only_toggled(is_toggled: bool) -> void:
	if not search_results.is_empty():
		for alias_instance in search_results:
			if is_toggled:
				alias_instance.visible = alias_instance.has_custom_alias()
			else:
				alias_instance.visible = true
	else:
		for child:TagAliasInstance in alias_container.get_children():
			if is_toggled:
				child.visible = child.has_custom_alias()
			else:
				child.visible = true


func load_alias(old_name: String, new_name: String, is_custom: bool = false) -> void:
	for alias_box:TagAliasInstance in alias_container.get_children():
		if alias_box.parent_alias == new_name:
			alias_box.add_alias_no_update(old_name, is_custom)
			return
	
	var _new_instance: TagAliasInstance = TAG_ALIAS_INSTANCE.instantiate()
	_new_instance.parent_alias = new_name
	alias_container.add_child(_new_instance)
	_new_instance.add_alias_no_update(old_name, is_custom)


func search_alias(alias_search: String) -> void:
	search_results.clear()
	if alias_search.is_empty():
		for child in alias_container.get_children():
			child.visible = true
	else:
		for alias_child:TagAliasInstance in alias_container.get_children():
			var has_alias: bool = alias_child.has_alias(alias_search)
			alias_child.visible = has_alias
			if has_alias:
				search_results.append(alias_child)


func on_search_pressed() -> void:
	on_search_submitted(search_line_edit.text)


func on_search_filter_cleared() -> void:
	searching_label.hide()
	clear_search_button.hide()
	search_results.clear()
	#for child in alias_container.get_children():
		#child.visible = true
	on_custom_only_toggled(custom_only_check_button.button_pressed)


func on_search_submitted(text_sumbit: String) -> void:
	var search_text: String = text_sumbit.strip_edges().to_lower()
	search_line_edit.clear()
	
	search_alias(search_text)
	
	if text_sumbit.is_empty():
		searching_label.hide()
		clear_search_button.hide()
	else:
		searching_label.text = search_text
		searching_label.show()
		clear_search_button.show()


func on_create_alias_pressed() -> void:
	var from_alias: String = from_alias_line_edit.text.strip_edges().to_lower()
	var to_alias: String = to_alias_line_edit.text.strip_edges().to_lower()
	
	if from_alias.is_empty() or to_alias.is_empty() or from_alias == to_alias:
		return
	
	from_alias_line_edit.clear()
	to_alias_line_edit.clear()

	if not Tagger.custom_aliases.has(from_alias.left(1)):
		Tagger.custom_aliases[from_alias.left(1)] = {}
	
	Tagger.custom_aliases[from_alias.left(1)][from_alias] = to_alias

	add_alias(from_alias, to_alias, true)


func text_alias_submitted(_ignored_text: String) -> void:
	on_create_alias_pressed()


func on_tag_updated(tag_name: String) -> void:
	var tag_load: Tag = Tagger.get_tag(tag_name)
	
	# Clear aliases and reload
	for child:TagAliasInstance in alias_container.get_children():
		if child.parent_alias != tag_name:
			continue
		child.clear_aliases()
		for new_alias in tag_load.aliases:
			child.add_alias(new_alias, false)
		break # We shouldn't keep looking if we found the alias.


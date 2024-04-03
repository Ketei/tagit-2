class_name TagAliasInstance
extends PanelContainer


var parent_alias: String = ""
#var child_alias: Array[String] = []

@onready var alias_label: Label = $MarginContainer/VBoxContainer/AliasLabel

@onready var alias_list: TagItemList = $MarginContainer/VBoxContainer/AliasList
@onready var alias_line_edit: LineEdit = $MarginContainer/VBoxContainer/InteractContainer/AliasLineEdit
@onready var add_alias_button: Button = $MarginContainer/VBoxContainer/InteractContainer/AddAliasButton


func _ready():
	alias_label.text = parent_alias
	alias_list.list_emptied.connect(queue_free)
	alias_list.alias_deleted.connect(remove_alias)
	alias_line_edit.text_submitted.connect(on_line_submitted)
	add_alias_button.pressed.connect(on_add_pressed)


func on_add_pressed() -> void:
	on_line_submitted(alias_line_edit.text)


func on_line_submitted(alias_text: String) -> void:
	alias_line_edit.clear()
	add_alias(alias_text.strip_edges().to_lower(), true)


func has_alias(alias_name: String) -> bool:
	var prefix_wildcard: bool = alias_name.begins_with(Tagger.WILDCARD_CHAR)
	var suffix_wildcard: bool = alias_name.ends_with(Tagger.WILDCARD_CHAR)
	
	if prefix_wildcard:
		alias_name = alias_name.trim_prefix("*")
	if suffix_wildcard:
		alias_name = alias_name.trim_suffix("*")
	
	var tag_array:Array[String] = alias_list.get_tag_array()
	
	if prefix_wildcard and suffix_wildcard:
		if parent_alias.contains(alias_name):
			return true
		for child in tag_array:
			if child.contains(alias_name):
				return true
		return false
	elif prefix_wildcard:
		if parent_alias.ends_with(alias_name):
			return true
		for child in tag_array:
			if child.ends_with(alias_name):
				return true
		return false
	else:
		if parent_alias.begins_with(alias_name):
			return true
		for child in tag_array:
			if child.begins_with(alias_name):
				return true
		return false


func remove_alias(deleted_alias: String, is_custom: bool) -> void:
	#child_alias.erase(deleted_alias)
	
	Tagger.alias_list[deleted_alias.left(1)].erase(deleted_alias)
	if Tagger.alias_list[deleted_alias.left(1)].is_empty():
		Tagger.alias_list.erase(deleted_alias.left(1))
	
	if is_custom:
		Tagger.custom_aliases[deleted_alias.left(1)].erase(deleted_alias)
		if Tagger.custom_aliases[deleted_alias.left(1)].is_empty():
			Tagger.custom_aliases.erase(deleted_alias.left(1))


func add_alias(new_alias: String, is_custom: bool) -> void:
	if alias_list.has_item(new_alias):# If the alias exists
		if is_custom: # And is custom
			var alias_index: int = alias_list.get_item_index(new_alias)
			# If current item is not custom. Make it
			if not alias_list.get_item_metadata(alias_index):
				if not Tagger.custom_aliases.has(new_alias.left(1)):
					Tagger.custom_aliases[new_alias.left(1)] = {}
				Tagger.custom_aliases[new_alias.left(1)][new_alias] = parent_alias
				alias_list.set_item_icon(
						alias_index,
						load("res://textures/status/loaded.png"))
				alias_list.set_item_metadata(
						alias_index,
						true)
		return # Since alias exists, we do nothing else.
	
	#child_alias.append(new_alias)
	
	var item_index: int = alias_list.add_item(new_alias)
	
	if not Tagger.alias_list.has(new_alias.left(1)):
		Tagger.alias_list[new_alias.left(1)] = {}
	Tagger.alias_list[new_alias.left(1)][new_alias] = parent_alias
	
	if is_custom:
		if not Tagger.custom_aliases.has(new_alias.left(1)):
			Tagger.custom_aliases[new_alias.left(1)] = {}
		Tagger.custom_aliases[new_alias.left(1)][new_alias] = parent_alias
		
		alias_list.set_item_icon(
			item_index,
			load("res://textures/status/loaded.png"))
		alias_list.set_item_metadata(
				item_index,
				true)
	else:
		alias_list.set_item_metadata(
				item_index,
				false)


func add_alias_no_update(new_alias: String, is_custom: bool) -> void:
	if alias_list.has_item(new_alias):
		return
	
	var item_index: int = alias_list.add_item(new_alias)
	
	if is_custom:
		alias_list.set_item_icon(
			item_index,
			load("res://textures/status/loaded.png"))
		alias_list.set_item_metadata(
				item_index,
				true)
	else:
		alias_list.set_item_metadata(
				item_index,
				false)


func has_custom_alias() -> bool:
	for index in range(alias_list.item_count):
		if alias_list.get_item_metadata(index):
			return true
	return false


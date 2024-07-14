class_name TagAliasInstance
extends PanelContainer


var parent_alias: String = ""
#var child_alias: Array[String] = []

@onready var alias_label: Label = $MarginContainer/VBoxContainer/AliasLabel

@onready var alias_list: AliasItemList = $MarginContainer/VBoxContainer/AliasList
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
	
	elif suffix_wildcard:
		if parent_alias.begins_with(alias_name):
			return true
		for child in tag_array:
			if child.begins_with(alias_name):
				return true
		return false
		
	else:
		if parent_alias == alias_name:
			return true
		for child in tag_array:
			if child == alias_name:
				return true
		return false


func remove_alias(deleted_alias: String, is_custom: bool, is_remove: bool, item_index: int) -> void:
	#child_alias.erase(deleted_alias)
	if is_remove:
		print("Is remove")
		Tagger.remove_from_removed_aliases(deleted_alias, parent_alias)
		if Tagger.has_custom_alias(deleted_alias):
			alias_list.set_item_removed(item_index, false)
			alias_list.set_item_custom(item_index)
		else:
			alias_list.set_item_normal(item_index)
	elif is_custom:
		Tagger.remove_from_custom_aliases(deleted_alias)
		if Tagger.has_load_alias(deleted_alias):
			print(Tagger._loaded_aliases)
			alias_list.set_item_normal(item_index)
		else:
			alias_list.remove_item(item_index)
	else:
		Tagger.add_to_removed_aliases(deleted_alias, parent_alias)
		alias_list.set_item_removed(item_index)


func add_alias(new_alias: String, is_custom: bool) -> void:
	if alias_list.has_item(new_alias):# If the alias exists
		if is_custom: # And is custom
			var alias_index: int = alias_list.get_item_index(new_alias)
			#var item_metadata: Dictionary = alias_list.get_item_metadata(alias_index)
			# If current item is not custom. Make it
			if not alias_list.get_item_metadata(alias_index):
				Tagger.add_to_custom_aliases(new_alias, parent_alias)
				alias_list.set_item_custom(alias_index)
		return # Since alias exists, we do nothing else.
	
	var item_index: int = alias_list.add_item(new_alias)
	
	alias_list.set_item_metadata(
			item_index,
			{"custom": false, "remove": false})
	
	Tagger.add_alias(new_alias, parent_alias)
	
	#if Tagger.has_removed_alias(new_alias, parent_alias):
		#alias_list.set_item_removed(item_index)
	var was_removed: bool = Tagger.has_removed_alias(new_alias, parent_alias)
	if is_custom:
		Tagger.add_to_custom_aliases(new_alias, parent_alias)
		#if not Tagger.custom_aliases.has(new_alias.left(1)):
			#Tagger.custom_aliases[new_alias.left(1)] = {}
		#Tagger.custom_aliases[new_alias.left(1)][new_alias] = parent_alias
		alias_list.set_item_custom(item_index)
		if was_removed:
			Tagger.remove_from_removed_aliases(new_alias, parent_alias)
	else:
		if was_removed:
			alias_list.set_item_removed(item_index)


func add_alias_no_update(new_alias: String, is_custom: bool) -> void:
	if alias_list.has_item(new_alias):
		return
	
	var item_index: int = alias_list.add_item(new_alias)
	
	alias_list.set_item_metadata(
			item_index,
			{"custom": false, "remove": false})
	
	if is_custom:
		alias_list.set_item_custom(item_index)


func set_alias_removed(alias_name: String) -> void:
	var alias_index: int = alias_list.get_item_index(alias_name)
	if alias_index == -1:
		return
	alias_list.set_item_removed(alias_index)


func has_custom_alias() -> bool:
	for index in range(alias_list.item_count):
		var item_metadata: Dictionary = alias_list.get_item_metadata(index)
		if item_metadata["custom"] or item_metadata["remove"]:
			return true
	return false


func clear_aliases() -> void:
	for alias in alias_list.get_tag_array():
		Tagger.remove_alias(alias)
	alias_list.clear()


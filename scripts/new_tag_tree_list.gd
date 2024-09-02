class_name TagTreeList
extends Tree

signal list_changed
signal tag_activated(tag_treeitem: TreeItem)
signal wiki_tag_pressed(tag: String)

const DELETE_ID: int = 0
const RESET_DATA_ID: int = 1
const WIKI_ID: int = 2
const ALT_LIST_ID: int = 3

var tag_root: TreeItem


func _ready() -> void:
	tag_root = create_item()
	tag_root.set_text(0, "Tags")
	button_clicked.connect(on_tree_button_clicked)
	focus_exited.connect(_on_focus_lost)
	item_activated.connect(on_item_activated)
	#add_tag("ketei (character)", Tagger.build_tag_meta(Tagger.get_tag("ketei (character)")))
	#add_tag("Second Tag", Tagger.get_empty_meta(false))
	#add_tag("cum", Tagger.build_tag_meta(Tagger.get_tag("cum")))


func _gui_input(_event: InputEvent) -> void:
	if has_focus():
		if Input.is_action_just_pressed("ui_end"):
			release_focus()
		if Input.is_action_just_pressed("tag_delete"):
			delete_selected()
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed("set_alt_all"):
			set_alt_selected(0)
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed("set_alt_main"):
			set_alt_selected(1)
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed("set_alt_alt"):
			set_alt_selected(2)
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed("deselect_all_tags"):
			deselect_all()
			get_viewport().set_input_as_handled()


func delete_selected() -> void:
	var children: Array[TreeItem] = tag_root.get_children()
	var emit_change: bool = not children.is_empty()
	for child in children:
		if child.is_selected(0):
			child.free()
	if emit_change:
		list_changed.emit()


func set_alt_selected(alt_state: int) -> void:
	var children: Array[TreeItem] = tag_root.get_children()
	var emit_change: bool = not children.is_empty()
	for child in children:
		if child.is_selected(0):
			set_item_alt(child, alt_state)
	if emit_change:
		list_changed.emit()


func add_tag(tag_name: String, metadata: Dictionary, has_custom := false) -> TreeItem:
	var new_tag: TreeItem = create_item(tag_root)
	
	new_tag.set_text(0, tag_name)
	new_tag.set_metadata(0, metadata)
	
	if not metadata["valid"]:
		new_tag.set_icon(0, load("res://textures/status/bad.png"))
	elif Tagger.has_tag(tag_name):
		new_tag.set_icon(0, load("res://textures/status/valid.png"))
	else:
		new_tag.set_icon(0, load("res://textures/status/generic.png"))
	
	new_tag.add_button(0, get_list_texture(metadata["alt_state"]), ALT_LIST_ID, false, get_list_tooltip(metadata["alt_state"]))
	new_tag.add_button(0, load("res://textures/icons/wiki_icon_m.svg"), WIKI_ID, not Tagger.has_tag(tag_name), "Wiki")
	new_tag.add_button(0, load("res://textures/icons/reset_icon_m.svg"), RESET_DATA_ID, not has_custom, "Reset Tag")
	new_tag.add_button(0, load("res://textures/icons/x_icon_m.svg"), DELETE_ID, false, "Delete")
	
	if not metadata["tooltip"].is_empty():
		new_tag.set_tooltip_text(0, metadata["tooltip"])
	for parent in metadata["parents"]:
		var parent_tag: TreeItem = new_tag.create_child()
		parent_tag.set_text(0, parent)
		parent_tag.add_button(0, load("res://textures/icons/wiki_icon_m.svg"), WIKI_ID, not Tagger.has_tag(parent))
		#parent_tag.set_selectable(0, false)
	new_tag.collapsed = true
	
	list_changed.emit()
	return new_tag


func set_item_alt(item: TreeItem, alt_state: int) -> void:
	var metadata = item.get_metadata(0)
	var button_idx: int = item.get_button_by_id(0, ALT_LIST_ID)

	metadata["alt_state"] = alt_state % 3
	item.set_button(0, button_idx, get_list_texture(metadata["alt_state"]))
	item.set_button_tooltip_text(0, button_idx, get_list_tooltip(metadata["alt_state"]))


func has_tag(tag_text: String) -> bool:
	var next_item: TreeItem = tag_root.get_first_child()
	while next_item != null:
		if next_item.get_text(0) == tag_text:
			return true
		next_item = next_item.get_next()
	return false


func delete_tag(tag_text: String) -> void:
	var next_item: TreeItem = tag_root.get_first_child()
	
	while next_item != null:
		if next_item.get_text(0) == tag_text:
			next_item.free()
			list_changed.emit()
			break
		next_item = next_item.get_next()


func get_tag_array() -> Array[String]:
	var return_array: Array[String] = []
	var next_item: TreeItem = tag_root.get_first_child()
	while next_item != null:
		return_array.append(next_item.get_text(0))
		next_item = next_item.get_next()
	return return_array


func reset_all_tags() -> void:
	var tag_memory: Dictionary = {}
	var tag_metadata: Dictionary = {}
	
	var tags: Array[TreeItem] = tag_root.get_children()
	
	for tag_child in tags:
		tag_metadata = tag_child.get_metadata(0)
		
		if Tagger.has_invalid_tag(tag_child.get_text(0)):
			
			tag_memory = Tagger.get_empty_meta(false)
			
			for category in tag_metadata:
				if category == "alt_state":
					continue
				tag_metadata[category] = tag_memory[category]
			tag_child.set_icon(0, load("res://textures/status/bad.png"))
			tag_child.set_tooltip_text(0, "This is an invalid tag")
		
		elif Tagger.has_tag(tag_child.get_text(0)):
			tag_memory = Tagger.build_tag_meta(
					Tagger.get_tag(
							tag_child.get_text(0)))
			for category in tag_metadata:
				if category == "alt_state":
					continue
				tag_metadata[category] = tag_memory[category]
			
			tag_child.set_icon(0, load("res://textures/status/valid.png"))
			
			if not tag_memory["tooltip"].is_empty():
				tag_child.set_tooltip_text(
					0,
					tag_memory["tooltip"])
		
		else:
			tag_memory = Tagger.get_empty_meta()
			for category in tag_metadata:
				if category == "alt_state":
					continue
				tag_metadata[category] = tag_memory[category]
			tag_child.set_icon(0, load("res://textures/status/generic.png"))
		tag_child.set_button_disabled(0, tag_child.get_button_by_id(0, RESET_DATA_ID), true)


func reset_tag(tag_child: TreeItem) -> void:
	var tag_memory: Dictionary = {}
	var tag_metadata: Dictionary = tag_child.get_metadata(0)
	if Tagger.has_invalid_tag(tag_child.get_text(0)):
		
		tag_memory = Tagger.get_empty_meta(false)
		
		for category in tag_metadata:
			if category == "alt_state":
				continue
			tag_metadata[category] = tag_memory[category]
		tag_child.set_icon(0, load("res://textures/status/bad.png"))
		tag_child.set_tooltip_text(0, "This is an invalid tag")
	
	elif Tagger.has_tag(tag_child.get_text(0)):
		tag_memory = Tagger.build_tag_meta(
				Tagger.get_tag(
						tag_child.get_text(0)))
		for category in tag_metadata:
			if category == "alt_state":
				continue
			tag_metadata[category] = tag_memory[category]
		
		tag_child.set_icon(0, load("res://textures/status/valid.png"))
		
		if not tag_memory["tooltip"].is_empty():
			tag_child.set_tooltip_text(
				0,
				tag_memory["tooltip"])
	
	else:
		tag_memory = Tagger.get_empty_meta()
		for category in tag_metadata:
			if category == "alt_state":
				continue
			tag_metadata[category] = tag_memory[category]
		tag_child.set_icon(0, load("res://textures/status/generic.png"))
	tag_child.set_button_disabled(0, tag_child.get_button_by_id(0, RESET_DATA_ID), true)


func _on_focus_lost() -> void:
	deselect_all()


func on_tree_button_clicked(item: TreeItem, column: int, id: int, _mouse_button_index: int) -> void:
	if id == WIKI_ID:
		wiki_tag_pressed.emit(item.get_text(column))
	elif id == ALT_LIST_ID:
		var metadata = item.get_metadata(column)
		var button_idx: int = item.get_button_by_id(column, id)
		metadata["alt_state"] = (metadata["alt_state"] + 1) % 3
		item.set_button(column, button_idx, get_list_texture(metadata["alt_state"]))
		item.set_button_tooltip_text(column, button_idx, get_list_tooltip(metadata["alt_state"]))
	elif id == RESET_DATA_ID:
		reset_tag(item)
	elif id == DELETE_ID:
		item.free()


func on_item_activated() -> void:
	var selected_item: TreeItem = get_selected()
	if selected_item != null:
		if selected_item.get_parent() == tag_root:
			tag_activated.emit(selected_item)


func sort_tags_by_text() -> void:
	var tree_array: Array[TreeItem] = tag_root.get_children()
	if tree_array.size() < 2:
		return
	
	tree_array.sort_custom(sort_custom_treeitem_alphabetically)
	tree_array[0].move_before(tag_root.get_child(0))
	for tree_idx in range(1, tree_array.size()):
		tree_array[tree_idx].move_after(tree_array[tree_idx - 1])


func sort_tags_by_priority() -> void:
	var tree_array: Array[TreeItem] = tag_root.get_children()
	if tree_array.size() < 2:
		return
	
	tree_array.sort_custom(sort_custom_treeitem_priority)
	tree_array[0].move_before(tag_root.get_child(0))
	for tree_idx in range(1, tree_array.size()):
		tree_array[tree_idx].move_after(tree_array[tree_idx - 1])


func sort_tags_by_alt_state() -> void:
	var tree_array: Array[TreeItem] = tag_root.get_children()
	if tree_array.size() < 2:
		return
	
	tree_array.sort_custom(sort_custom_treeitem_altlist)
	tree_array[0].move_before(tag_root.get_child(0))
	for tree_idx in range(1, tree_array.size()):
		tree_array[tree_idx].move_after(tree_array[tree_idx - 1])


func get_tag_tree(tag_name: String) -> TreeItem:
	for tag_tree:TreeItem in tag_root.get_children():
		if tag_tree.get_text(0) == tag_name:
			return tag_tree
	return null


# Searches on all tags' children for this tag.
func get_tag_tree_children(tag_name: String) -> Array[TreeItem]:
	var matching_parents: Array[TreeItem] = []
	
	for tag in tag_root.get_children():
		for parent_tag in tag.get_children():
			if parent_tag.get_text(0) == tag_name:
				matching_parents.append(parent_tag)
	
	return matching_parents


func update_tag(tag_name: String) -> void:
	var relevant_tagtree: TreeItem = get_tag_tree(tag_name)
	var in_database: bool = Tagger.has_tag(tag_name)
	
	if relevant_tagtree != null:
		return
	
		var tag_metadata: Dictionary = relevant_tagtree.get_metadata(0)
		var new_metadata: Dictionary = {}
		var signal_change: bool = false
		var invalid: bool = Tagger.has_invalid_tag(tag_name)

		if in_database:
			new_metadata = Tagger.build_tag_meta(Tagger.get_tag(tag_name))
			relevant_tagtree.set_icon(0, load("res://textures/status/valid.png"))
		else:
			new_metadata = Tagger.get_empty_meta(not invalid)
			if invalid:
				relevant_tagtree.set_icon(0, load("res://textures/status/bad.png"))
			else:
				relevant_tagtree.set_icon(0, load("res://textures/status/generic.png"))
		
		for meta_key in tag_metadata:
			if meta_key == "alt_state":
				continue	
			if tag_metadata[meta_key] != new_metadata[meta_key]:
				tag_metadata[meta_key] = new_metadata[meta_key]
				if not signal_change and meta_key != "suggestions" and meta_key != "tooltip":
					signal_change = true
		
		for parent in relevant_tagtree.get_children():
			parent.free()
		
		for new_parent in tag_metadata["parents"]:
			var parent_tag: TreeItem = relevant_tagtree.create_child()
			parent_tag.set_text(0, new_parent)
			parent_tag.add_button(0, load("res://textures/icons/wiki_icon_m.svg"), WIKI_ID, not Tagger.has_tag(new_parent))
		
		relevant_tagtree.set_button_disabled(
				0,
				relevant_tagtree.get_button_by_id(0, WIKI_ID),
				not in_database)
	
		if signal_change:
			list_changed.emit()
	
	for parent in get_tag_tree_children(tag_name):
		parent.set_button_disabled(
				0,
				parent.get_button_by_id(0, WIKI_ID),
				not in_database)


func clear_tags() -> void:
	for child:TreeItem in tag_root.get_children():
		child.free()


func get_tag_treeitems() -> Array[TreeItem]:
	return tag_root.get_children()


func tag_count() -> int:
	return tag_root.get_child_count()


func collapse_all_tags() -> void:
	for tag:TreeItem in tag_root.get_children():
		if not tag.collapsed:
			tag.collapsed = true


static func sort_custom_treeitem_alphabetically(item_a: TreeItem, item_b: TreeItem) -> bool:
	return item_a.get_text(0).naturalnocasecmp_to(item_b.get_text(0)) < 0


static func sort_custom_treeitem_priority(item_a: TreeItem, item_b: TreeItem) -> bool:
	return item_b.get_metadata(0)["priority"] < item_a.get_metadata(0)["priority"]


static func sort_custom_treeitem_altlist(item_a: TreeItem, item_b: TreeItem) -> bool:
	return item_a.get_metadata(0)["alt_state"] < item_b.get_metadata(0)["alt_state"]


static func get_list_texture(state: int) -> Texture2D:
	if state == 0:
		return load("res://textures/icons/crossed_star.svg")
	elif state == 1:
		return load("res://textures/icons/white_star.svg")
	else:
		return load("res://textures/icons/full_star.svg")


static func get_list_tooltip(state: int) -> String:
	if state == 0:
		return "All lists"
	elif state == 1:
		return "Main only"
	else:
		return "Alt only"

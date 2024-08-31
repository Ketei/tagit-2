class_name TagTreeList
extends Tree

signal list_changed

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
	add_tag("ketei (character)", Tagger.build_tag_meta(Tagger.get_tag("ketei (character)")))
	add_tag("Second Tag", Tagger.get_empty_meta(false))
	add_tag("cum", Tagger.build_tag_meta(Tagger.get_tag("cum")))


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


func add_tag(tag_name: String, metadata: Dictionary, has_custom := false) -> void:
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
	new_tag.add_button(0, load("res://textures/icons/wiki_icon_m.svg"), WIKI_ID, not metadata["valid"], "Wiki")
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


func get_list_texture(state: int) -> Texture2D:
	if state == 0:
		return load("res://textures/icons/crossed_star.svg")
	elif state == 1:
		return load("res://textures/icons/white_star.svg")
	else:
		return load("res://textures/icons/full_star.svg")


func get_list_tooltip(state: int) -> String:
	if state == 0:
		return "All lists"
	elif state == 1:
		return "Main only"
	else:
		return "Alt only"


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
		print("Searching for: " + item.get_text(column))
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

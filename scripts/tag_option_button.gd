class_name TagsOptionButton
extends OptionButton

@export var max_height: int = 250
@export var elements: Array[Dictionary] = []
@export var add_none_option: bool = true
@export var none_text: String = "- Unknown | N/A -"
## Bind controls to indextes. int: node
@export var bind_indexes: Dictionary = {}
## Faster to add than regular elements
@export var better_elements: Array[String] = []


func _ready():
	var _index: int = 0
	get_popup().max_size.y = max_height
	if add_none_option:
		add_item(none_text)
		set_item_metadata(
				_index,
				[])
		_index += 1
	
	for tag_option:Dictionary in elements:
		add_item(tag_option["title"])
		set_item_metadata(
				_index,
				tag_option["include"].duplicate())
		_index += 1
	if 0 < item_count:
		select(0)
	if not bind_indexes.is_empty():
		item_selected.connect(on_selected)
		for keys in bind_indexes:
			if add_none_option:
				get_node(bind_indexes[keys]).visible = keys + 1 == selected
			else:
				get_node(bind_indexes[keys]).visible = keys == selected
	
	for option in better_elements:
		var title: String = ""
		var elements_array: Array[String] = []
		for split_element in option.split(",", false):
			var clean_element = split_element.strip_edges()
			var lower_element = clean_element.to_lower()
			if clean_element.begins_with("!"):
				title = clean_element.trim_prefix("!")
			elif not elements_array.has(lower_element):
				elements_array.append(lower_element)
		if title.is_empty() and not elements_array.is_empty():
			title = DumbUtils.title_case(elements_array[0])
		add_item(title)
		set_item_metadata(
				_index,
				elements_array.duplicate()
		)
		_index += 1
	
	elements.clear()
	better_elements.clear()


func on_selected(selected_index: int) -> void:
	if add_none_option:
		selected_index -= 1
	
	for existing_key in bind_indexes:
		if existing_key == selected_index:
			get_node(bind_indexes[existing_key]).visible = true
		else:
			get_node(bind_indexes[existing_key]).visible = false


func get_tags() -> Array[String]:
	var return_array: Array[String] = []

	for item: String in get_item_metadata(selected):
		if not item.is_empty():
			return_array.append(item)
	
	return return_array


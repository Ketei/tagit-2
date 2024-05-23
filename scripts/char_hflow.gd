class_name CharHflowContainer
extends HFlowContainer

const TYPES: Dictionary = {
	"colors": [
		"black",
		"blue",
		"brown",
		"green",
		"grey",
		"orange",
		"pink",
		"purple",
		"red",
		"tan",
		"teal",
		"white",
		"yellow",
		"rainbow,multicolored"]
}

enum Modes {
	COLOR,
	OTHER
}

## Where index 0 is the type
@export var formatting: String = ""
@export var element: String = ""
@export var mode := Modes.COLOR
@export var count_select: Dictionary = {}
@export var other_items: Array[String] = []


func _ready():
	if mode == Modes.COLOR:
		for color_item in TYPES.colors:
			var items_array: Array[String] = []
			items_array.assign(color_item.split(",", false))
			var title: String = formatting.format([items_array[0], element])
			var new_color := TagCheckBoxCharacter.new()
			new_color.title = DumbUtils.title_case(title)
			for item in items_array:
				new_color.contains.append(formatting.format([item, element]))
			new_color.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			add_child(new_color)
	elif mode == Modes.OTHER:
		for other_item in other_items:
			var separate_array: Array[String] = []
			separate_array.assign(
					other_item.split(",", false))
			var new_other := TagCheckBoxCharacter.new()
			
			for item in separate_array:
				var format_item: String = item.strip_edges()
				if format_item.begins_with("!"):
					new_other.title = DumbUtils.title_case(format_item.trim_prefix("!").strip_edges())
				else:
					new_other.contains.append(format_item)
			
			if new_other.title.is_empty() and not new_other.contains.is_empty():
				new_other.title = DumbUtils.title_case(new_other.contains[0])
			
			new_other.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			add_child(new_other)



func get_selected() -> Array[String]:
	var return_array: Array[String] = []
	var counting_index: int = 0
	
	if not visible:
		return return_array
	
	for tag_checkbox:TagCheckBoxCharacter in get_children():
		if tag_checkbox.button_pressed and not tag_checkbox.contains.is_empty():
			DumbUtils.append_without_repeats(return_array, tag_checkbox.contains)
			counting_index += 1
	
	for element_count in count_select:
		var value: String = element_count
		var or_higher: bool = value.ends_with("+")
		if or_higher:
			value = value.trim_suffix("+")
		
		if or_higher and int(value) <= counting_index:
			DumbUtils.append_without_repeats(return_array, count_select[element_count])
		elif int(value) == counting_index:
			DumbUtils.append_without_repeats(return_array, count_select[element_count])
	
	return return_array


func deselect_all() -> void:
	for item:TagCheckBoxCharacter in get_children():
		if item.button_pressed:
			item.button_pressed = false



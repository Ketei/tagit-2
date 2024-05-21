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
		"white",
		"yellow"]
}

enum Modes {
	COLOR,
	OTHER
}

## Where index 0 is the type
@export var formatting: String = ""
@export var element: String = ""
@export var mode := Modes.COLOR
@export var other_items: Array[String] = []


func _ready():
	if mode == Modes.COLOR:
		for color_item in TYPES.colors:
			var title: String = formatting.format([color_item, element])
			var new_color := TagCheckBoxCharacter.new()
			new_color.title = DumbUtils.title_case(title)
			new_color.contains.append(title)
			new_color.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			add_child(new_color)
	elif mode == Modes.OTHER:
		for other_item in other_items:
			var new_other := TagCheckBoxCharacter.new()
			new_other.title = DumbUtils.title_case(other_item)
			new_other.contains.append(other_item)
			new_other.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			add_child(new_other)



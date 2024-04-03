class_name BackgroundsContainer
extends VBoxContainer


const BACKGROUNDS: Dictionary = {
	"simple": {
		"name": "Simple",
		"tag": "simple background",
		"types": {
			"mono": {
				"name": "Single Color",
				"tag": "monotone background"
			},
			"abst": {
				"name": "Abstract",
				"tag": "abstract background"
			},
			"spiral": {
				"name": "Spiral Pattern",
				"tag": "spiral background"
			},
			"geometric": {
				"name": "Geometric Shapes",
				"tag": "geometric background"
			},
			"heart": {
				"name": "Heart Shapes",
				"tag": "heart background"
			},
			"grad": {
				"name": "Gradient",
				"tag": "gradient background"
			},
			"patt": {
				"name": "Repeating Pattern",
				"tag": "pattern background"
			},
			"dott": {
				"name": "Dots Pattern",
				"tag": "dotted background"
			},
			"stripe": {
				"name": "Stripes Pattern",
				"tag": "stripped background"
			},
			"texture": {
				"name": "Nongeometric Texture",
				"tag": "textured background"
			},
			"trans": {
				"name": "Transparent",
				"tag": "transparent background"
			},
			"other": {
				"name": "Other",
				"tag": ""
			}
		}
	},
	"detailed": {
		"name": "Detailed",
		"tag": "detailed background",
		"types": {
			"default": {
				"name": "Full Background",
				"tag": "",
			},
			"amazing": {
				"name": "Extremely Detailed",
				"tag": "amazing background"
			},
			"blurr": {
				"name": "Detailed Blurred",
				"tag": "blurred background"
			}
		}
	}
}


@onready var bg_type_options: OptionButton = $BackgroundsContainer/BGTypeOptions
@onready var bg_subtype_options: OptionButton = $BackgroundsContainer/BGSubtypeOptions

@onready var day_time: CheckBox = $ExtraButtons/TimeBox/DayTime
@onready var night_time: CheckBox = $ExtraButtons/TimeBox/NightTime
@onready var location_inside: CheckBox = $ExtraButtons/LocationBox/LocationInside
@onready var location_outside: CheckBox = $ExtraButtons/LocationBox/LocationOutside


func _ready():
	var index_counter: int = 0
	
	for type in BACKGROUNDS:
		bg_type_options.add_item(BACKGROUNDS[type]["name"])
		bg_type_options.set_item_metadata(
				index_counter,
				type)
		index_counter += 1
	bg_type_options.select(0)
	
	index_counter = 0
	for subtype	in BACKGROUNDS["simple"]["types"]:
		bg_subtype_options.add_item(
				BACKGROUNDS["simple"]["types"][subtype]["name"])
		bg_subtype_options.set_item_metadata(
				index_counter,
				BACKGROUNDS["simple"]["types"][subtype]["tag"])
		index_counter += 1
	bg_subtype_options.select(0)
	
	bg_type_options.item_selected.connect(on_type_selected)


func on_type_selected(item_index: int) -> void:
	var key: String = bg_type_options.get_item_metadata(item_index)
	
	bg_subtype_options.clear()
	var index_counter: int = 0
	for sub in BACKGROUNDS[key]["types"]:
		bg_subtype_options.add_item(
				BACKGROUNDS[key]["types"][sub]["name"])
		bg_subtype_options.set_item_metadata(
				index_counter,
				BACKGROUNDS[key]["types"][sub]["tag"])
		index_counter += 1
	bg_subtype_options.select(0)


func get_background_tags() -> Array[String]:
	var return_string: Array[String] = []
	var bg_type: String = BACKGROUNDS[
			bg_type_options.get_item_metadata(bg_type_options.selected)
			]["tag"]
	var bg_subtype: String = bg_subtype_options.get_item_metadata(
			bg_subtype_options.selected)
	
	if not bg_type.is_empty():
		return_string.append(bg_type)
	if not bg_subtype.is_empty():
		return_string.append(bg_subtype)
	if day_time.button_pressed:
		return_string.append("day")
	if night_time.button_pressed:
		return_string.append("night")
	if location_inside.button_pressed:
		return_string.append("inside")
	if location_outside.button_pressed:
		return_string.append("outside")
	
	return return_string



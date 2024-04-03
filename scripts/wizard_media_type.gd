class_name WizardMediaTypes
extends HBoxContainer


const MEDIA_TYPES: Dictionary = {
		"digital": {"name": "Digital",
			"tag": "digital media (artwork)",
			"types": {
				"digidraw": {
					"name": "Digital drawing",
					"tag": "digital drawing (artwork)"},
				"digipaint": {
					"name": "Digital painting",
					"tag": "digital painting (artwork)"},
				"pixel": {
					"name": "Pixel Artwork",
					"tag": "pixel_(artwork)"},
				"tridi": {
					"name": "3D artwork",
					"tag": "3d (artwork)"},
				"oekaki": {
					"name": "Oekaki",
					"tag": "oekaki"
				},
			}
		},
		"traditional": {"name": "Traditional artwork",
			"tag": "traditional media (artwork)",
			"types": {
				"penart": {
					"name": "Colored pencils artwork",
					"tag": "colored pencil (artwork)"},
				"markart": {
					"name": "Marker artwork",
					"tag": "marker (artwork)"},
				"crayon": {
					"name": "Crayon artwork",
					"tag": "crayon (artwork)"},
				"pastel": {
					"name": "Pastel arwork",
					"tag": "pastel (artwork)"},
				"paint": {
					"name": "Paint artwork",
					"tag": "painting (artwork)"},
				"pen": {
					"name": "Pen artwork",
					"tag": "pen (artwork)"},
				"sculpt": {
					"name": "Sculpture",
					"tag": "sculpture (artwork)"},
				"graph": {
					"name": "Graphite artwork",
					"tag": "graphite (artwork)"},
				"chalk": {
					"name": "Chalk artwork",
					"tag": "chalk (artwork)"},
				"charc": {
					"name": "Charcoal artwork",
					"tag": "charcoal (artwork)"},
				"etch": {
					"name": "Engraved artwork",
					"tag": "engraving (artwork)"},
				"air": {
					"name": "Airbrush artwork",
					"tag": "airbrush (artwork)"},
				}
			},
		"photo": {
			"name": "Photography",
			"tag": "photography (artwork)",
			"types": {}},
		"anim": {
			"name": "Animation",
			"tag": "animated",
			"types": {
				"twod": {
					"name": "2D animation",
					"tag": "2d animation"},
				"tridi": {
					"name": "3D animation",
					"tag": "3d animation"},
				"pixel": {
					"name": "Pixel animation",
					"tag": "pixel animation"
				}
			}
		}
	}

@onready var media_type_opt_btn: OptionButton = $OptionContainer/MediaTypeOptBtn
@onready var media_sub_opt_btn: OptionButton = $OptionContainer/MediaSubOptBtn


# Called when the node enters the scene tree for the first time.
func _ready():
	var index_counter: int = 0
	
	for media in MEDIA_TYPES:
		media_type_opt_btn.add_item(MEDIA_TYPES[media]["name"])
		media_type_opt_btn.set_item_metadata(
				index_counter,
				media)
		index_counter += 1
	media_type_opt_btn.select(0)
	
	index_counter = 0
	for submedia in MEDIA_TYPES["digital"]["types"]:
		media_sub_opt_btn.add_item(
				MEDIA_TYPES["digital"]["types"][submedia]["name"])
		media_sub_opt_btn.set_item_metadata(
				index_counter,
				MEDIA_TYPES["digital"]["types"][submedia]["tag"])
		index_counter += 1
	media_sub_opt_btn.select(0)
	
	media_type_opt_btn.item_selected.connect(on_media_selected)


func on_media_selected(media_index: int) -> void:
	var media_key: String = media_type_opt_btn.get_item_metadata(media_index)
	
	media_sub_opt_btn.clear()
	
	var index_counter: int = 0
	for submedia in MEDIA_TYPES[media_key]["types"]:
		media_sub_opt_btn.add_item(
				MEDIA_TYPES[media_key]["types"][submedia]["name"])
		media_sub_opt_btn.set_item_metadata(
				index_counter,
				MEDIA_TYPES[media_key]["types"][submedia]["tag"])
		index_counter += 1
	
	if 0 < media_sub_opt_btn.item_count:
		media_sub_opt_btn.select(0)
	

func get_media_tags() -> Array[String]:
	var return_array: Array[String] = []
	
	return_array.append(
			MEDIA_TYPES[
					media_type_opt_btn.get_item_metadata(
							media_type_opt_btn.selected)]
						["tag"])
	
	if 0 < media_sub_opt_btn.item_count:
		return_array.append(
				media_sub_opt_btn.get_item_metadata(
						media_sub_opt_btn.selected))
	
	return return_array




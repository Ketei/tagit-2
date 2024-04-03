class_name ClothingCheckBox
extends CheckBox

@export var clothing_title: String = ""
@export var clothing_tag: String = ""
@export var solo_tag: String = ""
@export var counts_as_clothing: bool = true
@export var clothing_score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	text = clothing_title


func get_tags(is_unique: bool) -> Array[String]:
	if is_unique:
		return [clothing_tag, solo_tag]
	else:
		return [clothing_tag]


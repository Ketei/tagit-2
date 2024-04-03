class_name CategoryOptionButton
extends OptionButton


@export var max_heigth: int = 720
@export var max_width: int = 1280

var category_order: Array[Tagger.Categories] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_popup().max_size = Vector2i(max_width, max_heigth)
	var current_index: int = 0
	for dict:Dictionary in Tagger.CategorySorting:
		category_order.append(dict["index"])
		add_item(dict["name"])
		set_item_metadata(
			current_index,
			dict["index"]
		)
		current_index += 1
	select(0)


func get_category() -> Tagger.Categories:
	return get_item_metadata(selected)


func select_category(category: Tagger.Categories) -> void:
	select(category_order.find(category))


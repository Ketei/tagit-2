class_name BodyOptionButton
extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	var index_counter: int = 0
	for body in Tagger.BODY_TYPES:
		add_item(
				Tagger.BODY_TYPES[body]["name"]
		)
		set_item_metadata(
				index_counter,
				body
		)
		index_counter += 1
	select(0)


func get_body_type() -> Array:
	return Tagger.BODY_TYPES[get_item_metadata(selected)]["tags"].duplicate()


func select_body(body_id: String) -> void:
	for item in range(item_count):
		if get_item_metadata(item) == body_id:
			select(item)
			return




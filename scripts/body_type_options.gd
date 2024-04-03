class_name BodyOptionButton
extends OptionButton


const BODY_TYPES: Dictionary = {
	"anthro": {"name": "Anthro", "tags": ["anthro"]},
	"semian": {"name": "Semi-anthro", "tags": ["anthro", "semi-anthro"]},
	"stud": {"name": "Feral", "tags": ["feral"]},
	"semife": {"name": "Semi-feral", "tags": ["feral", "semi-anthro"]},
	"hooman": {"name": "Human", "tags": ["human"]},
	"humanoid": {"name": "Humanoid", "tags": ["humanoid"]},
	"tahuff": {"name": "Taur", "tags": ["taur"]},
}



# Called when the node enters the scene tree for the first time.
func _ready():
	var index_counter: int = 0
	for body in BODY_TYPES:
		add_item(
				BODY_TYPES[body]["name"]
		)
		set_item_metadata(
				index_counter,
				BODY_TYPES[body]["tags"]
		)
		index_counter += 1
	select(0)


func get_body_type() -> Array:
	return get_item_metadata(selected)



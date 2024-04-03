class_name AgeOptionButton
extends OptionButton

const AGES: Dictionary = {
	"adult": {"name": "Adult", "tag": ""},
	"teen": {"name": "Adolescent", "tag": "adolescent"},
	"child": {"name": "Child", "tag": "child"},
	"todd": {"name": "Toddler", "tag": "toddler"},
	"bab": {"name": "Baby", "tag": "baby"}}


# Called when the node enters the scene tree for the first time.
func _ready():
	var index_counter: int = 0
	for age in AGES:
		add_item(AGES[age]["name"])
		set_item_metadata(
				index_counter,
				AGES[age]["tag"])
		index_counter += 1
	select(0)


func get_age_tag() -> String:
	return get_item_metadata(selected)


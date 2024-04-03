class_name GenderOptionButton
extends OptionButton

const GENDERS: Dictionary = {
	"male": {"name": "Male", "tag": "male"},
	"female": {"name": "Female", "tag": "female"},
	"amb": {"name": "Ambiguous", "tag": "ambiguous gender"},
	"andro": {"name": "Andromorph", "tag": "andromorph"},
	"gyno": {"name": "Gynomorph", "tag": "gynomorph"},
	"herm": {"name": "Hermaphrodite", "tag": "herm"},
	"maleherm": {"name": "Male Hermaphrodite", "tag": "maleherm"}
}


func _ready():
	var index_counter: int = 0
	for key in GENDERS:
		add_item(GENDERS[key]["name"])
		set_item_metadata(
				index_counter,
				key)
		index_counter += 1
	select(0)


func get_gender_tag() -> String:
	return GENDERS[get_item_metadata(selected)]["tag"]





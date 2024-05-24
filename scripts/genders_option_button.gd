class_name GenderOptionButton
extends OptionButton

const GENDERS: Dictionary = {
	"male": {"name": "Male", "tag": "male", "is_female": false},
	"female": {"name": "Female", "tag": "female", "is_female": true},
	"amb": {"name": "Ambiguous", "tag": "ambiguous gender", "is_female": false},
	"andro": {"name": "Andromorph", "tag": "andromorph", "is_female": false},
	"gyno": {"name": "Gynomorph", "tag": "gynomorph", "is_female": true},
	"herm": {"name": "Hermaphrodite", "tag": "herm", "is_female": true},
	"maleherm": {"name": "Male Hermaphrodite", "tag": "maleherm", "is_female": false}
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


func is_female() -> bool:
	return GENDERS[get_item_metadata(selected)]["is_female"]




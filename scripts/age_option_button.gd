class_name AgeOptionButton
extends OptionButton

var default_age: String = "adult"

enum AgeRange{
	YOUNG,
	ADULT,
	MATURE,
	OLD
}

const AGES: Dictionary = {
	"old": {"name": "Elderly", "tag": "old", "cat": AgeRange.OLD},
	"mature": {"name": "Mature", "tag": "", "cat": AgeRange.MATURE},
	"adult": {"name": "Adult", "tag": "", "cat": AgeRange.ADULT},
	"young_adult": {"name": "Young Adult", "tag": "young adult", "cat": AgeRange.ADULT},
	"teen": {"name": "Adolescent", "tag": "adolescent", "cat": AgeRange.YOUNG},
	"child": {"name": "Child", "tag": "child", "cat": AgeRange.YOUNG},
	"todd": {"name": "Toddler", "tag": "toddler", "cat": AgeRange.YOUNG},
	"bab": {"name": "Baby", "tag": "baby", "cat": AgeRange.YOUNG}}


# Called when the node enters the scene tree for the first time.
func _ready():
	var index_counter: int = 0
	var default_select: int = 0
	for age in AGES:
		add_item(AGES[age]["name"])
		set_item_metadata(
				index_counter,
				{"tag": AGES[age]["tag"], "range": AGES[age]["cat"]})
		if age == default_age:
			default_select = index_counter
		index_counter += 1
	select(default_select)


func get_age_tag() -> String:
	return get_item_metadata(selected)["tag"]


func get_age_category() -> AgeRange:
	return get_item_metadata(selected)["range"]



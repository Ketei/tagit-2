class_name AgeOptionButton
extends OptionButton

var default_age: String = "adult"
var default_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	var index_counter: int = 0
	var default_select: int = 0
	for age in Tagger.AGES:
		add_item(Tagger.AGES[age]["name"])
		set_item_metadata(
				index_counter,
				age)
		if age == default_age:
			default_select = index_counter
			default_index = index_counter
		index_counter += 1
	select(default_select)


func get_age_tag() -> String:
	return Tagger.AGES[get_item_metadata(selected)]["tag"]


func get_age_category() -> Tagger.AgeRange:
	return Tagger.AGES[get_item_metadata(selected)]["range"]


func reset_to_default() -> void:
	select(default_index)


func set_age_by_id(age_id: String) -> void:
	for index in range(item_count):
		if get_item_metadata(index) == age_id:
			select(index)
			return

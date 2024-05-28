class_name GenderOptionButton
extends OptionButton


func _ready():
	var index_counter: int = 0
	for key in Tagger.GENDERS:
		add_item(Tagger.GENDERS[key]["name"])
		set_item_metadata(
				index_counter,
				key)
		index_counter += 1
	select(0)


func get_gender_tag() -> String:
	return Tagger.GENDERS[get_item_metadata(selected)]["tag"]


func is_female() -> bool:
	return Tagger.GENDERS[get_item_metadata(selected)]["is_female"]


func set_gender_by_id(gender_id: String) -> void:
	for gender_idx in range(item_count):
		if get_item_metadata(gender_idx) == gender_id:
			select(gender_idx)
	
	

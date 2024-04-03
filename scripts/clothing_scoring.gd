class_name ClothingScoring
extends HFlowContainer


func get_tags() -> Dictionary:
	var enabled_clothing: Array[ClothingCheckBox] = []
	var return_dict: Dictionary = {"tags": [], "suggestions": []}
	var clothing_score: int = 0
	
	for clothing:ClothingCheckBox in get_children():
		if clothing.button_pressed:
			enabled_clothing.append(clothing)
			return_dict["tags"].append(clothing.clothing_tag)
			clothing_score += clothing.clothing_score
	
	if enabled_clothing.size() == 1:
		return_dict["tags"].append(enabled_clothing[0].solo_tag)
	
	if 300 <= clothing_score:
		return_dict["suggestions"].append("fully clothed")
	elif 200 <= clothing_score:
		return_dict["suggestions"].append("mostly clothed")
	elif 0 < clothing_score:
		return_dict["suggestions"].append("mostly nude")
	else:
		return_dict["tags"].append("nude")
	
	return return_dict
	
	

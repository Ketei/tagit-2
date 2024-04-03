class_name WizardCharacterInstance
extends Control

var known_character: bool = true


@onready var focus_check_box: CheckBox = $SmoothScrollContainer/MarginContainer/VBoxContainer/ExtraTags/FocusCheckBox

@onready var top_check: CheckBox = $SmoothScrollContainer/MarginContainer/VBoxContainer/ExtraTags/PositionContainer/TopCheck
@onready var bottom_check: CheckBox = $SmoothScrollContainer/MarginContainer/VBoxContainer/ExtraTags/PositionContainer/BottomCheck
@onready var dominant_check: CheckBox = $SmoothScrollContainer/MarginContainer/VBoxContainer/ExtraTags/RoleContainer/DominantCheck
@onready var submissive_check: CheckBox = $SmoothScrollContainer/MarginContainer/VBoxContainer/ExtraTags/RoleContainer/SubmissiveCheck

@onready var gender_opt: GenderOptionButton = $SmoothScrollContainer/MarginContainer/VBoxContainer/GendersContainer/GenderOpt
@onready var canon_gender: GenderOptionButton = $SmoothScrollContainer/MarginContainer/VBoxContainer/GendersContainer/CanonGender
@onready var bod_type_opt_btn: BodyOptionButton = $SmoothScrollContainer/MarginContainer/VBoxContainer/TopContainer/BodyTContainer/BodTypeOptBtn

@onready var age_option_button: AgeOptionButton = $SmoothScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/AgeOptionButton
@onready var lore_age_option_button: AgeOptionButton = $SmoothScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/LoreAgeOptionButton


@onready var species_line_edit: LineEdit = $SmoothScrollContainer/MarginContainer/VBoxContainer/TopContainer/SpeciesContainer/SpeciesLineEdit

@onready var bod_props_container: BodyPropsContianer = $SmoothScrollContainer/MarginContainer/VBoxContainer/BodPropsContainer

@onready var clothing_scoring: ClothingScoring = $SmoothScrollContainer/MarginContainer/VBoxContainer/ClothingHFlow

@onready var pose_container: PoseContainer = $SmoothScrollContainer/MarginContainer/VBoxContainer/PanelContainer/PoseContainer


func get_genders() -> Array[String]:
	var return_array: Array[String] = [gender_opt.get_gender_tag()]
	
	if not canon_gender.disabled:
		return_array.append(canon_gender.get_gender_tag() + " (lore)")
	
	return return_array


func get_focus_dict() -> Dictionary:
	return {
		"body": bod_type_opt_btn.get_body_type(),
		"gender": gender_opt.get_gender_tag()
	}


func is_foucsed() -> bool:
	return focus_check_box.button_pressed


func is_top() -> bool:
	return top_check.button_pressed


func is_bottom() -> bool:
	return bottom_check.button_pressed


func is_dom() -> bool:
	return dominant_check.button_pressed


func is_sub() -> bool:
	return submissive_check.button_pressed


func get_ages() -> Array[String]:
	var age_array: Array[String] = []
	
	var age: String = age_option_button.get_age_tag()
	
	if age != "adult":
		age_array.append(age_option_button.get_age_tag())
	if not lore_age_option_button.disabled:
		age_array.append(
			lore_age_option_button.get_age_tag() + " (lore)"
		)
	return age_array


func get_tag_dict() -> Dictionary:
	var main_tags: Array[String] = []
	var suggestion_array: Array[String] = []
	
	var clothing_dict: Dictionary = clothing_scoring.get_tags()
	
	var gender: String = gender_opt.get_gender_tag()
	
	
	var body_tags: Array = bod_type_opt_btn.get_body_type()
	
	if gender == "ambiguous gender":
		gender = "ambiguous"
	
	if known_character:
		main_tags.append(name)
	else:
		main_tags.append("unknown character")
	
	main_tags.append_array(body_tags)
	
	var species: String = species_line_edit.text.strip_edges()
	
	if not species.is_empty():
		main_tags.append(species)
	
	main_tags.append_array(get_genders())
	main_tags.append_array(get_ages())
	main_tags.append_array(bod_props_container.get_tags())
	main_tags.append_array(clothing_dict["tags"])
	main_tags.append_array(pose_container.get_tags())
	suggestion_array.append_array(clothing_dict["suggestions"])
	
	if is_sub():
		main_tags.append("submissive")
		main_tags.append("submissive " + gender)
		for body in body_tags:
			main_tags.append("submissive " + body)
	elif is_dom():
		main_tags.append("dominant")
		main_tags.append("dominant " + gender)
		for body in body_tags:
			main_tags.append("dominant " + body)
	
	if is_bottom():
		main_tags.append("on bottom")
		main_tags.append(gender + " on bottom")
		for body in body_tags:
			main_tags.append(body + " on bottom")
	
	elif is_top():
		main_tags.append("on top")
		main_tags.append(gender + " on top")
		for body in body_tags:
			main_tags.append(body + " on top")

	return {"tags": main_tags, "suggestions": suggestion_array}




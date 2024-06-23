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

@onready var name_separator = $SmoothScrollContainer/MarginContainer/VBoxContainer/HTitleSeparator


func _ready():
	name_separator.set_title_name(
		DumbUtils.title_case(name)
	)


func get_genders() -> Array[String]:
	var gender: String = gender_opt.get_gender_tag()
	var form: Array = bod_type_opt_btn.get_body_type()
	
	var gendered_form: String = gender + " " + form[0]
	
	var return_array: Array[String] = [gender, gendered_form]
	
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
	
	var age_tag: String = age_option_button.get_age_tag()
	var lore_age_group: Tagger.AgeRange = lore_age_option_button.get_age_category()
	
	if not age_tag.is_empty():
		age_array.append(age_tag)
	
	if not lore_age_option_button.disabled:
		if lore_age_group == Tagger.AgeRange.YOUNG:
			age_array.append("young (lore)")
		else:
			age_array.append("adult (lore)")
		
		# Mature doesn't have a tag, same as "adult". But that's handled
		# up there ^
		if  lore_age_group == Tagger.AgeRange.MATURE:
			age_array.append("mature (lore)")
		elif not age_tag.is_empty(): # "mature" and "adult" = false
			age_array.append(
				age_tag + " (lore)")

	return age_array


func get_tag_dict() -> Dictionary:
	var main_tags: Array[String] = []
	var suggestion_array: Array[String] = []
	
	var clothing_dict: Dictionary = clothing_scoring.get_tags()
	
	var gender: String = gender_opt.get_gender_tag()

	var body_tags: Array = bod_type_opt_btn.get_body_type()
	
	var age_group: Tagger.AgeRange = age_option_button.get_age_category()
	
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
	
	if age_group == Tagger.AgeRange.YOUNG:
		main_tags.append("young " + gender)
		for form in body_tags:
			main_tags.append("young " + form)
	elif age_group == Tagger.AgeRange.MATURE:
		main_tags.append("mature " + gender)
		for form in body_tags:
			main_tags.append("mature " + form)
	elif age_group == Tagger.AgeRange.OLD:
		main_tags.append("old " + gender)
		for form in body_tags:
			main_tags.append("old " + form)
	
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


func set_gender_id(gender_id: String):
	gender_opt.set_gender_by_id(gender_id)


func set_body_id(body_id: String) -> void:
	bod_type_opt_btn.select_body(body_id)


func set_age_id(age_id: String) -> void:
	age_option_button.set_age_by_id(age_id)




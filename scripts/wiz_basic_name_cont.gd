class_name WizardBasicAuthory
extends HBoxContainer



@onready var artist_line_edit: LineEdit = $ArtistContainer/HBoxContainer/ArtistLineEdit
@onready var unknown_art_chk_btn: CheckButton = $ArtistContainer/UnknownArtChkBtn
@onready var year_spin_box: SpinBox = $YearContainer/HBoxContainer/YearSpinBox
@onready var unknown_date_chk_btn: CheckButton = $YearContainer/UnknownDateChkBtn



func get_tags() -> Array[String]:
	var tag_array: Array[String] = []
	
	var artist_line: String = artist_line_edit.text.strip_edges()
	
	if unknown_art_chk_btn.button_pressed:
		tag_array.append("unknown artist")
	elif not artist_line.is_empty():
		tag_array.append(artist_line)
	
	if not unknown_date_chk_btn.button_pressed:
		tag_array.append(str(year_spin_box.value))
	
	return tag_array







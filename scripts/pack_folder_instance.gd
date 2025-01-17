class_name PackFolderInstance
extends Control


const TAG_CHECK_BOX = preload("res://scenes/tag_check_box.tscn")

@onready var tags_container: HFlowContainer = $VBoxContainer/MarginContainer/SmoothScrollContainer/TagsContainer

@onready var search_name_line_edit: LineEdit = $VBoxContainer/SearchContainer/SearchNameLineEdit
@onready var category_option_button: CategoryOptionButton = $VBoxContainer/SearchContainer/CatCon/CategoryOptionButton
@onready var enable_cat: CheckButton = $VBoxContainer/SearchContainer/CatCon/EnableCat
@onready var search_by_priority_spin: SpinBox = $VBoxContainer/SearchContainer/HBoxContainer/SearchByPrioritySpin
@onready var enable_prio_check_button: CheckButton = $VBoxContainer/SearchContainer/HBoxContainer/EnablePrioCheckButton
@onready var search_button: Button = $VBoxContainer/SearchContainer/SearchButton
@onready var show_all_button: Button = $VBoxContainer/SearchContainer/ShowAllButton
@onready var close_button: Button = $VBoxContainer/SearchContainer/CloseButton

@onready var select_all_button: Button = $VBoxContainer/HBoxContainer/SelectAllButton
@onready var deselect_all_button: Button = $VBoxContainer/HBoxContainer/DeselectAllButton
@onready var check_from_folder_button: Button = $VBoxContainer/SearchContainer/CheckFromFolderButton

@onready var pack_name_line_edit: LineEdit = $VBoxContainer/HBoxContainer/HBoxContainer/PackNameLineEdit
@onready var pack_desc_line_edit: LineEdit = $VBoxContainer/HBoxContainer/HBoxContainer/PackDescLineEdit
@onready var tag_map_type_line_edit: LineEdit = $VBoxContainer/HBoxContainer/HBoxContainer/TagMapTypeLineEdit
@onready var tag_map_cat_line_edit: LineEdit = $VBoxContainer/HBoxContainer/HBoxContainer/TagMapCatLineEdit

@onready var create_map_check_box: CheckBox = $VBoxContainer/HBoxContainer/HBoxContainer/CreateMapCheckBox


func _ready():
	show_all_button.pressed.connect(show_all)
	search_button.pressed.connect(on_search_tag)
	search_name_line_edit.text_submitted.connect(on_search_submited)
	close_button.pressed.connect(queue_free)
	select_all_button.pressed.connect(on_select_all_pressed)
	deselect_all_button.pressed.connect(on_deselect_all_pressed)
	check_from_folder_button.pressed.connect(check_from_folder)
	for key in Tagger.loaded_tags:
		for tag in Tagger.loaded_tags[key]:
			var tag_load: Tag = Tagger.get_tag(tag)
			var new_tag: TagCheckBox = TAG_CHECK_BOX.instantiate()
			new_tag.tag_name = tag
			new_tag.tag_category = tag_load.category
			new_tag.tag_priority = tag_load.tag_priority
			new_tag.tag_path = Tagger.loaded_tags[key][tag]["path"]
			tags_container.add_child(new_tag)
	

func get_paths_to_pack() -> Array[String]:
	var return_pack: Array[String] = []
	for check:TagCheckBox in tags_container.get_children():
		if check.button_pressed:
			return_pack.append(check.tag_path)
	return return_pack


func on_search_tag() -> void:
	on_search_submited(search_name_line_edit.text)


func on_search_submited(tag_serch: String) -> void:
	if not tag_serch.is_empty():
		for check:TagCheckBox in tags_container.get_children():
			check.visible = check.tag_name.contains(tag_serch)

	if enable_cat.button_pressed:
		var cat_select := category_option_button.get_category()
		for check:TagCheckBox in tags_container.get_children():
			if not check.visible:
				continue
			check.visible = check.tag_category == cat_select
	
	if enable_prio_check_button.button_pressed:
		var priority: int = int(search_by_priority_spin.value)
		for check:TagCheckBox in tags_container.get_children():
			if not check.visible:
				continue
			
			check.visible = check.tag_priority == priority


func show_all() -> void:
	for check:TagCheckBox in tags_container.get_children():
		if not check.visible:
			check.visible = true


func on_select_all_pressed() -> void:
	#on_deselect_all_pressed()
	for check:TagCheckBox in tags_container.get_children():
		if check.visible and not check.button_pressed:
			check.button_pressed = true


func on_deselect_all_pressed() -> void:
	for check:TagCheckBox in tags_container.get_children():
		if check.button_pressed and check.visible:
			check.button_pressed = false


func get_pack_type() -> String:
	return tag_map_type_line_edit.text.strip_edges().to_lower()


func get_pack_category() -> String:
	return tag_map_cat_line_edit.text.strip_edges().to_lower()


func get_pack_name() -> String:
	return pack_name_line_edit.text.strip_edges()


func get_pack_desc() -> String:
	return pack_desc_line_edit.text.strip_edges()


func is_tagmap_enabled() -> bool:
	return create_map_check_box.button_pressed


# So many loops, so ugly.
func check_from_folder() -> void:
	var pack_path: String = Tagger.database_path + Tagger.TAGS_PATH + name + "/"
	for tag_in_folder in DirAccess.get_files_at(pack_path):
		var loaded_tag: Tag = load(pack_path + tag_in_folder)
		for check:TagCheckBox in tags_container.get_children():
			if check.text == loaded_tag.tag:
				check.button_pressed = true
				break


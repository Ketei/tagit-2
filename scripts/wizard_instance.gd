class_name WizardInstance
extends Control


signal wizard_finished(finish_data: Dictionary)

const CHARA_INFO_INSTANCE = preload("res://scenes/chara_info_instance.tscn")
const WIZARD_VIEW_SELECTOR = preload("res://scenes/wizard_view_selector.tscn")

var unknown_count: int = 1
var view_selector: WizardViewSelector

# Charcter Menu
@onready var char_menu: MenuButton = $MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/MenuButton

# Stuff that returns tags
@onready var basic_data: WizardBasicAuthory = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/BasicData
@onready var media_type: WizardMediaTypes = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/MediaType
@onready var backgrounds_container: BackgroundsContainer = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/HBoxContainer
@onready var completion_container: WizardCompletionContainer = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/CompletionContainer
@onready var perspectives: WizardContainer = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives
@onready var comic_container: WizardContainer = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/ComicContainer
@onready var extra_segs: WizardContainer = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/ExtraSegs
@onready var sex_interactions: WizardSexInteractions = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/SexInteractions

# Character Containers
@onready var character_info_tab: TabContainer = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/CharacterInfo

# Tools
@onready var character_namer: WizardCharacterNamer = $CharacterNamer

# Sets
@onready var year_spin_box: SpinBox = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/BasicData/YearContainer/HBoxContainer/YearSpinBox

# Angles
@onready var worm_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/AnglesContainer/ChecksContainer/WormCheckBox
@onready var low_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/AnglesContainer/ChecksContainer/LowCheckBox
@onready var high_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/AnglesContainer/ChecksContainer/HighCheckBox
@onready var bird_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/AnglesContainer/ChecksContainer/BirdCheckBox

# Views
@onready var front_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/ViewsContainer/ChecksContainer/FrontCheckBox
@onready var three_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/ViewsContainer/ChecksContainer/ThreeCheckBox
@onready var side_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/ViewsContainer/ChecksContainer/SideCheckBox
@onready var butt_check_box: WizardCheckBoxTag = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/ViewsContainer/ChecksContainer/ButtCheckBox

@onready var view_select_button: Button = $MarginContainer/HBoxContainer/SmoothScrollContainer/ImageInfo/Perspectives/OpenViewSlectButton
@onready var cancel_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/ButtonsContainer/CancelButton
@onready var done_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/ButtonsContainer/DoneButton


# Called when the node enters the scene tree for the first time.
func _ready():
	Tagger.disable_shortcuts()
	char_menu.get_popup().index_pressed.connect(on_menu_selected)
	character_info_tab.get_tab_bar().tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
	character_info_tab.get_tab_bar().tab_close_pressed.connect(on_close_tab_pressed)
	year_spin_box.value = Time.get_date_dict_from_system().year
	view_select_button.pressed.connect(open_view_selector)
	cancel_button.pressed.connect(on_cancel_press)
	done_button.pressed.connect(on_finish_pressed)
	character_namer.character_created.connect(create_character)


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		close_wizard()


func open_view_selector() -> void:
	view_selector = WIZARD_VIEW_SELECTOR.instantiate()
	view_selector.views_selected.connect(on_views_selected)
	add_child(view_selector)


func on_views_selected(view_dict: Dictionary) -> void:
	perspectives.deselect_all()
	worm_check_box.button_pressed = view_dict["worm"]
	low_check_box.button_pressed = view_dict["low"]
	high_check_box.button_pressed = view_dict["high"]
	bird_check_box.button_pressed = view_dict["bird"]
	front_check_box.button_pressed = view_dict["front"]
	three_check_box.button_pressed = view_dict["profile"]
	side_check_box.button_pressed = view_dict["side"]
	butt_check_box.button_pressed = view_dict["rear"]
	view_selector.queue_free()


func on_close_tab_pressed(tab_index: int) -> void:
	var character_name: String = character_info_tab.get_tab_bar().get_tab_title(tab_index)
	
	for node_tab in character_info_tab.get_children():
		if node_tab.name == character_name:
			node_tab.queue_free()
			break


func create_character(character_name: String, set_unknown := false) -> void:
	character_namer.clear()
	if character_name.is_empty() or has_character(character_name):
		return
	
	var new_character: WizardCharacterInstance = CHARA_INFO_INSTANCE.instantiate()
	new_character.name = character_name
	if set_unknown:
		new_character.known_character = false
	
	character_info_tab.add_child(new_character)
	
	character_info_tab.current_tab = new_character.get_index()
					
	if Tagger.has_tag(character_name):
		var tag_data: Tag = Tagger.get_tag(character_name)
		if tag_data.category == Tagger.Categories.CHARACTER:
			var body_types: Array[String] = []
			for parent_tag in tag_data.parents:
				if Tagger.is_valid_gender(parent_tag):
					new_character.set_gender_id(
							Tagger.get_gender_id(parent_tag)
					)
				elif Tagger.is_valid_body_tag(parent_tag):
					body_types.append(parent_tag)
				elif Tagger.is_valid_age_tag(parent_tag):
					new_character.set_age_id(
							Tagger.get_age_id(parent_tag)
					)
			new_character.set_body_id(Tagger.get_body_id(body_types))


func has_character(character_name: String) -> bool:
	for character_tab in character_info_tab.get_children():
		if character_tab.name == character_name:
			return true
	return false


func on_menu_selected(index_selected: int) -> void:
	if index_selected == 0: # Known Character
		character_namer.show()
		character_namer.grab_line_focus()
	elif index_selected == 1: # UnknowCharacter
		create_character("????? #" + str(unknown_count), true)
		unknown_count += 1


func on_finish_pressed() -> void:
	var tags_dict: Dictionary = {
		"tags": [],
		"suggestions": []}
	
	var character_count: int = 0
	var focus_count: int = 0
	
	for char_inst:WizardCharacterInstance in character_info_tab.get_children():
		character_count += 1
		
		if char_inst.is_foucsed():
			focus_count += 1

		var char_dict: Dictionary = char_inst.get_tag_dict()
		
		for char_tag in char_dict["tags"]:
			if not tags_dict["tags"].has(char_tag):
				tags_dict["tags"].append(char_tag)
		
		for sugg in char_dict["suggestions"]:
			if not tags_dict["suggestions"].has(sugg):
				tags_dict["suggestions"].append(sugg)
	
	if character_count == 0:
		tags_dict["tags"].append("zero_pictured")
	elif character_count == 1:
		tags_dict["tags"].append("solo")
	elif character_count == 2:
		tags_dict["tags"].append("duo")
	elif character_count == 3:
		tags_dict["tags"].append("trio")
		tags_dict["tags"].append("group")
	elif 3 < character_count:
		tags_dict["tags"].append("group")

	if 0 < character_count and 0 < focus_count:
		if character_count != focus_count:
			if focus_count == 1:
				tags_dict["tags"].append("solo focus")
			elif focus_count == 2:
				tags_dict["tags"].append("duo focus")
			elif focus_count == 3:
				tags_dict["tags"].append("trio focus")
	
	tags_dict["tags"].append_array(basic_data.get_tags())
	tags_dict["tags"].append_array(media_type.get_media_tags())
	tags_dict["tags"].append_array(backgrounds_container.get_background_tags())
	tags_dict["tags"].append_array(completion_container.get_tags())
	tags_dict["tags"].append_array(perspectives.get_tags())
	tags_dict["tags"].append_array(comic_container.get_tags())
	tags_dict["tags"].append_array(extra_segs.get_tags())
	tags_dict["tags"].append_array(sex_interactions.get_interactions())
	
	wizard_finished.emit(tags_dict)


func on_cancel_press() -> void:
	close_wizard()


func close_wizard() -> void:
	Tagger.enable_shortcuts()
	queue_free()



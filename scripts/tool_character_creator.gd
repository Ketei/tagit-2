extends Control


const TAB_INFO: Dictionary = {
	1: "Basic Info Tab",
	2: "Heaad Info Tab",
	3: "Torso Info Tab",
	4: "Hand/Feet Info Tab",
	5: "Legs Info Tab",
	6: "Tail info Tab",
	7: "Genitals Info Tab",
	8: "Extra Info Tab",
}


@onready var category_info: RichTextLabel = $MarginContainer/DataContainer/InfoContainer/PanelContainer/InfoSide/InfoSmoothScrollContainer/CategoryInfo
@onready var tag_item_list: TagItemList = $MarginContainer/DataContainer/InfoContainer/ExtraTagsContainer/TagItemList
@onready var tab_container: TabContainer = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer
@onready var info_smooth_scroll_container: SmoothScrollContainer = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer

@onready var reset_button: Button = $MarginContainer/DataContainer/TabsContainer/ButtonsContainer/ResetButton
@onready var prev_button: Button = $MarginContainer/DataContainer/TabsContainer/ButtonsContainer/PrevButton
@onready var next_button: Button = $MarginContainer/DataContainer/TabsContainer/ButtonsContainer/NextButton
@onready var finish_button: Button = $MarginContainer/DataContainer/TabsContainer/ButtonsContainer/FinishtButton

@onready var wiki_text_edit: TextEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/ExtraInfo/WikiInfo/WikiTextEdit
@onready var tooltip_line_edit: LineEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/ExtraInfo/TooltipContainer/TooltipLineEdit

@onready var name_line_edit: LineEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/NameContainer/NameLineEdit
@onready var species_line_edit: LineEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/SpeciesContainer/SpeciesLineEdit

@onready var gender_option_button: GenderOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/BasicsContainer/GenderContainer/GenderOptionButton
@onready var age_option_button: AgeOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/BasicsContainer/AgeContainer/AgeOptionButton
@onready var body_type_opt_btn: BodyOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/BasicsContainer/BodyForm/BodTypeOptBtn

@onready var figure_button: TagsOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/ShapeContainer/FigureContainer/TagsOptionButton


var skip_nodes: Array[Control] = []

var tag_option_buttons: Array[TagsOptionButton] = []
var character_spinboxes: Array[CharSpinBox] = []
var character_flows: Array[CharHflowContainer] = []
var character_checkboxes: Array[TagCheckBoxCharacter] = []
var conditionals: Array[ConditionalVisibilityCheckButton] = []

var max_tabs: int = 0
var current_tab: int = 1:
	set(new_tab):
		current_tab = new_tab
		on_tab_changed()
var scroll_queued := false 


func _ready():
	next_button.pressed.connect(on_next_pressed)
	prev_button.pressed.connect(on_previous_pressed)
	finish_button.pressed.connect(on_finish_pressed)
	reset_button.pressed.connect(reset_fields)
	max_tabs = tab_container.get_child_count()
	
	if tab_container.current_tab != 0:
		tab_container.current_tab = 0
	
	category_info.text = TAB_INFO[current_tab]
	
	skip_nodes.assign([
			wiki_text_edit,
			tooltip_line_edit,
			name_line_edit,
			species_line_edit,
			body_type_opt_btn,
			gender_option_button,
			age_option_button
			])
	
	prepare_for_skips(self)
	explore_for_elements(self)
	
	skip_nodes.clear()


func generate_characer() -> void:
	var tag_name: String = name_line_edit.text.strip_edges().to_lower()
	
	if Tagger.has_tag(tag_name):
		var warn_window:TaggerConfirmationDialog = Tagger.create_confirmation_dialog()
		
		warn_window.set_data(
			"Existing Tag...",
			"Tag \"{0}\" already exists.\nOverwrite?".format([tag_name]),
			"Overwrite",
			"Cancel")
		
		warn_window.visible = true
		
		var replace_tag: bool = await warn_window.dialog_confirmed
		
		warn_window.visible = false
		warn_window.queue_free()
		
		if not replace_tag:
			return
	
	
	var tag_res := Tag.new()
	tag_res.tag = tag_name
	
	if tag_res.tag.is_empty():
		tag_res.tag = "nameless character"
	
	tag_res.category = Tagger.Categories.CHARACTER
	tag_res.tag_priority = 5
	DumbUtils.append_without_repeats(tag_res.parents, species_line_edit.get_string_array())
	tag_res.parents.append(gender_option_button.get_gender_tag())
	var age: String = age_option_button.get_age_tag()
	if not age.is_empty():
		tag_res.parents.append(age)
	DumbUtils.append_without_repeats(tag_res.parents, body_type_opt_btn.get_body_type())

	if figure_button.selected == 5: # 4 base + unknown
		if gender_option_button.is_female():
			if not tag_res.suggestions.has("shortstack"):
				tag_res.suggestions.append("shortstack")
		else:
			if not tag_res.suggestions.has("teapot (body type)"):
				tag_res.suggestions.append("teapot (body type)")
	
	for opt_btn in tag_option_buttons:
		DumbUtils.append_without_repeats(tag_res.suggestions, opt_btn.get_tags())
	
	for char_spin in character_spinboxes:
		var tag_to_add: String = char_spin.get_tag()
		if not tag_res.suggestions.has(tag_to_add) and not tag_to_add.is_empty():
			tag_res.suggestions.append(tag_to_add)
	
	for char_flow in character_flows:
		DumbUtils.append_without_repeats(tag_res.suggestions, char_flow.get_selected())
	
	for char_check in character_checkboxes:
		if not char_check.button_pressed:
			continue
		DumbUtils.append_without_repeats(tag_res.suggestions, char_check.get_tags())
	
	for special in conditionals:
		if not special.is_enabled():
			continue
		DumbUtils.append_without_repeats(
				tag_res.suggestions,
				special.get_tags()
		)
	
	DumbUtils.append_without_repeats(tag_res.suggestions, tag_item_list.get_tag_array())
	
	tag_res.wiki_entry = wiki_text_edit.text.strip_edges()
	
	if tag_res.wiki_entry.is_empty():
		tag_res.wiki_entry = "- Nobody here but us chickens! -"
	
	tag_res.tooltip = tooltip_line_edit.text.strip_edges()
	
	print("Tag: " + tag_res.tag)
	print("Parents: " + str(tag_res.parents))
	print("Suggestions: " + str(tag_res.suggestions))
	print("Wiki: " + tag_res.wiki_entry)
	print("Tooltip: " + tag_res.tooltip)
	
	Tagger.queue_notification(
			"Character created",
			"Character \"{0}\" has been created".format([tag_name]))
	
	


func reset_fields() -> void:
	for opt_btn in tag_option_buttons:
		opt_btn.select(0)
	for spn_bx in character_spinboxes:
		spn_bx.value = spn_bx.default
	for char_flow in character_flows:
		char_flow.deselect_all()
	for char_chkbx in character_checkboxes:
		char_chkbx.button_pressed = char_chkbx.default
	for spec_item in conditionals:
		spec_item.reset_items()
	wiki_text_edit.clear()
	tooltip_line_edit.clear()
	name_line_edit.clear()
	species_line_edit.clear()
	gender_option_button.select(0)
	age_option_button.select(0)
	body_type_opt_btn.select(0)
	tag_item_list.clear()
	


func on_next_pressed() -> void:
	if tab_container.select_next_available():
		current_tab += 1


func on_previous_pressed() -> void:
	if tab_container.select_previous_available():
		current_tab -= 1


func on_tab_changed() -> void:
	next_button.visible = current_tab != max_tabs
	finish_button.visible = current_tab == max_tabs
	prev_button.disabled = current_tab == 1
	category_info.text = TAB_INFO[current_tab]
	queue_scroll_to_top()


func queue_scroll_to_top() -> void:
	#if scroll_queued:
		#return
	#scroll_queued = true
	#await get_tree().process_frame
	#print("scrolling")
	#info_smooth_scroll_container.scroll_y_to(0,0)
	if info_smooth_scroll_container.get_v_scroll_bar().value != 0:
		info_smooth_scroll_container.scroll_to_top(0)
	#scroll_queued = false


func prepare_for_skips(parent_node: Control) -> void:
	for child in parent_node.get_children():
		if not child is Control:
			continue
		
		if child is ConditionalVisibilityCheckButton:
			if child.is_conditional:
				DumbUtils.append_without_repeats(skip_nodes, child.visibility_controlled)
		else:
			prepare_for_skips(child)


func explore_for_elements(parent_node: Control) -> void:
	for child in parent_node.get_children():
		if not child is Control:
			continue
		
		if skip_nodes.has(child):
			continue
		elif child is TagsOptionButton:
			tag_option_buttons.append(child)
		elif child is CharSpinBox:
			character_spinboxes.append(child)
		elif child is CharHflowContainer:
			character_flows.append(child)
		elif child is TagCheckBoxCharacter:
			character_checkboxes.append(child)
		elif child is ConditionalVisibilityCheckButton:
			conditionals.append(child)
		else:
			explore_for_elements(child)


func on_finish_pressed() -> void:
	generate_characer()



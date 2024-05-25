extends Control


const TAB_INFO: Dictionary = {
	1: "You can manually add a tag at any moment by writing it on the line below that says [b]Extra Tags[/b]
Not every trait/feature needs to be filled out. If you're unsure it's ok to leave it unchecked/unselected.
[u]Species[/u], [u]Age[/u] and [u]Form[/u] will be added as parents. You can change the tag on the review window after you've finished it.

Some helpful info about the section you're in will appear here.

[b]Species:[/b] You can add multiple species by separating them with commas. \"canine, domestic dog\" will give you 2 tags: [u]canine[/u] and [u]domestic dog[/u]",
	
	2: "[b]Figure:[/b][ul]
[b]Hourglass[/b]:  Wide hips, small waist, and sizeable bust that is comparable to the hips. Any gender
[b]Pear[/b]:  Wide hips paired with a narrower upper body and shoulders. Any gender
[b]Venus[/b]: Wide hips, big thighs/buttocks, small waist, big bust, usually tall with small heads. Only females, gynomorph and herms.
[b]Voluptuous[/b]: Wide hips, thick thighs, big breasts and big butt. Only females, gynomorph and herms.[/ul]",
	
	3: "[b]Ear Size & Ear Length:[/b] They are relative to the character.

[b]Sclera:[/b] Usually the white part of an eyeball
[b]Pupil:[/b] Usually the black circle of an eyeball",
	4: "[b]About toggles:[/b] Enabling one of them will give extra options and it means your character has these traits.
[b]Glans[/b] is the acorn-shaped bulb at the end of the primate penis.",
	5: "[b]About toggles:[/b] Enabling one of them will give extra options and it means your character has these traits.

[b]Handpaws[/b] are hands that look more like paws than. Usually having short stubby fingers and pawpads on the palm and fingers

[b]Talon hands[/b] are hands that look like talons, usually having long hooked claws and having scutes instead of feathers/fur.",
	6: "[b]Movement:[/b]
[indent]
[b]Biped[/b] walks normally on two legs
[b]Triped[/b] walks normally on three legs
[b]Quadruped[/b] walks normally on four legs.
[/indent]
[b]Leg form:[/b]
[indent]
[b]Plantigrade[/b] walk by having the toes, soles and heel on the floor. Like humans
[b]Digitigrade[/b] walk by having only their digits on the floor. Like dogs.
[b]Ungligrade[/b] walk by having their hooves on the floor. Like horses.
[b]Hooved Plantigrade[/b] have hooves but still walk like plantigrades. This is normally by having the \"toes\" be hooves.
[b]Hooved digitigrade[/b] have hooves but walk like digitigrades. This is normally by having the \"toes\" be hooves.
[/indent]",
	7: "Tail Traits",
	8: "[b]About toggles:[/b] Enabling one of them will give extra options and it means your character has these traits.",
	9: "[b]Wiki[/b] is to write any extra detail/lore about your character.
[b]Tooltip[/b] is the text that will appear on the tag as you hover on it.",
	10: "Review the tags you've added."
}

@onready var category_info: RichTextLabel = $MarginContainer/DataContainer/InfoContainer/PanelContainer/InfoSide/CategoryInfo
@onready var tag_item_list: TagItemList = $MarginContainer/DataContainer/InfoContainer/ExtraTagsContainer/TagItemList
@onready var tab_container: TabContainer = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer
@onready var info_smooth_scroll_container: SmoothScrollContainer = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer

@onready var reset_button: Button = $MarginContainer/DataContainer/TabsContainer/ButtonsContainer/ResetButton
@onready var prev_button: Button = $MarginContainer/DataContainer/TabsContainer/ButtonsContainer/PrevButton
@onready var next_button: Button = $MarginContainer/DataContainer/TabsContainer/ButtonsContainer/NextButton
@onready var finish_button: Button = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/FinishtButton

@onready var wiki_text_edit: TextEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/ExtraInfo/WikiInfo/WikiTextEdit
@onready var tooltip_line_edit: LineEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/ExtraInfo/TooltipContainer/TooltipLineEdit

@onready var name_line_edit: LineEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/NameContainer/NameLineEdit
@onready var species_line_edit: LineEdit = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/SpeciesContainer/SpeciesLineEdit

@onready var gender_option_button: GenderOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/BasicsContainer/GenderContainer/GenderOptionButton
@onready var age_option_button: AgeOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/BasicsContainer/AgeContainer/AgeOptionButton
@onready var body_type_opt_btn: BodyOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/BaseData/BasicsContainer/BodyForm/BodTypeOptBtn

@onready var figure_button: TagsOptionButton = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/GenBodyContainer/ShapeContainer/FigureContainer/TagsOptionButton

# Review nodes ---
@onready var review_name_label: Label = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/BasicContainer7/HBoxContainer/NameLabel
@onready var review_species_label: Label = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/BasicContainer7/HBoxContainer2/SpeciesLabel
@onready var review_gender_opt: Label = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/DetsContainer/HBoxContainer3/GenderLabel
@onready var review_age_option_button: Label = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/DetsContainer/HBoxContainer4/AgeLabel
@onready var review_bod_type_opt_btn: Label = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/DetsContainer/HBoxContainer5/FormLabel
@onready var review_parents_item_list: ItemList = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/HBoxContainer6/VBoxContainer/ParentsItemList
@onready var review_suggestion_item_list: ItemList = $MarginContainer/DataContainer/TabsContainer/InteractSide/SmoothScrollContainer/TabContainer/Review/HBoxContainer6/VBoxContainer2/SuggestionItemList
#-------
@onready var extra_tags_container: VBoxContainer = $MarginContainer/DataContainer/InfoContainer/ExtraTagsContainer

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
	if Tagger.SOURCE_RUN:
		var button_container: HBoxContainer = get_node("MarginContainer/DataContainer/TabsContainer/ButtonsContainer")
		var new_debug_finish = Button.new()
		new_debug_finish.text = "Finish"
		new_debug_finish.pressed.connect(on_finish_pressed)
		new_debug_finish.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button_container.add_child(new_debug_finish)
	finish_button.pressed.connect(on_finish_pressed)
	reset_button.pressed.connect(on_reset_pressed)
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


func get_parents() -> Array[String]:
	var parents_array: Array[String] = []
	
	DumbUtils.append_without_repeats(parents_array, species_line_edit.get_string_array())
	parents_array.append(gender_option_button.get_gender_tag())
	
	var age: String = age_option_button.get_age_tag()
	
	if not age.is_empty():
		parents_array.append(age)
	DumbUtils.append_without_repeats(parents_array, body_type_opt_btn.get_body_type())
	
	return parents_array


func get_suggestions() -> Array[String]:
	var suggestions_array: Array[String] = []
	
	if figure_button.selected == 5: # 4 base + unknown
		if gender_option_button.is_female():
			if not suggestions_array.has("shortstack"):
				suggestions_array.append("shortstack")
		else:
			if not suggestions_array.has("teapot (body type)"):
				suggestions_array.append("teapot (body type)")
	
	for opt_btn in tag_option_buttons:
		DumbUtils.append_without_repeats(suggestions_array, opt_btn.get_tags())
	
	for char_spin in character_spinboxes:
		var tag_to_add: String = char_spin.get_tag()
		if not suggestions_array.has(tag_to_add) and not tag_to_add.is_empty():
			suggestions_array.append(tag_to_add)
	
	for char_flow in character_flows:
		DumbUtils.append_without_repeats(suggestions_array, char_flow.get_selected())
	
	for char_check in character_checkboxes:
		if not char_check.button_pressed:
			continue
		DumbUtils.append_without_repeats(suggestions_array, char_check.get_tags())
	
	for special in conditionals:
		if not special.is_enabled():
			continue
		DumbUtils.append_without_repeats(
				suggestions_array,
				special.get_tags()
		)
	
	DumbUtils.append_without_repeats(suggestions_array, tag_item_list.get_tag_array())
	
	return suggestions_array


func generate_characer() -> bool:
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
			return false
	
	var tag_res := Tag.new()
	tag_res.tag = tag_name
	
	if tag_res.tag.is_empty():
		tag_res.tag = "nameless character"
	
	tag_res.category = Tagger.Categories.CHARACTER
	tag_res.tag_priority = 5
	tag_res.parents = get_parents()
	tag_res.suggestions = get_suggestions()
	tag_res.wiki_entry = wiki_text_edit.text.strip_edges()
	
	if tag_res.wiki_entry.is_empty():
		tag_res.wiki_entry = "- Nobody here but us chickens! -"
	
	tag_res.tooltip = tooltip_line_edit.text.strip_edges()
	
	if Tagger.SOURCE_RUN:
		print("Tag: " + tag_res.tag)
		print("Parents: " + str(tag_res.parents))
		print("Suggestions: " + str(tag_res.suggestions))
		print("Wiki: " + tag_res.wiki_entry)
		print("Tooltip: " + tag_res.tooltip)
	else:
		Tagger.register_tag(
				tag_res.tag,
				tag_res.save()
				)
		Tagger.tag_updated.emit(tag_res.tag)
		
	
	Tagger.queue_notification(
			"Character \"{0}\" has been created".format([tag_name]),
			"Character created")
	return true


func on_reset_pressed() -> void:
	tab_container.current_tab = 0
	current_tab = 1
	reset_fields()


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
	next_button.disabled = current_tab == max_tabs
	prev_button.disabled = current_tab == 1
	category_info.text = TAB_INFO[current_tab]
	extra_tags_container.visible = current_tab != max_tabs
	queue_scroll_to_top()
	
	if current_tab == max_tabs:
		review_name_label.text = name_line_edit.text
		review_species_label.text = species_line_edit.text
		
		review_gender_opt.text = gender_option_button.get_item_text(gender_option_button.selected)
		review_age_option_button.text = age_option_button.get_item_text(age_option_button.selected)
		review_bod_type_opt_btn.text = body_type_opt_btn.get_item_text(body_type_opt_btn.selected)
		
		review_parents_item_list.clear()
		review_suggestion_item_list.clear()
		for item in get_parents():
			review_parents_item_list.add_item(item)
		for item in get_suggestions():
			review_suggestion_item_list.add_item(item)


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
	if not await generate_characer():
		return
	tab_container.current_tab = 0
	current_tab = 1
	reset_fields()



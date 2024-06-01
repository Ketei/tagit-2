class_name ConditionalVisibilityCheckButton
extends CheckButton


@export var includes_tags: Array[String] = []
@export var visibility_controlled: Array[Control] = []
## If enabled, when the button is pressed it'll be considered "disabled"
## and when it's not pressed it'll be considered "enabled".
@export var inverted: bool = false
## If true, all nodes in visibility_controlled will only give it's tags
## if this node is "enabled".
@export var is_conditional: bool = true


var tag_option_buttons: Array[TagsOptionButton] = []
var character_spinboxes: Array[CharSpinBox] = []
var character_flows: Array[CharHflowContainer] = []
var character_checkboxes: Array[TagCheckBoxCharacter] = []



func _ready():
	for item in visibility_controlled:
		item.visible = button_pressed != inverted
	toggled.connect(on_toggled)
	if is_conditional:
		for controlled in visibility_controlled:
			grab_conditionals(controlled)


func reset_items() -> void:
	button_pressed = inverted
	if is_conditional:
		for opt_btn in tag_option_buttons:
			opt_btn.select(0)
		for spn_bx in character_spinboxes:
			spn_bx.value = spn_bx.default
		for char_flow in character_flows:
			char_flow.deselect_all()
		for char_chkbx in character_checkboxes:
			char_chkbx.button_pressed = char_chkbx.default



func grab_conditionals(parent: Control) -> void:
	for child in parent.get_children():
		if child is TagsOptionButton:
			tag_option_buttons.append(child)
		elif child is CharSpinBox:
			character_spinboxes.append(child)
		elif child is CharHflowContainer:
			character_flows.append(child)
		elif child is TagCheckBoxCharacter:
			character_checkboxes.append(child)
		else:
			grab_conditionals(child)


func on_toggled(is_toggled: bool) -> void:
	for controlled in visibility_controlled:
		controlled.visible = is_toggled != inverted


func get_tags() -> Array[String]:
	var return_tags: Array[String] = []
	return_tags.append_array(includes_tags)
	
	if is_conditional:
		for opt_bnt in tag_option_buttons:
			DumbUtils.append_without_repeats(return_tags, opt_bnt.get_tags())
		for spn_bx in character_spinboxes:
			var tag_to_add: String = spn_bx.get_tag()
			if not return_tags.has(tag_to_add) and not tag_to_add.is_empty():
				return_tags.append(tag_to_add)
		for hflow in character_flows:
			DumbUtils.append_without_repeats(return_tags, hflow.get_selected())
		for check in character_checkboxes:
			DumbUtils.append_without_repeats(return_tags, check.get_tags())
	
	return return_tags


func is_enabled() -> bool:
	return button_pressed != inverted


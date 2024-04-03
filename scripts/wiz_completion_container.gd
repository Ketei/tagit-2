class_name WizardCompletionContainer
extends WizardContainer


var check_boxes: Array[WizardCheckBoxTag] = []

@onready var sketch_check: WizardCheckBoxTag = $CompletionContainerH/DegreeContainer/SketchCheck
@onready var colored_check: WizardCheckBoxTag = $CompletionContainerH/ColoredCheck


func get_tags() -> Array[String]:
	var tag_array: Array[String] = []
	
	for check in checkboxes:
		if check.button_pressed and not check.disabled:
			tag_array.append(check.get_tag())
	
	if sketch_check.button_pressed and colored_check.button_pressed:
		tag_array.append("colored sketch")
	
	return tag_array



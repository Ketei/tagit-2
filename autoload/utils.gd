class_name DumbUtils
extends Node


static func capitalize(input_string: String) -> String:
	var return_string: String = ""
	
	return_string = input_string.left(1).to_upper() +\
	input_string.right(-1).to_lower()
	
	return return_string


static func title_case(input_string: String) -> String:
	var capitalize_next: bool = true
	var return_string: String = ""
	
	for letter in input_string:
		if capitalize_next:
			return_string += letter.to_upper()
			capitalize_next = false
		else:
			return_string += letter
		
		if letter == " ":
			capitalize_next = true
	
	return return_string



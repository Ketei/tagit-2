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


static func is_str_digit(digit_to_check: String) -> bool:
	var digits: Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	return digits.has(digit_to_check)


static func signal_disconnect_all(signal_to_disconnect: Signal) -> void:
	for call_dict:Dictionary in signal_to_disconnect.get_connections():
		signal_to_disconnect.disconnect(call_dict["callable"])


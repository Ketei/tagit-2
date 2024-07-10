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


static func append_without_repeats(array_to_append: Array, data_to_append: Array) -> void:
	for item in data_to_append:
		if not array_to_append.has(item):
			array_to_append.append(item)


static func pluralize_word(singular_form: String) -> String:
	const es_conditions: Array[String] = ["s", "x", "z", "sh", "ch"]
	const vocals: Array[String] = ["a", "e", "i", "o", "u"]
	var suffix: String = ""
	
	if has_suffix_array(singular_form, es_conditions):
		suffix = "es"
	elif 1 < singular_form.length() and singular_form.ends_with("y") and not vocals.has(singular_form[-2]):
		singular_form = singular_form.left(-1)
		suffix = "ies"
	else:
		suffix = "s"
	
	return singular_form + suffix


static func has_suffix_array(string_to_check: String, suffix_array: Array[String]) -> bool:
	for suffix in suffix_array:
		if string_to_check.ends_with(suffix):
			return true
	return false


static func is_letter(character: String) -> bool:
	const valid_letters: Array[String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "ñ", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", " "]
	
	return valid_letters.has(character.to_lower())
	

static func array_remove_all(array: Array, value: Variant) -> void:
	while array.has(value):
		array.erase(value) 

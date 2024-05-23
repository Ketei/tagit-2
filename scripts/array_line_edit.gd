extends LineEdit


func get_string_array() -> Array[String]:
	var return_array: Array[String] = []
	
	if text.is_empty():
		return return_array
	
	for element in text.split(",", false):
		var format_text: String = element.strip_edges().to_lower()
		if not return_array.has(format_text):
			return_array.append(format_text)
	
	return return_array


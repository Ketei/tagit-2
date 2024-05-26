extends Node


signal request_get(request_response: Array)
signal implications_get(request_response: Array)
signal prio_get(request_response: Array)

enum JOB_TYPES {
	WIKI,
	SUGGESTION,
	ALIAS,
	PARENTS,
}

var requester: HTTPRequest
var priority_requester: HTTPRequest

var jobs: Array[Dictionary] = []

var job_timer: Timer
var regex: RegEx

var working: bool = false


func _ready():
	requester = HTTPRequest.new()
	requester.timeout = 10
	requester.request_completed.connect(on_request_completed)
	add_child(requester)
	priority_requester = HTTPRequest.new()
	priority_requester.timeout = 10
	priority_requester.request_completed.connect(on_prio_request_completed)
	add_child(priority_requester)
	regex = RegEx.new()
	job_timer = Timer.new()
	job_timer.autostart = false
	job_timer.one_shot = true
	job_timer.wait_time = 1.2
	job_timer.timeout.connect(on_timer_timeout)
	add_child(job_timer)
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		jobs.clear()
		job_timer.stop()
		if working:
			requester.cancel_request()


func queue_job(url: String, target_node: Node, job_type: JOB_TYPES) -> void:
	working = true
	jobs.append({"url": url, "node": target_node, "type": job_type})
	Tagger.http_requests += 1
	if job_timer.is_stopped():
		job_timer.start()


func convert_from_wiki(text_from_wiki: String) -> String:
	#var body_reply: String = "thumb #323057 thumb #2581520 thumb #3998445\r\n\r\nA [[male]] character that appears [[young|visibly underage]].\r\n\r\nh4. Related Tags\r\n* [[shota]]\r\n\r\nh4. Not To Be Confused With\r\n* [[younger_male]]\r\n\r\nh4. See Also\r\n* [[young_ambiguous]]\r\n* [[young_female]]\r\n* [b]young_male[/b]\r\n* [[young_intersex]]\r\n** [[young andromorph]]\r\n** [[young_gynomorph]]\r\n** [[young_herm]]\r\n** [[young_maleherm]]"
	
	regex.clear()
	regex.compile("[Tt]humb #\\d+\\s*")
	var return_string: String = regex.sub( # clears "thumb #XXXX"
		text_from_wiki,
		"",
		true)
	
	regex.clear()
	regex.compile("(?m)^(?:\\*+(?:.*)?\\n*)+")
	for result in regex.search_all(text_from_wiki):
		return_string = return_string.replace(result.get_string(), format_nested_list(result.get_string()))
	
	regex.clear()
	regex.compile("\\[\\[[^|\\]]+\\]\\]") # Finds [[*]]
	for new_url:RegExMatch in regex.search_all(return_string):
		var url = new_url.get_string().trim_prefix("[[").trim_suffix("]]").replace("_", " ")
		return_string = return_string.replace(new_url.get_string(), "[color=AQUAMARINE][url]{0}[/url][/color]".format([url]))	
	
	regex.clear()
	regex.compile("\\[\\[[^|\\]]+\\|[^|\\]]+\\]\\]") # Finds special urls
	for custom_url:RegExMatch in regex.search_all(return_string):
		var array: Array = custom_url.get_string().trim_prefix("[[").trim_suffix("]]").replace("_", " ").split("|")
		return_string = return_string.replace(custom_url.get_string(), "[color=AQUAMARINE][url={0}]{1}[/url][/color]".format(array))

	regex.clear()
	regex.compile("h5\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h5.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=18][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("(?m)^h4\\..*\\n")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h4.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=20][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("h3\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h3.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=22][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("h2\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h2.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=25][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("h1\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h1.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=27][b]{0}[/b][/font_size]".format([header_four]))
	
	return return_string


func on_timer_timeout() -> void:
	if not jobs.is_empty():
		var req_url: Dictionary = jobs.pop_front()
		Tagger.log_message("Making a request to:\n" + req_url["url"])
		requester.request(req_url["url"], Tagger.get_headers())
		var response: Array = await request_get
		Tagger.log_message("Response received")
		if is_instance_valid(req_url["node"]) and req_url["node"].is_inside_tree():
			req_url["node"].process_response(response, req_url["type"])
		job_timer.start()
	else:
		working = false
		Tagger.http_requests -= 1


func on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var response: Array = []
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Tagger.log_message(
			"An error was encountered with the request.\nResult code: " + str(result) + "\nResponse code: " + str(response_code),
			Tagger.LoggingLevel.WARNING)
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error == OK:
		var pre_json = json.get_data()
		if pre_json is Array:
			response = pre_json # Should be Array[Dictionary]
	else:
		Tagger.log_message(
			"Error parsing response data: " + json.get_error_message(),
			Tagger.LoggingLevel.ERROR
		)
	
	request_get.emit(response)


func request_prio(url: String) -> void:
	priority_requester.request(url, Tagger.get_headers())


func on_prio_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var response: Array = []
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Tagger.log_message(
			"An error was encountered with the request.\nResult code: " + str(result) + "\nResponse code: " + str(response_code),
			Tagger.LoggingLevel.WARNING)
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error == OK:
		var pre_json = json.get_data()
		if pre_json is Array:
			response = pre_json # Should be Array[Dictionary]
	else:
		Tagger.log_message(
			"Error parsing response data: " + json.get_error_message(),
			Tagger.LoggingLevel.ERROR
		)
	
	prio_get.emit(response)


func parse_tag_strength(parse_string: String) -> Dictionary:
	var return_dictionary: Dictionary = {}
	
	# I'm seriously starting to question the logic of whoever
	# designed the e621 API.
	if parse_string.is_empty() or parse_string == "[]":
		return return_dictionary
	
	var tags: Array[String] = []
	var strength: Array[int] = []
	var highest_strength: int = 0
	
	var entry_counter: int = 1
	
	for entry in parse_string.split(" "):
		if entry_counter % 2 == 0: # even pares
			strength.append(int(entry)) 
		else: # Odds impares
			tags.append(entry)
		entry_counter += 1
	
	highest_strength = strength.max()
	
	entry_counter = 0
	
	for strength_value in strength:
		var percent_strength: int = roundi(strength_value * 100 / float(highest_strength))
		
		if not return_dictionary.has(str(percent_strength)):
			return_dictionary[str(percent_strength)] = []
		
		return_dictionary[str(percent_strength)].append(tags[entry_counter])
		entry_counter += 1
	
	return return_dictionary


func format_nested_list(input: String) -> String:
	var output: String = ""
	var open_lists: int = 0
	
	var lines: Array = input.split("\n")
	for line in lines:
		var stripped_line: String = line.strip_edges()
		var level: int = 0
		
		while stripped_line.begins_with("*"):
			level += 1
			stripped_line = stripped_line.substr(1)
		
		if level < open_lists:
			for _n in range(open_lists - level):
				output += "[/ul]" + "\n"
			open_lists = level

		if level > open_lists:
			for _n in range(level - open_lists):
				output += "[ul]\n"
			open_lists = level
			
		output += stripped_line.strip_edges() + "\n"
	
	for _n in open_lists:
		output += "[/ul]"

	return output




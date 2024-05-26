extends Node


signal image_created(image: Texture2D)
signal hydrus_connected(is_connected)
signal permissions_received(access_key: String)

const LOCAL_ADDRESS: String = "http://127.0.0.1:{0}/"
const HEADER: String = "Hydrus-Client-API-Access-Key:"

# Endpoints
const THUMBNAILS: String = "get_files/thumbnail?file_id="
const SEARCH: String = "get_files/search_files?tags="
const FILE: String = "get_files/file?file_id="

enum IMAGE_TYPE {
	THUMBNAIL,
	FILE,
}

var requester: HTTPRequest

var api_key: String = ""
var api_port: int = 0

var connected: bool = false

var work_queue: Array[String] = []


func _ready():
	api_port = Tagger.hydrus_port
	api_key = Tagger.hydrus_key
	requester = HTTPRequest.new()
	requester.timeout = 10
	add_child(requester)
	if not api_key.is_empty():
		connect_to_hydrus()
	
	#await connect_to_hydrus()
	#var ids = await search(["male/male"], 2)
	#print_debug(await get_thumbnails(ids))


func connect_to_hydrus(port := api_port, key := api_key) -> void:
	if key.is_empty():
		return
	var access_string = LOCAL_ADDRESS.format([port]) + "verify_access_key"
	requester.request(access_string, get_headers(key))
	
	var response: Array = await requester.request_completed

	var headers = parse_headers(response[2])

	if response[0] != OK:
		Tagger.log_message("Hydrus request response: " + str(response[0]), Tagger.LoggingLevel.ERROR)
	else:
		if headers.server.begins_with("client api"):
			var json = JSON.new()
			json.parse(response[3].get_string_from_utf8())
			var parsed = json.get_data()
			#print(parsed)
			if response[1] == 200:
				if parsed["basic_permissions"].has(3.0):
					connected = true
					Tagger.log_message("Successfully connected to Hydrus")
				else:
					Tagger.log_message(
						"Key doesn't have Search/Fetch permissions (3)",
						Tagger.LoggingLevel.WARNING
					)
			else:
				Tagger.log_message(
					"Hydrus Exception: " + str(parsed["error"]) + "\n, " + str(parsed["exception_type"]),
					Tagger.LoggingLevel.WARNING
				)
	
	hydrus_connected.emit(connected)


func parse_headers(headers_array: Array) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func get_headers(access_key: String = api_key) -> PackedStringArray:
	return PackedStringArray([HEADER + access_key])


## Returns a Dictionary with a 2DTexture as value and the id as key.
func get_thumbnails(ids_array: Array) -> Dictionary:
	if not connected:
		return {}
	
	var url_building: String = LOCAL_ADDRESS.format([api_port]) + THUMBNAILS
	
	var return_dictionary: Dictionary = {}
	var headers := get_headers()
	
	for pic_id in ids_array:
		ImageLoader.load_web_image.call_deferred(url_building + str(pic_id), headers)
		
		var response_array = await ImageLoader.http_responded
		
		if not response_array[0]: # If successful
			continue
		
		return_dictionary[str(pic_id)] = response_array[1]
	
	return return_dictionary


func get_file(file_id: int) -> Texture2D:
	if not connected:
		return null
	
	var url: String = LOCAL_ADDRESS.format([api_port]) + FILE + str(file_id)
	
	ImageLoader.load_full_image.call_deferred(url, get_headers())
	
	var response_array = await ImageLoader.full_image_responded
		
	if not response_array[0]: # If successful
		return null
	
	return response_array[1]


func create_texture(image_data: PackedByteArray, image_format: String) -> Texture2D:
	var image := Image.new()
	var return_texture: Texture2D = null
	
	if image_format == "jpeg" or image_format == "jpg":
		image.load_jpg_from_buffer(image_data)
		image.generate_mipmaps()
		return_texture = ImageTexture.create_from_image(image)
	elif image_format == "png":
		image.load_png_from_buffer(image_data)
		image.generate_mipmaps()
		return_texture = ImageTexture.create_from_image(image)
	elif image_format == "gif":
		return_texture =  GifManager.animated_texture_from_buffer(image_data, 256)
	
	return return_texture


func is_valid_headers(header_data: Dictionary) -> bool:
	if header_data.has("server"):
		if typeof(header_data.server) == 4:
			if header_data.server.begins_with("client api"):
				return true
	return false


func search(tags_array: Array[String], tag_count: int) -> Array:
	if not connected:
		return []
	
	var request_url: String = LOCAL_ADDRESS.format([api_port]) + SEARCH
	
	if not tags_array.is_empty():
		var tags_to_format: String = "["
		for tag in tags_array:
			#var tag_to_check = parse_tag(tag)
			tags_to_format += "\"" +  parse_tag(tag) + "\","
		tags_to_format += "\"system:limit={0}\",".format([str(tag_count)])
		tags_to_format += "\"system:filetype=image,gif\","
		tags_to_format += "\"system:archive\""
		tags_to_format += "]"
		request_url += tags_to_format.uri_encode() + "&"
	request_url += "file_sort_type=4"
	requester.request(request_url, get_headers())
	
	var response = await requester.request_completed
	
	if response[0] != OK or response[1] != 200:
		Tagger.log_message(
			"API response was not 0, 200\nResponse: " + str(response[0]) + ", " + str(response[1]),
			Tagger.LoggingLevel.WARNING
		)
		return[]
	
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var parsed = json.get_data()
	
	return parsed["file_ids"]


func parse_tag(input_tag: String) -> String:
	var final_tag: String = ""
	
	if input_tag.begins_with("-"):
		input_tag = input_tag.trim_prefix("-")
		final_tag += "-"
	
	var aliased_tag = Tagger.get_alias(input_tag)
	
	if Tagger.has_tag(aliased_tag):
		var tag_class: Tagger.Categories = Tagger.get_tag(aliased_tag).category
		
		if tag_class == Tagger.Categories.ARTIST:
			final_tag += "creator:" + aliased_tag
		elif tag_class == Tagger.Categories.SPECIES:
			final_tag += "species:" + aliased_tag
		elif tag_class == Tagger.Categories.COPYRIGHT:
			final_tag += "series:" + aliased_tag
		elif tag_class == Tagger.Categories.CHARACTER:
			final_tag += "character:" + aliased_tag
		elif tag_class == Tagger.Categories.META:
			final_tag += "meta:" + aliased_tag
		elif tag_class == Tagger.Categories.LORE:
			final_tag += "lore:" + aliased_tag
		else:
			final_tag += aliased_tag
	else:
		final_tag += aliased_tag
	
	return final_tag


func request_permissions(port: int) -> void:
	var request_url: String = LOCAL_ADDRESS.format([str(port)]) + "request_new_permissions?name=TagIt%20-%20Tag%20List%20Assistant&basic_permissions=[3]"
	requester.request(request_url)
	var client_response: Array = await requester.request_completed
	
	Tagger.log_message("Hydrus HTTP response: " + str(client_response[0]) + "\nHydrus response: " + str(client_response[1]))
	
	if client_response[0] != OK or client_response[1] != 200:
		permissions_received.emit("")
		return
	var json: JSON = JSON.new()
	json.parse(client_response[3].get_string_from_utf8())
	permissions_received.emit(json.data["access_key"])



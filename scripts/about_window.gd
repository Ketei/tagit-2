extends Control


@onready var version_request: HTTPRequest = $HTTPRequest

@onready var version_label: Label = $PanelContainer/HBoxContainer/MarginContainer/DataContainer/HBoxContainer/VersionLabel
@onready var close_button: Button = $PanelContainer/HBoxContainer/MarginContainer/DataContainer/HBoxContainer2/Label/CloseButton
@onready var update_status: Label = $PanelContainer/HBoxContainer/MarginContainer/DataContainer/VersionChecker/UpdateStatus


func _ready():
	if visible:
		visible = false
	version_label.text = Tagger.VERSION
	close_button.pressed.connect(on_close_pressed)
	
	var error = version_request.request(
			"https://api.github.com/repos/Ketei/tagit-2/releases/latest"
	)
	var response = await version_request.request_completed
	if error != OK:
		version_request.queue_free()
		return
	
	var json_decoder = JSON.new()
	json_decoder.parse(response[3].get_string_from_utf8())
	
	if not json_decoder.data is Dictionary:
		version_request.queue_free()
		return
	
	if json_decoder.data.has("message") and json_decoder.data["message"].to_lower() == "not found":
		version_request.queue_free()
		return
	
	var version_text: String = json_decoder.data["tag_name"].trim_prefix("v")
	
	var online_version_array: Array[int] = []
	var local_version_array: Array[int] = []

	for version in version_text.split(".", false):
		online_version_array.append(int(version))
	
	for c_version in Tagger.VERSION.split(".", false):
		local_version_array.append(int(c_version))
	
	set_new_version_available(
			local_version_array < online_version_array,
			version_text)
	
	version_request.queue_free()


func on_close_pressed() -> void:
	visible = false


func set_new_version_available(update_available: bool, update_version: String = "") -> void:
	if update_available:
		update_status.text = "Update {0} is available.".format([update_version])
		update_status.add_theme_color_override("font_color", Color(1, 0.784, 0))
	else:
		update_status.text = "You're using the latest version."
		update_status.add_theme_color_override("font_color", Color(0.588, 0.98, 0))


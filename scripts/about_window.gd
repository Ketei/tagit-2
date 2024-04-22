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
	
	var version_text: String = json_decoder.data["tag_name"]
	
	var version_split: Array[int] = []
	var current_version_split: Array[int] = []

	for version in version_text.split(".", false):
		version_split.append(int(version))
	
	for c_version in Tagger.VERSION.split(".", false):
		current_version_split.append(int(c_version))
	
	if current_version_split[0] < version_split[1]:
		set_new_version_available(true, version_text)
	elif current_version_split[1] < version_split[1]:
		set_new_version_available(true, version_text)
	elif current_version_split[2] < version_split[2]:
		set_new_version_available(true, version_text)
	else:
		set_new_version_available(false)
	version_request.queue_free()


func on_close_pressed() -> void:
	visible = false


func set_new_version_available(update_available: bool, update_version: String = "") -> void:
	if update_available:
		update_status.text = "Update {0} is available.".format([update_version])
	else:
		update_status.text = "You're using the latest version."


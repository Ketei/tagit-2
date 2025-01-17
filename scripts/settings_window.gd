class_name SettingsWindow
extends Control

const PACK_INSTALL_WINDOW = preload("res://scenes/pack_install_window.tscn")
const WEB_INSTALL_WINDOW = preload("res://scenes/web_install_window.tscn")

var pack_installer: PakInstallWindow
var website_installer: WebsiteInstallWindow

@onready var hydrus_connect_button: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Wiki/WikiContainer/HydrusContainer/HydrusButtons/HydrusConnectButton
@onready var browse_path_button: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/General/GeneralContainer/DatabaseContainer/HBoxContainer/BrowsePathButton
@onready var reload_tag_button: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/ButtonsContainer/VBoxContainer/ReloadTagButton
@onready var open_tag_folder_btn: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/ButtonsContainer/VBoxContainer2/OpenTagFolderBtn
@onready var install_pak_button: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/ButtonsContainer/VBoxContainer2/InstallPakButton
@onready var install_website_button: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/ButtonsContainer/VBoxContainer2/InstallWebsiteButton
@onready var clear_tag_map_button: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/ButtonsContainer/VBoxContainer/ClearTagMapButton
@onready var hydrus_request_button: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Wiki/WikiContainer/HydrusContainer/HydrusButtons/RequestHydrus

@onready var autofill_enabled: CheckButton = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/General/GeneralContainer/FunctionallityToggle/AutofillEnabled
@onready var wiki_esix_search: CheckButton = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Wiki/WikiContainer/WikiESixSearch
@onready var include_invalid_check: CheckButton = $"MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Tag List/TaglistContainer/InvalidInclude/IncludeInvalidCheck"
@onready var online_check_button: CheckButton = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/General/GeneralContainer/OnlineContainer/OnlineCheckButton
@onready var danger_buttons_check: CheckButton = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/ButtonsContainer/VBoxContainer/DangerButtonsCheck
@onready var remove_after_use: CheckButton = $"MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Tag List/TaglistContainer/RemoveOnUse/RemoveAfterUse"
@onready var blacklist_after_remove: CheckButton = $"MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Tag List/TaglistContainer/RemoveOnUse/BlacklistAfterRemove"

@onready var db_path_line_edit: LineEdit = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/General/GeneralContainer/DatabaseContainer/HBoxContainer/DBPathLineEdit
@onready var key_secret: LineEdit = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Wiki/WikiContainer/HydrusContainer/HydrusFields/KeyContainer/KeySecret

@onready var folder_dialog: FileDialog = $FolderDialog
@onready var accept_dialog: AcceptDialog = $AcceptDialog

@onready var port_spinbox: SpinBox = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/Wiki/WikiContainer/HydrusContainer/HydrusFields/PortContainer/PortSpinbox
@onready var confidence_spin_box: SpinBox = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/General/GeneralContainer/SuggestContainer/ConfidenceSpinBox

@onready var invalid_list: TagItemList = $"MarginContainer/HBoxContainer/BlackListTabs/Invalid Tags/VBoxContainer/InvalidList"
@onready var sug_black_list: TagItemList = $"MarginContainer/HBoxContainer/BlackListTabs/Suggestion Blacklist/VBoxContainer/SugBlackList"
@onready var constants_list: TagItemList = $"MarginContainer/HBoxContainer/BlackListTabs/Constant Tags/VBoxContainer/ConstantsList"
@onready var sites_option_menu: SitesOptionButton = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/General/GeneralContainer/DefaultSite/SitesOptionMenu

@onready var algoritm_button: OptionButton = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/TabContainer/General/GeneralContainer/AlgorithmType/AlgorithmButton

@onready var export_json_btn: Button = $MarginContainer/HBoxContainer/MarginContainer/LeftBox/ExportJsonBtn

# Called when the node enters the scene tree for the first time.
func _ready():
	confidence_spin_box.value = Tagger.suggestion_confidence
	db_path_line_edit.text = Tagger.database_path
	db_path_line_edit.tooltip_text = Tagger.database_path
	remove_after_use.button_pressed = Tagger.remove_after_use
	blacklist_after_remove.button_pressed = Tagger.blacklist_after_remove
	algoritm_button.select(Tagger.search_algorithm)
	
	if Tagger.remove_after_use:
		blacklist_after_remove.disabled = false
	
	port_spinbox.value = Tagger.hydrus_port
	key_secret.text = Tagger.hydrus_key
	
	if not Tagger.default_site.is_empty():
		sites_option_menu.select_with_key(Tagger.default_site)
	else:
		Tagger.default_site = sites_option_menu.get_selected_site_key()
	
	online_check_button.button_pressed = Tagger.search_online_suggestions
	include_invalid_check.button_pressed = Tagger.include_invalid
	
	if not Hydrus.api_key.is_empty():
		on_hydrus_connect_pressed()
	
	algoritm_button.item_selected.connect(on_algoritm_selected)
	folder_dialog.dir_selected.connect(on_folder_selected)
	browse_path_button.pressed.connect(on_browse_folder_pressed)
	hydrus_connect_button.pressed.connect(on_hydrus_connect_pressed)
	reload_tag_button.pressed.connect(on_reload_tags_pressed)
	confidence_spin_box.value_changed.connect(on_confidence_changed)
	open_tag_folder_btn.pressed.connect(on_open_tag_folder_pressed)
	online_check_button.toggled.connect(on_online_toggled)
	install_pak_button.pressed.connect(on_install_pak_pressed)
	install_website_button.pressed.connect(on_install_website_pressed)
	autofill_enabled.toggled.connect(on_autofill_toggled)
	wiki_esix_search.toggled.connect(on_online_wiki_toggled)
	sites_option_menu.item_selected.connect(on_default_site_changed)
	include_invalid_check.toggled.connect(on_load_invalid_changed)
	danger_buttons_check.toggled.connect(on_danger_toggled)
	clear_tag_map_button.pressed.connect(on_clear_tagmap_pressed)
	remove_after_use.toggled.connect(on_remove_after_use)
	blacklist_after_remove.toggled.connect(on_blacklist_after_remove)
	hydrus_request_button.pressed.connect(on_request_pressed)
	export_json_btn.pressed.connect(on_export_new_pressed)


func on_algoritm_selected(algorithm_id: int) -> void:
	Tagger.search_algorithm = algorithm_id as Tagger.CompareAlgorithms


func on_request_pressed() -> void:
	disable_hydrus_connect_buttons()
	Hydrus.request_permissions(int(port_spinbox.value))
	
	var access_key: String = await Hydrus.permissions_received
	
	if not access_key.is_empty():
		key_secret.text = access_key
		Tagger.queue_notification(
			"Received access key.
			Apply permissions on Hydrus then
			press \"Connect to Hydrus\"",
			"Key Received")
	
	disable_hydrus_connect_buttons(false)


func on_remove_after_use(is_toggled: bool) -> void:
	Tagger.remove_after_use = is_toggled


func on_blacklist_after_remove(is_toggled: bool) -> void:
	Tagger.blacklist_after_remove = is_toggled


func on_clear_tagmap_pressed() -> void:
	Tagger.clear_tag_map()


func on_danger_toggled(is_toggled: bool) -> void:
	reload_tag_button.disabled = not is_toggled
	clear_tag_map_button.disabled = not is_toggled


func on_load_invalid_changed(is_toggled: bool) -> void:
	Tagger.include_invalid = is_toggled


func on_default_site_changed(_index: int) -> void:
	Tagger.default_site = sites_option_menu.get_selected_site_key()


func on_autofill_toggled(is_toggled: bool) -> void:
	Tagger.autofill_enabled = is_toggled


func on_online_wiki_toggled(is_toggled: bool) -> void:
	Tagger.open_e6_on_wiki_link = is_toggled


func on_install_pak_pressed() -> void:
	pack_installer = PACK_INSTALL_WINDOW.instantiate()
	add_child(pack_installer)


func on_install_website_pressed() -> void:
	website_installer = WEB_INSTALL_WINDOW.instantiate()
	add_child(website_installer)


func on_online_toggled(is_toggled: bool) -> void:
	Tagger.search_online_suggestions = is_toggled


func on_open_tag_folder_pressed() -> void:
	OS.shell_open(Tagger.database_path + Tagger.TAGS_PATH)


func on_reload_tags_pressed() -> void:
	Tagger.reload_tags()


func on_confidence_changed(new_value: float) -> void:
	Tagger.suggestion_confidence = int(new_value)


func on_hydrus_connect_pressed() -> void:
	hydrus_connect_button.disabled = true
	hydrus_connect_button.text = "Connecting..."
	Hydrus.connect_to_hydrus(int(port_spinbox.value), key_secret.text)
	if await Hydrus.hydrus_connected:
		Tagger.hydrus_port = int(port_spinbox.value)
		Tagger.hydrus_key = key_secret.text
		Hydrus.api_port = Tagger.hydrus_port
		Hydrus.api_key = Tagger.hydrus_key
		hydrus_connect_button.text = "Connected!!!"
		await get_tree().create_timer(2.0).timeout
		hydrus_connect_button.text = "Connect to Hydrus"
		hydrus_connect_button.disabled = false
	else:
		hydrus_connect_button.text = "Failed to connect"
		await get_tree().create_timer(2.0).timeout
		hydrus_connect_button.text = "Connect to Hydrus"
		hydrus_connect_button.disabled = false


func on_browse_folder_pressed() -> void:
	folder_dialog.show()


func on_folder_selected(folder_path: String) -> void:
	Tagger.database_path = folder_path
	db_path_line_edit.text = Tagger.database_path
	db_path_line_edit.tooltip_text = Tagger.database_path
	accept_dialog.show()
	await accept_dialog.confirmed
	Tagger.database_changed()


func disable_hydrus_connect_buttons(set_disabled := true) -> void:
	hydrus_request_button.disabled = set_disabled
	hydrus_connect_button.disabled = set_disabled


func on_export_new_pressed() -> void:
	var dialog_browser := FileDialog.new()
	dialog_browser.access = FileDialog.ACCESS_FILESYSTEM
	dialog_browser.use_native_dialog = true
	dialog_browser.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog_browser.add_filter("*.json", "JSON Files")
	dialog_browser.file_selected.connect(export_for_new.bind(dialog_browser))
	dialog_browser.canceled.connect(dialog_browser.queue_free)
	dialog_browser.show()


func export_for_new(path: String, browser: FileDialog):
	const categories: Array[Dictionary] = [
		{
			"color": "ffffff",
			"description": "A category for tags that lacks specificity.",
			"icon": 0,
			"name": "Generic"
		},
		{
			"color": "ffffff",
			"description": "Tags that represent artists.",
			"icon": 0,
			"name": "Artist"
		},
		{
			"color": "ffffff",
			"description": "A tag referring to something belonging to an IP",
			"name": "Copyright",
			"icon": 0
		},
		{
			"color": "ffffff",
			"description": "A representation of an individual in a fictional or dramatic work.",
			"icon": 0,
			"name": "Character"
		},
		{
			"color": "ffffff",
			"description": "A group of closely related organisms that are very similar to each other and are capable of interbreeding and producing fertile offspring",
			"icon": 0,
			"name": "Species"
		},
		{
			"color": "ffffff",
			"description": "The anatomical and physiological configurations of a character.",
			"icon": 0,
			"name": "Body"
		},
		{
			"color": "ffffff",
			"description": " The state or process of acting or doing something",
			"icon": 0,
			"name": "Action"
		},
		{
			"color": "ffffff",
			"description": "An activity that can involve kissing, touching, masturbation, vaginal, oral, or anal sex/penetration in any position.",
			"icon": 0,
			"name": "Sex"
		},
		{
			"color": "ffffff",
			"description": "Any material thing perceptible by one or more of the senses, especially by vision or touch. ",
			"icon": 0,
			"name": "Object"
		},
		{
			"color": "ffffff",
			"description": "Any object that can be worn on the body as apparel or accessory",
			"icon": 0,
			"name": "Clothing"
		},
		{
			"color": "ffffff",
			"description": " A place that holds distinguishing features",
			"icon": 0,
			"name": "Location"
		},
		{
			"color": "ffffff",
			"description": "A tag describing a property of the file.",
			"icon": 0,
			"name": "Meta"
		},
		{
			"color": "ffffff",
			"description": "A tag for describing a character or situation even though visually can't be confirmed.",
			"icon": 0,
			"name": "Lore"
		},
		{
			"color": "ffffff",
			"description": "Tags describing physical, social or moral properties of something",
			"icon": 0,
			"name": "Properties"}]
	
	var tags: Array[Dictionary] = []
	
	for tag in Tagger.loaded_tags:
		for tag_name in Tagger.loaded_tags[tag]:
			var tag_load: Tag = Tagger.get_tag(tag_name)
			var category: int = old_to_new(tag_load.category)
			tags.append({
				"aliases": tag_load.aliases,
				"category": category,
				"group": -1,
				"group_suggestions": [],
				"is_valid": not Tagger.has_invalid_tag(tag_name),
				"name": tag_name,
				"parents": tag_load.parents,
				"priority": tag_load.tag_priority,
				"suggestions": tag_load.suggestions,
				"tooltip": tag_load.tooltip,
				"wiki": tag_load.wiki_entry,
				})
	
	var full_data: Dictionary = {
		"categories": categories,
		"groups": [],
		"icons": [],
		"tags": tags,
		"type": 1}
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file == null:
		Tagger.log_message("Couldn't open JSON file on path: " + path, Tagger.LoggingLevel.ERROR)
		Tagger.queue_notification(
			"Couldn't export tags",
			"Error")
	else:
		file.store_string(JSON.stringify(full_data, "\t"))
		Tagger.queue_notification(
			"Tags Exported",
			"Success")
		file.close()
	
	browser.queue_free()


func old_to_new(from: int) -> int:
	match from:
		Tagger.Categories.GENERAL:
			return 0
		Tagger.Categories.ARTIST:
			return 1
		Tagger.Categories.COPYRIGHT:
			return 2
		Tagger.Categories.CHARACTER:
			return 3
		Tagger.Categories.SPECIES:
			return 4
		Tagger.Categories.GENDER:
			return 5
		Tagger.Categories.BODY_TYPES:
			return 5
		Tagger.Categories.ANATOMY:
			return 5
		Tagger.Categories.MARKINGS:
			return 5
		Tagger.Categories.POSES_AND_STANCES:
			return 6
		Tagger.Categories.ACTIONS_AND_INTERACTIONS:
			return 6
		Tagger.Categories.SEX_AND_POSITIONS:
			return 7
		Tagger.Categories.PENETRATION:
			return 7
		Tagger.Categories.FLUIDS:
			return 8
		Tagger.Categories.EXPRESSIONS:
			return 6
		Tagger.Categories.COLORS:
			return 13
		Tagger.Categories.OBJECTS:
			return 8
		Tagger.Categories.CLOTHING:
			return 9
		Tagger.Categories.ACCESSORIES:
			return 9
		Tagger.Categories.PROFESSION:
			return 13
		Tagger.Categories.META:
			return 11
		Tagger.Categories.LOCATION:
			return 10
		Tagger.Categories.FURNITURE:
			return 8
		Tagger.Categories.LORE:
			return 12
		_:
			return 0

class_name SettingsWindow
extends Control

const PACK_INSTALL_WINDOW = preload("res://scenes/pack_install_window.tscn")
const WEB_INSTALL_WINDOW = preload("res://scenes/web_install_window.tscn")

var pack_installer: PakInstallWindow
var website_installer: WebsiteInstallWindow

@onready var exit_button: Button = $MarginContainer/HBoxContainer/LeftSettings/ExitButton
@onready var hydrus_connect_button: Button = $MarginContainer/HBoxContainer/LeftSettings/HydrusContainer/HydrusConnectButton
@onready var browse_path_button: Button = $MarginContainer/HBoxContainer/LeftSettings/HBoxContainer/HBoxContainer/BrowsePathButton
@onready var reload_tag_button: Button = $MarginContainer/HBoxContainer/LeftSettings/ButtonsContainer/VBoxContainer/ReloadTagButton
@onready var open_tag_folder_btn: Button = $MarginContainer/HBoxContainer/LeftSettings/ButtonsContainer/VBoxContainer2/OpenTagFolderBtn
@onready var install_pak_button: Button = $MarginContainer/HBoxContainer/LeftSettings/ButtonsContainer/VBoxContainer2/InstallPakButton
@onready var install_website_button: Button = $MarginContainer/HBoxContainer/LeftSettings/ButtonsContainer/VBoxContainer2/InstallWebsiteButton
@onready var clear_tag_map_button: Button = $MarginContainer/HBoxContainer/LeftSettings/ButtonsContainer/VBoxContainer/ClearTagMapButton

@onready var autofill_enabled: CheckButton = $MarginContainer/HBoxContainer/LeftSettings/FunctionallityToggle/AutofillEnabled
@onready var wiki_esix_search: CheckButton = $MarginContainer/HBoxContainer/LeftSettings/FunctionallityToggle/WikiESixSearch
@onready var include_invalid_check: CheckButton = $MarginContainer/HBoxContainer/LeftSettings/InvalidInclude/IncludeInvalidCheck
@onready var online_check_button: CheckButton = $MarginContainer/HBoxContainer/LeftSettings/OnlineContainer/OnlineCheckButton
@onready var danger_buttons_check: CheckButton = $MarginContainer/HBoxContainer/LeftSettings/ButtonsContainer/VBoxContainer/DangerButtonsCheck
@onready var remove_after_use: CheckButton = $MarginContainer/HBoxContainer/LeftSettings/HBoxContainer2/RemoveAfterUse
@onready var blacklist_after_remove: CheckButton = $MarginContainer/HBoxContainer/LeftSettings/HBoxContainer2/BlacklistAfterRemove

@onready var db_path_line_edit: LineEdit = $MarginContainer/HBoxContainer/LeftSettings/HBoxContainer/HBoxContainer/DBPathLineEdit

@onready var folder_dialog: FileDialog = $FolderDialog
@onready var accept_dialog: AcceptDialog = $AcceptDialog

@onready var port_spinbox: SpinBox = $MarginContainer/HBoxContainer/LeftSettings/HydrusContainer/HydrusFields/PortContainer/PortSpinbox
@onready var confidence_spin_box: SpinBox = $MarginContainer/HBoxContainer/LeftSettings/SuggestContainer/ConfidenceSpinBox

@onready var key_secret: LineEdit = $MarginContainer/HBoxContainer/LeftSettings/HydrusContainer/HydrusFields/KeyContainer/KeySecret

@onready var invalid_list: TagItemList = $"MarginContainer/HBoxContainer/BlackListTabs/Invalid Tags/VBoxContainer/InvalidList"
@onready var sug_black_list: TagItemList = $"MarginContainer/HBoxContainer/BlackListTabs/Suggestion Blacklist/VBoxContainer/SugBlackList"
@onready var constants_list: TagItemList = $"MarginContainer/HBoxContainer/BlackListTabs/Constant Tags/VBoxContainer/ConstantsList"
@onready var sites_option_menu: SitesOptionButton = $MarginContainer/HBoxContainer/LeftSettings/DefaultSite/SitesOptionMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	confidence_spin_box.value = Tagger.suggestion_confidence
	db_path_line_edit.text = Tagger.database_path
	db_path_line_edit.tooltip_text = Tagger.database_path
	remove_after_use.button_pressed = Tagger.remove_after_use
	blacklist_after_remove.button_pressed = Tagger.blacklist_after_remove
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
	
	exit_button.pressed.connect(on_exit_pressed)
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
	#reload_tag_button.disabled = true
	Tagger.reload_tags()
	#await Tagger.aliases_reloaded
	#reload_tag_button.disabled = false


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


func on_exit_pressed() -> void:
	hide()


func on_browse_folder_pressed() -> void:
	folder_dialog.show()


func on_folder_selected(folder_path: String) -> void:
	Tagger.database_path = folder_path
	db_path_line_edit.text = Tagger.database_path
	db_path_line_edit.tooltip_text = Tagger.database_path
	accept_dialog.show()
	await accept_dialog.confirmed
	Tagger.database_changed()


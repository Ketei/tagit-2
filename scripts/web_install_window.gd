class_name WebsiteInstallWindow
extends PanelContainer


var web_load: WebsiteResource = null

@onready var browse_button: Button = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/BrowserContainer/BrowseContainer/BrowseButton
@onready var cancel_button: Button = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/ButtonContainer/CancelButton
@onready var install_button: Button = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/ButtonContainer/InstallButton
@onready var error_label: Label = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/BrowserContainer/ErrorLabel
@onready var name_line_edit: LineEdit = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/PackData/PackName/NameLineEdit
@onready var author_line_edit: LineEdit = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/PackData/AuthorInfo/AuthorLineEdit
@onready var pack_info: TextEdit = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/PackData/PackInfo

@onready var file_dialog: FileDialog = $FileDialog
@onready var pack_installed: AcceptDialog = $PackInstalled

# Called when the node enters the scene tree for the first time.
func _ready():
	browse_button.pressed.connect(on_browse_pressed)
	file_dialog.file_selected.connect(on_file_selected)
	install_button.pressed.connect(on_install_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_browse_pressed() -> void:
	file_dialog.show()


func on_file_selected(file_path: String) -> void:
	var resource_preload = ResourceLoader.load(file_path, "WebsiteResource")
	
	if resource_preload != null and resource_preload is WebsiteResource:
		web_load = resource_preload
		name_line_edit.text = web_load.website_name
		author_line_edit.text = web_load.website_address
		pack_info.text = web_load.website_desc
		error_label.text = "Valid file selected."
		install_button.disabled = false


func on_install_pressed() -> void:
	Tagger.custom_sites[web_load.website_id] = {
		"name": web_load.website_name,
		"whitespace": web_load.website_whitespace,
		"separator": web_load.website_separator
	}
	
	Tagger.loaded_sites[web_load.website_id] = {
		"name": web_load.website_name,
		"whitespace": web_load.website_whitespace,
		"separator": web_load.website_separator
	}
	
	clear_all()
	web_load = null
	install_button.disabled = true
	Tagger.websites_updated.emit()
	pack_installed.show()


func clear_all() -> void:
	name_line_edit.clear()
	error_label.text = "No valid file selected."
	author_line_edit.clear()
	pack_info.clear()


func on_cancel_pressed() -> void:
	queue_free()


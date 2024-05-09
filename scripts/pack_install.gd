class_name PakInstallWindow
extends PanelContainer

@onready var browse_button: Button = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/BrowserContainer/BrowseContainer/BrowseButton
@onready var file_dialog: FileDialog = $FileDialog

@onready var error_label: Label = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/BrowserContainer/ErrorLabel

@onready var author_line_edit: LineEdit = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/PackData/AuthorInfo/AuthorLineEdit
@onready var tag_count_line_edit: LineEdit = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/PackData/TagNumber/TagCountLineEdit
@onready var name_line_edit: LineEdit = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/PackData/PackName/NameLineEdit

@onready var pack_info: TextEdit = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/PackContainer/PackData/PackInfo

@onready var cancel_button: Button = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/ButtonContainer/CancelButton
@onready var install_button: Button = $CenterContainer/PakInstaller/MarginContainer/VBoxContainer/ButtonContainer/InstallButton

@onready var pack_installed: AcceptDialog = $PackInstalled

var tagger_load: TagPak = null


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
	var resource_preload: TagPak = ResourceLoader.load(file_path, "TagPak")
	
	if resource_preload != null and resource_preload is TagPak:
		tagger_load = resource_preload
		name_line_edit.text = tagger_load.pack_name
		error_label.text = "Valid pack selected."
		author_line_edit.text = tagger_load.pack_author
		pack_info.text = tagger_load.pack_description
		tag_count_line_edit.text = str(tagger_load.included_tags.size())
		install_button.disabled = false


func on_install_pressed() -> void:
	var custom_folder: bool = not tagger_load.subfolder.is_empty()
	var pack_path: String = Tagger.database_path + Tagger.TAGS_PATH
	
	if custom_folder:
		pack_path += tagger_load.subfolder + "/"
	
	if custom_folder:
		if DirAccess.dir_exists_absolute(pack_path):
			OS.move_to_trash(pack_path)
			DirAccess.make_dir_absolute(pack_path)
		else:
			DirAccess.make_dir_recursive_absolute(pack_path)
	
	for type in tagger_load.pack_tag_map:
		if not Tagger.tag_map.has(type):
			Tagger.tag_map[type] = {
				"name": tagger_load.pack_tag_map[type]["name"],
				"desc": tagger_load.pack_tag_map[type]["desc"],
				"categories": {}
				}
		
		for category in tagger_load.pack_tag_map[type]["categories"]:
			if not Tagger.tag_map[type]["categories"].has(category):
				Tagger.tag_map[type]["categories"][category] = {
					"name": tagger_load.pack_tag_map[type]["categories"][category]["name"],
					"desc": tagger_load.pack_tag_map[type]["categories"][category]["desc"],
					"tags": {}
				}
			
			for tag in tagger_load.pack_tag_map[type]["categories"][category]["tags"]:
				Tagger.tag_map[type]["categories"][category]["tags"][tag] = tagger_load.pack_tag_map[type]["categories"][category]["tags"][tag]
	
	for invalid_tag in tagger_load.invalid_tags:
		Tagger.add_invalid_tag(invalid_tag)
	
	for tag_dict:Dictionary in tagger_load.included_tags:
		var new_tag := Tag.new()
		new_tag.tag = tag_dict["tag"]
		new_tag.tag_id = tag_dict["tag_id"]
		new_tag.file_name = tag_dict["file_name"]
		new_tag.tag_priority = tag_dict["priority"]
		new_tag.category = tag_dict["category"]
		new_tag.parents = tag_dict["parents"]
		new_tag.suggestions = tag_dict["suggestions"]
		new_tag.aliases = tag_dict["aliases"]
		new_tag.tooltip = tag_dict["tooltip"]
		new_tag.wiki_entry = tag_dict["wiki"]
		new_tag.smart_tags = tag_dict["smart"]
		
		ResourceSaver.save(
				new_tag,
				pack_path +
				new_tag.file_name)

	clear_all()
	tagger_load = null
	install_button.disabled = true
	Tagger.reload_tags() # <- Moved the updated signals here.
	pack_installed.show()


func clear_all() -> void:
	name_line_edit.clear()
	error_label.text = "No valid pack selected."
	author_line_edit.clear()
	pack_info.clear()
	tag_count_line_edit.clear()


func on_cancel_pressed() -> void:
	queue_free()



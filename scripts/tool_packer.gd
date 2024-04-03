class_name ToolPacker
extends Control


const PACK_FOLDER_INSTANCE = preload("res://scenes/pack_folder_instance.tscn")

@onready var subfolder_line_edit: LineEdit = $VBoxContainer/MarginContainer/HBoxContainer2/SubfolderLineEdit
#@onready var pack_name_line_edit: LineEdit = $VBoxContainer/HBoxContainer/PackNameLineEdit
#@onready var pack_desc_line_edit: LineEdit = $VBoxContainer/HBoxContainer/PackDescLineEdit
#@onready var tag_map_type_line_edit: LineEdit = $VBoxContainer/HBoxContainer/TagMapTypeLineEdit
#@onready var tag_map_cat_line_edit: LineEdit = $VBoxContainer/HBoxContainer/TagMapCatLineEdit


@onready var create_subfolder_button: Button = $VBoxContainer/MarginContainer/HBoxContainer2/CreateSubfolderButton
@onready var pack_button: Button = $VBoxContainer/HBoxContainer/PackButton

@onready var tab_container: TabContainer = $VBoxContainer/TabContainer
@onready var save_file_dialog: FileDialog = $SaveFileDialog


func _ready():
	create_subfolder_button.pressed.connect(create_folder_instance)
	pack_button.pressed.connect(pack_it)
	save_file_dialog.dir_selected.connect(pack_and_save)


func create_folder_instance() -> void:
	var new_instance: PackFolderInstance = PACK_FOLDER_INSTANCE.instantiate()
	new_instance.name = subfolder_line_edit.text
	tab_container.add_child(new_instance)


func pack_it() -> void:
	save_file_dialog.show()


func pack_and_save(export_folder: String) -> void:
	var export_path: String = export_folder.replace("\\", "/") + "/"

	for folder_instance:PackFolderInstance in tab_container.get_children():
		var tag_pack: TagPak = TagPak.new()
		
		var create_mappak: bool = folder_instance.is_tagmap_enabled()
		var pack_type: String = folder_instance.get_pack_type()
		var pack_cat: String = folder_instance.get_pack_category()
		
		tag_pack.pack_author = "Ketei"
		
		tag_pack.pack_name = folder_instance.get_pack_name()
		tag_pack.pack_description = folder_instance.get_pack_desc()
		
		tag_pack.subfolder = folder_instance.name
		if create_mappak:
			tag_pack.pack_tag_map = {
				pack_type: {
					"name": "",
					"desc": "",
					"categories": {
						pack_cat: {
							"name": "",
							"desc": "",
							"tags": {}
						}
					}
				}
			}
		
		var instace_tags := folder_instance.get_paths_to_pack() # Arraystring
		
		for tag_path in instace_tags:
			var tag_load: Tag = load(tag_path)
			if create_mappak:
				tag_pack.pack_tag_map[pack_type]["categories"][pack_cat]["tags"][tag_load.tag.replace(" ", "_")] = {
					"name": DumbUtils.title_case(tag_load.tag),
					"desc": tag_load.tooltip,
					"tag": tag_load.tag
				}
			tag_pack.included_tags.append({
				"tag": tag_load.tag,
				"tag_id": tag_load.tag_id,
				"file_name": tag_load.file_name,
				"priority": tag_load.tag_priority,
				"category": tag_load.category,
				"parents": tag_load.parents,
				"suggestions": tag_load.suggestions,
				"aliases": tag_load.aliases,
				"tooltip": tag_load.tooltip,
				"wiki": tag_load.wiki_entry,
				"smart": tag_load.smart_tags
			})
		
		ResourceSaver.save(tag_pack, export_path + folder_instance.name + ".tres")


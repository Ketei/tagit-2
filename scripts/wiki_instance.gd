class_name WikiWindow
extends Control


const IMAGE_THUMBNAIL = preload("res://scenes/image_thumbnail.tscn")
# [title, category, parents, suggestions, priority]
const WIKI_BASE: String = "[center][b][color=e37a54][font_size=30]{0}[/font_size][/color][/b][/center]
[color=8eef97]
[ul]Category: [color=d2f9d6]{1}[/color]
Parents: [color=d2f9d6]{2}[/color]
Suggestions: [color=d2f9d6]{3}[/color]
Priority: [color=d2f9d6]{4}[/color][/ul]
[/color]
{5}"

@onready var full_image: TextureRect = $PanelContainer/SmoothScrollContainer/FullScreenView

@onready var full_screen_view: PanelContainer = $PanelContainer
@onready var thumbnail_container: HFlowContainer = $MarginContainer/VBoxContainer/WikiContainer/PanelContainer/SmoothScrollContainer/ThumbnailContainer
@onready var wiki_desc: RichTextLabel = $MarginContainer/VBoxContainer/WikiContainer/WikiSide/PanelContainer/MarginContainer/SmoothScrollContainer/WikiDesc

@onready var wiki_search: LineEdit = $MarginContainer/VBoxContainer/WikiContainer/WikiSide/LeftMenus/AutoSearch

@onready var close_button: Button = $MarginContainer/VBoxContainer/WikiContainer/WikiSide/CloseButton
@onready var search_button: Button = $MarginContainer/VBoxContainer/WikiContainer/WikiSide/LeftMenus/SearchButton
@onready var e_six_search: Button = $MarginContainer/VBoxContainer/WikiContainer/WikiSide/LeftMenus/ESixSearch

@onready var thumbnail_scroll_container: SmoothScrollContainer = $MarginContainer/VBoxContainer/WikiContainer/PanelContainer/SmoothScrollContainer
@onready var wiki_smooth_scroll_container: SmoothScrollContainer = $MarginContainer/VBoxContainer/WikiContainer/WikiSide/PanelContainer/MarginContainer/SmoothScrollContainer

@onready var pictures_panel: PanelContainer = $MarginContainer/VBoxContainer/WikiContainer/PanelContainer


func _ready():
	pictures_panel.visible = Tagger.load_images
	close_button.pressed.connect(on_exit_pressed)
	search_button.pressed.connect(on_local_search_pressed)
	wiki_search.text_submitted.connect(on_wiki_search_submit)
	e_six_search.pressed.connect(on_online_search_pressed)
	Tagger.image_view_toggled.connect(on_view_toggled)
	wiki_desc.meta_clicked.connect(on_meta_clicked)
	#auto_fill.item_submited.connect(on_wiki_search_submit)


func _unhandled_key_input(_event):
	if full_screen_view.visible and full_image.visible and Input.is_action_just_pressed("ui_cancel"):
		full_screen_view.hide() # This is shown when clicked
		full_image.hide() # This is shown when loaded


func on_online_search_pressed() -> void:
	var tag_to_search: String = wiki_search.text.strip_edges().to_lower()
	
	if tag_to_search.is_empty():
		return
	
	OS.shell_open(
		Tagger.get_online_wiki_url(tag_to_search)
	)


func on_local_search_pressed() -> void:
	on_wiki_search_submit(wiki_search.text)


func on_wiki_search_submit(tag_search: String) -> void:
	wiki_search.editable = false
	search_button.disabled = true
	if wiki_search.has_focus():
		wiki_search.release_focus()
	if search_button.has_focus():
		search_button.release_focus()
	var tag_to_search: String = Tagger.get_alias(
			tag_search.strip_edges().to_lower())
	
	if not Tagger.has_tag(tag_to_search):
		wiki_search.editable = true
		search_button.disabled = false
		return
	
	for child in thumbnail_container.get_children():
		child.queue_free()
	
	wiki_search.text = tag_to_search
	wiki_search.caret_column = wiki_search.text.length()
	
	var tag_to_load: Tag = Tagger.get_tag(tag_to_search)
	var parents_string: String = ""
	var suggestions_string: String = ""
	var aliases_string: String = ", ".join(tag_to_load.aliases)
	
	for parent in tag_to_load.parents:
		if Tagger.has_tag(parent):
			parents_string += "[url]" + parent + "[/url], "
		else:
			parents_string += parent + ", "
	parents_string = parents_string.left(-2)
	
	for suggestion in tag_to_load.suggestions:
		if Tagger.has_tag(suggestion):
			suggestions_string += "[url]" + suggestion + "[/url], "
		else:
			suggestions_string += suggestion + ", "
	suggestions_string = suggestions_string.left(-2)
	
# [title, category, parents, suggestions, priority, wiki]
	
	wiki_desc.text = WIKI_BASE.format(
			[
				tag_to_load.tag.to_upper(),
				Tagger.get_category_name(tag_to_load.category),
				parents_string,
				suggestions_string,
				str(tag_to_load.tag_priority),
				tag_to_load.wiki_entry
			])
	wiki_smooth_scroll_container.scroll_y_to(0, 0)
	if not aliases_string.is_empty():
		wiki_desc.text += "\n\n[color=8eef97]Aliases: [color=d2f9d6]{0}[/color][/color]".format([aliases_string])
	
	if Tagger.load_images and Hydrus.connected:
		var ids = await Hydrus.search([tag_to_search], Tagger.image_amount)
		var textures = await Hydrus.get_thumbnails(ids)
		
		for id in textures:
			create_thumbnail(textures[id], int(id))
	
	wiki_search.editable = true
	search_button.disabled = false
	
	if 0 < thumbnail_container.get_child_count():
		await get_tree().process_frame
		thumbnail_scroll_container.scroll_y_to(0, 0)


func on_exit_pressed() -> void:
	hide()


func on_thumbnail_pressed(thumb_id: int) -> void:
	if not Hydrus.connected:
		return
	full_screen_view.show()
	full_image.texture = await Hydrus.get_file(thumb_id)
	full_image.show()


func clear_wiki() -> void:
	wiki_desc.clear()
	wiki_search.clear()
	for child in thumbnail_container.get_children():
		child.queue_free()


func create_thumbnail(thumb_texture: Texture2D, image_id: int) -> void:
	var _new_thumbnail: ImageThumbnail = IMAGE_THUMBNAIL.instantiate()
	_new_thumbnail.texture = thumb_texture
	_new_thumbnail.file_id = image_id
	_new_thumbnail.thumbnail_pressed.connect(on_thumbnail_pressed)
	thumbnail_container.add_child(_new_thumbnail)


func on_view_toggled(is_toggled: bool) -> void:
	pictures_panel.visible = is_toggled


func on_meta_clicked(meta) -> void:
	var meta_string: String = str(meta)
	if Tagger.has_tag(meta_string):
		if not search_button.disabled:
			on_wiki_search_submit(meta_string)
	elif Tagger.open_e6_on_wiki_link:
		OS.shell_open(Tagger.E6_SEARCH_URL + meta_string)
	


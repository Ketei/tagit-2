class_name MainTaggerWindow
extends Control

const UNSAVED_WINDOW = preload("res://scenes/unsaved_window.tscn")

var unsaved_work_window: UnsavedWorkWindow

@onready var tagger: TaggerWindow = $TaggingInstance # id 0
@onready var reviewer: ReviewWindow = $TagReview # id 1
@onready var tools: ToolsWindow = $ToolsWindow # id 2
@onready var settings: SettingsWindow = $SettingsWindow # id 3
@onready var wiki: WikiWindow = $WikiInstance # id 4

@onready var main_menu: MenuButton = $MenusContainer/TopMenuContainer/MainMenu
@onready var tagger_menu: MenuButton = $MenusContainer/TopMenuContainer/TaggerMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu.get_popup().index_pressed.connect(on_menu_changed)
	tagger_menu.get_popup().index_pressed.connect(on_tagger_menu_selected)
	tagger.window_switch_signaled.connect(on_window_switch_signaled)
	

func on_window_switch_signaled(target_window: int, args = {}) -> void:
	hide_all_windows()
	if target_window == 0: # Wiki
		tagger.show()
		tagger_menu.show()
	elif target_window == 1: # Rewview Tag
		reviewer.show()
		reviewer.clear_fields()
		reviewer.tag_name_line_edit.text = args["tag"]
		reviewer.on_fetch_pressed()
	elif target_window == 2: # Tools
		tools.show()
		if not args.is_empty():
			tools.switch_to_menu(args["tool_id"])
	elif target_window == 3: # Settings
		settings.show()
	elif target_window == 4: # Tagger
		wiki.show()


func on_tagger_menu_selected(menu_index: int) -> void:
	var menu_id: int = tagger_menu.get_popup().get_item_id(menu_index)
	
	if menu_id == 0: # New List
		tagger.new_list()
	elif menu_id ==1: # Save
		tagger.open_save_window()
	elif menu_id ==2: # Load
		tagger.open_load_window()
	elif menu_id ==3: #Clear Tags
		tagger.clear_main_list()
	elif menu_id ==5: # Session Blacklist
		tagger.open_session_blacklist()
	elif menu_id == 10: # Sort Tags
		tagger.sort_tags_alphabetically()
	elif menu_id == 7: # Wizard
		tagger.summon_wizard()
	elif menu_id == 8: # Load from Text
		tagger.open_taglist_importer()
	elif menu_id == 9: # Load Template
		tagger.display_template_loader()


func on_menu_changed(menu_index: int) -> void:
	var menu_id: int = main_menu.get_popup().get_item_id(menu_index)
	if menu_id == 4: # Exit
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		return
	
	hide_all_windows()
	if menu_id == 0: # Wiki
		wiki.show()
	elif menu_id == 1: # Rewview Tag
		reviewer.show()
	elif menu_id == 2: # Tools
		tools.show()
	elif menu_id == 3: # Settings
		settings.show()
	elif menu_id == 5: # Tagger
		tagger.show()
		tagger_menu.show()


func hide_all_windows() -> void:
	if tagger.visible:
		tagger.hide()
		tagger_menu.hide()
	if reviewer.visible:
		reviewer.hide()
	if tools.visible:
		tools.hide()
	if settings.visible:
		settings.hide()
	if wiki.visible:
		wiki.hide()


func on_tag_searched(tag_name: String) -> void:
	hide_all_windows()
	wiki.show()
	wiki.on_wiki_search_submit(tag_name)


func on_unsaved_saved_quit() -> void:
	Tagger.save_settings()
	get_tree().quit()


func on_unsaved_not_saved() -> void:
	unsaved_work_window.queue_free()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if tagger.is_saving():
			return
		if not tagger.prompt_save_on_new:
			Tagger.save_settings()
			get_tree().quit()
		else:
			unsaved_work_window = UNSAVED_WINDOW.instantiate()
			unsaved_work_window.save_data = tagger.get_save_data()
			unsaved_work_window.process_continued.connect(on_unsaved_saved_quit)
			unsaved_work_window.process_cancelled.connect(on_unsaved_not_saved)
			add_child.call_deferred(unsaved_work_window)

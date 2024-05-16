extends MenuButton

signal sort_alphabetical_pressed
signal sort_high_index_pressed


# Called when the node enters the scene tree for the first time.
func _ready():
	Tagger.disabled_shortcuts.connect(on_shortcuts_disabled)
	var menu_popup := get_popup()
	var submenu := PopupMenu.new()
	submenu.name = "SortSubMenu"
	submenu.add_item("Alphabetically", 0)
	submenu.add_item("Priority", 1)
	menu_popup.add_child(submenu)
	menu_popup.set_item_submenu(
			4,
			"SortSubMenu"
	)
	menu_popup.set_item_shortcut(
				0,
				load("res://resources/shortcuts/list_actions/new_list_shortcut.tres"))
	menu_popup.set_item_shortcut(
			1,
			load("res://resources/shortcuts/list_actions/save_list_shortcut.tres"))
	menu_popup.set_item_shortcut(
				2,
				load("res://resources/shortcuts/list_actions/load_list_shortcut.tres"))
	menu_popup.set_item_shortcut(
			10,
			load("res://resources/shortcuts/list_actions/import_list_shortcut.tres"))
	menu_popup.set_item_shortcut(
			11,
			load("res://resources/shortcuts/list_actions/load_template_shortcut.tres"))
	menu_popup.set_item_tooltip(
			5,
			"Resets all custom and loaded tag data to it's default.")
	submenu.id_pressed.connect(on_sort_submenu_pressed)


func on_sort_submenu_pressed(menu_id: int) -> void:
	if menu_id == 0: # Alphabetical
		sort_alphabetical_pressed.emit()
	elif menu_id == 1: # HighPrio
		sort_high_index_pressed.emit()


func on_shortcuts_disabled(shortcuts_disabled: bool) -> void:
	set_disable_shortcuts(shortcuts_disabled)


class_name AutoFillList
extends ItemList


signal item_submited(item_text: String)
signal item_tabbed(item_text: String)


#@onready var add_tag: LineEdit = $"../.."
#@onready var container = $".."


func _ready():
	#container.hide()
	#focus_exited.connect(on_focus_exited)
	item_clicked.connect(on_item_clicked)
	item_activated.connect(on_item_activated)
	focus_neighbor_bottom = "."
	focus_neighbor_left = "."
	focus_neighbor_right = "."
	focus_neighbor_top = "."
	focus_next = "."
	focus_previous = "."


func _unhandled_key_input(event):
	if has_focus() and event.is_action("ui_focus_next") and is_anything_selected():
		item_tabbed.emit(get_item_text(get_selected_items()[0]))
		get_viewport().set_input_as_handled()
		#add_tag.text = get_item_text(
			#get_selected_items()[0]
		#)
		#add_tag.caret_column = add_tag.text.length()


func on_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		item_submited.emit(get_item_text(index))


func on_item_activated(item_index: int) -> void:
	item_submited.emit(get_item_text(item_index))
	#add_tag.grab_focus()


#func on_focus_exited():
	#container.hide()


extends Button

signal generate_default_pressed
signal generate_alternative_pressed

@onready var popup_menu: PopupMenu = $PopupMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_button_pressed)
	popup_menu.index_pressed.connect(on_popup_pressed)
	await get_tree().process_frame
	adjust_pos()
	popup_menu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_button_pressed() -> void:
	await get_tree().process_frame
	adjust_pos()
	popup_menu.visible = true
	popup_menu.grab_focus()


func adjust_pos() -> void:
	var _new_pos := get_screen_position()
	_new_pos.x -= popup_menu.size.x - size.x
	_new_pos.y -= popup_menu.size.y
	popup_menu.set_deferred("position", Vector2i(_new_pos))


func on_popup_pressed(index: int) -> void:
	if index == 0:
		generate_default_pressed.emit()
	else:
		generate_alternative_pressed.emit()


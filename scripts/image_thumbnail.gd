class_name ImageThumbnail
extends TextureRect


signal thumbnail_pressed(file_id: int)

@onready var open_button: Button = $OpenButton

var file_id: int = 0


func _ready():
	open_button.pressed.connect(on_thumbnail_pressed)


func on_thumbnail_pressed() -> void:
	thumbnail_pressed.emit(file_id)
	open_button.release_focus()
	#print_debug("Thumbnail Pressed")


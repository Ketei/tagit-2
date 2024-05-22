extends CheckButton


@export var includes_tags: Array[String] = []
@export var visibility_controlled: Array[Control] = []
@export var inverted: bool = false


func _ready():
	for item in visibility_controlled:
		item.visible = button_pressed != inverted
	toggled.connect(on_toggled)


func on_toggled(is_toggled: bool) -> void:
	# false and true = true
	# true and true = false
	# false and false = false
	# true and false = true
	# Result = XOR
	for controlled in visibility_controlled:
		controlled.visible = is_toggled != inverted


func get_tags() -> Array[String]:
	return includes_tags.duplicate()


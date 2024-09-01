extends Button


var generate_alt: bool = false
# Called when the node enters the scene tree for the first time.


func _ready():
	pressed.connect(_on_button_pressed)
	tooltip_text = "Switch to alternative list"


func _on_button_pressed() -> void:
	generate_alt = not generate_alt
	
	if generate_alt:
		text = "★"
		tooltip_text = "Switch to default list"
	else:
		text = "☆"
		tooltip_text = "Switch to alternative list"


func use_alts() -> bool:
	return generate_alt

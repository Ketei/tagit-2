extends VBoxContainer


@onready var load_images_btn: CheckButton = $LoadImagesBTN
@onready var image_count: SpinBox = $ImageCount


func _ready():
	image_count.value = Tagger.image_amount
	load_images_btn.toggled.connect(on_load_toggled)
	load_images_btn.button_pressed = Tagger.load_images
	image_count.value_changed.connect(on_image_count_changed)


func on_load_toggled(is_toggled: bool) -> void:
	Tagger.load_images = is_toggled
	image_count.editable = is_toggled


func on_image_count_changed(new_value: float) -> void:
	Tagger.image_amount = int(new_value)


extends WizardContainer


@onready var threesome_box = $SomeContainer/ThreesomeBox
@onready var foursome_box = $SomeContainer/FoursomeBox
@onready var fivesome_box = $SomeContainer/FivesomeBox
@onready var gang_box = $GroupSex/GangBox
@onready var reverse_gang_box = $GroupSex/ReverseGangBox
@onready var orgy_box = $GroupSex/OrgyBox


func _ready():
	iterate_nodes(self)
	foursome_box.toggled.connect(on_fourfive_pressed)
	fivesome_box.toggled.connect(on_fourfive_pressed)


func on_fourfive_pressed(_ignored: bool) -> void:
	gang_box.disabled = not (foursome_box.button_pressed or fivesome_box.button_pressed)
	reverse_gang_box.disabled = gang_box.disabled
	orgy_box.disabled = not fivesome_box.button_pressed


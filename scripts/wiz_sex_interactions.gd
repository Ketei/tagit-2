class_name WizardSexInteractions
extends VBoxContainer

const GENDER_INTERACTIONS: Dictionary = {
	"male/male": "male/male",
	"male/female": "male/female",
	"male/ambiguous gender": "male/ambiguous",
	"male/andromorph": "andromorph/male",
	"male/gynomorph": "gynomorph/male",
	"male/herm": "herm/male",
	"male/maleherm": "maleherm/male",
	"female/male": "male/female",
	"female/female": "female/female",
	"female/ambiguous gender": "female/ambiguous",
	"female/andromorph": "andromorph/female",
	"female/gynomorph": "gynomorph/female",
	"female/herm": "herm/female",
	"female/maleherm": "maleherm/female",
	"ambiguous gender/male": "male/ambiguous",
	"ambiguous gender/female": "female/ambiguous",
	"ambiguous gender/ambiguous gender": "ambiguous/ambiguous",
	"ambiguous gender/andromorph": "andromorph/ambiguous",
	"ambiguous gender/gynomorph": "gynomorph/ambiguous",
	"ambiguous gender/herm": "herm/ambiguous",
	"ambiguous gender/maleherm": "maleherm/ambiguous",
	"andromorph/male": "andromorph/male",
	"andromorph/female": "andromorph/female",
	"andromorph/ambiguous gender": "andromorph/ambiguous",
	"andromorph/andromorph": "andromorph/andromorph",
	"andromorph/gynomorph": "gynomorph/andromorph",
	"andromorph/herm": "herm/andromorph",
	"andromorph/maleherm": "maleherm/andromorph",
	"gynomorph/male": "gynomorph/male",
	"gynomorph/female": "gynomorph/female",
	"gynomorph/ambiguous gender": "gynomorph/ambiguous",
	"gynomorph/andromorph": "gynomorph/andromorph",
	"gynomorph/gynomorph": "gynomorph/gynomorph",
	"gynomorph/herm": "gynomorph/herm",
	"gynomorph/maleherm": "maleherm/gynomorph",
	"herm/male": "herm/male",
	"herm/female": "herm/female",
	"herm/ambiguous gender": "herm/ambiguous",
	"herm/andromorph": "herm/andromorph",
	"herm/gynomorph": "gynomorph/herm",
	"herm/herm": "herm/herm",
	"herm/maleherm": "maleherm/herm",
	"maleherm/male": "maleherm/male",
	"maleherm/female": "maleherm/female",
	"maleherm/ambiguous gender": "maleherm/ambiguous",
	"maleherm/andromorph": "maleherm/andromorph",
	"maleherm/gynomorph": "maleherm/gynomorph",
	"maleherm/herm": "maleherm/herm",
	"maleherm/maleherm": "maleherm/maleherm"
}

@onready var sex_interacts: TagItemList = $SexInteracts
@onready var gender_opt_a: GenderOptionButton = $HBoxContainer/Genders/GenderOptA
@onready var gender_opt_b: GenderOptionButton = $HBoxContainer/Genders/GenderOptB
@onready var add_interact_button: Button = $HBoxContainer/AddInteractButton


func _ready():
	add_interact_button.pressed.connect(on_sex_pressed)


func on_sex_pressed() -> void:
	var sex_string: String = GENDER_INTERACTIONS[
		gender_opt_a.get_gender_tag() + "/" + gender_opt_b.get_gender_tag()
	]
	
	if not sex_interacts.has_item(sex_string):
		sex_interacts.add_item(sex_string)


func get_interactions() -> Array[String]:
	var ret_array: Array[String] = []
	
	for item in range(sex_interacts.item_count):
		ret_array.append(sex_interacts.get_item_text(item))
	
	return ret_array


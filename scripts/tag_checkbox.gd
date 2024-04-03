class_name TagCheckBox
extends CheckBox


var tag_path: String = ""

var tag_name: String = ""
var tag_priority: int = 0
var tag_category := Tagger.Categories.GENERAL


func _ready():
	text = tag_name



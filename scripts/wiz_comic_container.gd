extends WizardContainer


@onready var comic_box: CheckBox = $HBoxContainer/ComicContainer/ComicBox
@onready var first_page_box: CheckBox = $HBoxContainer/ComicContainer/ComicProps/FirstPageBox
@onready var last_page_box: CheckBox = $HBoxContainer/ComicContainer/ComicProps/LastPageBox

@onready var multiple_scene_box: CheckBox = $Uniques/MultipleScenes/MultipleSceneBox
@onready var sequential_check: CheckBox = $Uniques/MultipleScenes/SequentialCheck


func _ready():
	iterate_nodes(self)
	comic_box.toggled.connect(on_comic_toggled)
	multiple_scene_box.toggled.connect(on_multiscenes_toggled)


func on_comic_toggled(is_toggled: bool) -> void:
	first_page_box.disabled = not is_toggled
	last_page_box.disabled = not is_toggled


func on_multiscenes_toggled(is_toggled: bool) -> void:
	sequential_check.disabled = not is_toggled



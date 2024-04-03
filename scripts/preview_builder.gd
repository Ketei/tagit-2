extends TabContainer

@onready var wiki_text_edit: TextEdit = $Write/WikiTextEdit
@onready var wiki_rich_label: RichTextLabel = $Preview/WikiRichLabel


func _ready():
	tab_changed.connect(on_tab_switch)


func on_tab_switch(tab_index: int) -> void:
	if tab_index == 1:
		wiki_rich_label.text = wiki_text_edit.text


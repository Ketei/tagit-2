extends MarginContainer


@onready var tab_container: TabContainer = $VBoxContainer/TabContainer

@onready var all_text_edit: TextEdit = $VBoxContainer/TabContainer/All/AllTextEdit
@onready var info_text_edit: TextEdit = $VBoxContainer/TabContainer/Info/InfoTextEdit
@onready var warning_text_edit: TextEdit = $VBoxContainer/TabContainer/Warnings/WarningTextEdit
@onready var error_text_edit: TextEdit = $VBoxContainer/TabContainer/Errors/ErrorTextEdit

@onready var log_level_option_button: OptionButton = $VBoxContainer/HBoxContainer/LogLevelOptionButton


func _ready():
	for info_log in Tagger.get_queued_logs(Tagger.LoggingLevel.NORMAL):
		on_log_emmited(info_log, Tagger.LoggingLevel.NORMAL)
	for warning_log in Tagger.get_queued_logs(Tagger.LoggingLevel.WARNING):
		on_log_emmited(warning_log, Tagger.LoggingLevel.WARNING)
	for error_log in Tagger.get_queued_logs(Tagger.LoggingLevel.ERROR):
		on_log_emmited(error_log, Tagger.LoggingLevel.ERROR)
	Tagger.clear_queued_logs()
	for level in tab_container.get_children():
		log_level_option_button.add_item(level.name)
	log_level_option_button.select(0)
	log_level_option_button.item_selected.connect(on_level_selected)
	Tagger.message_logged.connect(on_log_emmited)


func on_level_selected(selected_index: int) -> void:
	tab_container.current_tab = selected_index


func on_log_emmited(message: String, level: Tagger.LoggingLevel) -> void:
	all_text_edit.text += "\n" + message + "\n"
	if level == Tagger.LoggingLevel.NORMAL:
		info_text_edit.text += "\n" + message + "\n"
	elif level == Tagger.LoggingLevel.WARNING:
		warning_text_edit.text += "\n" + message + "\n"
	elif level == Tagger.LoggingLevel.ERROR:
		error_text_edit.text += "\n" + message + "\n"


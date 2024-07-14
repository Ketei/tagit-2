extends MarginContainer


var msg_log: Array[String] = []
var warn_log: Array[String] = []
var err_log: Array[String] = []

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
	all_text_edit.text = Tagger.get_log_string()
	if level == Tagger.LoggingLevel.NORMAL:
		msg_log.push_front(message)
	elif level == Tagger.LoggingLevel.WARNING:
		warn_log.push_front(message)
	elif level == Tagger.LoggingLevel.ERROR:
		err_log.push_front(message)
	
	normalize_sizes()
	
	if level == Tagger.LoggingLevel.NORMAL:
		info_text_edit.text = get_log_string(msg_log)
	elif level == Tagger.LoggingLevel.WARNING:
		warning_text_edit.text = get_log_string(warn_log)
	elif level == Tagger.LoggingLevel.ERROR:
		error_text_edit.text = get_log_string(err_log)


func normalize_sizes() -> void:
	if Tagger.LOG_SIZE < msg_log.size():
		msg_log.resize(Tagger.LOG_SIZE)
	if Tagger.LOG_SIZE < warn_log.size():
		warn_log.resize(Tagger.LOG_SIZE)
	if Tagger.LOG_SIZE < err_log.size():
		err_log.resize(Tagger.LOG_SIZE)


func get_log_string(log_array: Array[String]) -> String:
	var log_string: String = ""
	
	for index in range(log_array.size() - 1, -1, -1):
		log_string += log_array[index] + "\n"
	
	return log_string



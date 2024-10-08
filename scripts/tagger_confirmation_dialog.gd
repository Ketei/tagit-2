class_name TaggerConfirmationDialog
extends ConfirmationDialog

signal dialog_confirmed(confirmed_status: bool)


# Called when the node enters the scene tree for the first time.
func _ready():
	get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	get_label().vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	DumbUtils.signal_disconnect_all(get_cancel_button().pressed)
	DumbUtils.signal_disconnect_all(get_ok_button().pressed)
	get_ok_button().pressed.connect(on_confirmed)
	get_cancel_button().pressed.connect(on_canceled)


## Sets title, dialog AND buttons text in a single method call
func set_data(dialog_title := "Please Confirm...", dialog_info := "Confirm Action?", ok_button := "Confirm", cancel_button := "Cancel") -> void:
	title = dialog_title
	dialog_text = dialog_info
	ok_button_text = ok_button
	cancel_button_text = cancel_button


func on_canceled() -> void:
	dialog_confirmed.emit(false)
	canceled.emit()


func on_confirmed() -> void:
	dialog_confirmed.emit(true)
	confirmed.emit()



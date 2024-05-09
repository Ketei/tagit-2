class_name TaggerMainNotification
extends AcceptDialog


signal notification_closed


func _ready():
	confirmed.connect(on_confirmed_or_cancel)
	canceled.connect(on_confirmed_or_cancel)


func show_notification(notification_text: String, notification_title: String = "Notification", ok_text: String = "OK") -> void:
	size = Vector2i(100,100)
	ok_button_text = ok_text
	title = notification_title
	dialog_text = notification_text
	show()


func on_confirmed_or_cancel() -> void:
	notification_closed.emit()


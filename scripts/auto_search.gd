extends LineEdit


enum SearchType {
	TAGS,
	SAVES,
	TAG_TYPE,
}

@export var prompt_type: SearchType = SearchType.TAGS
@export var tag_type_search := Tagger.Categories.GENERAL
@export_range(0,10,1) var items_to_fetch: int = 10
@export var invert_list: bool = true
@export var key_direction: StringName = "ui_up" ## If up, invert is usually true.
@export_enum("Up","Down") var container_direction: int = 0
@export var close_n_clear_on_select: bool = true
@export var hide_n_clear_on_autofill: bool = true
@export var use_alt_container: AutoFillContainer = null

@onready var timer: Timer = $PromptTimer
@onready var auto_fill: AutoFillList = $AutoContainer/AutoFill
@onready var auto_container: AutoFillContainer = $AutoContainer


func _ready():
	timer.wait_time = Tagger.AUTOFILL_TIME
	timer.autostart = false
	timer.one_shot = true
	text_changed.connect(on_text_changed)
	if prompt_type == SearchType.TAGS:
		timer.timeout.connect(search_for_tags)
	elif prompt_type == SearchType.TAG_TYPE:
		timer.timeout.connect(search_for_type)
	if use_alt_container == null:
		if container_direction == 0:
			auto_container.position.y = -auto_container.size.y
			auto_container.alignment = VBoxContainer.ALIGNMENT_END
		else:
			auto_container.position.y = size.y
			auto_container.alignment = VBoxContainer.ALIGNMENT_BEGIN
	else:
		auto_container.queue_free()
		auto_container = use_alt_container
		if not auto_container.is_node_ready():
			await auto_container.ready
		auto_fill = auto_container.auto_fill
	
	focus_exited.connect(on_focus_lost)
	text_submitted.connect(on_text_submitted)
	auto_fill.focus_exited.connect(on_item_list_focus_lost)
	auto_fill.item_submited.connect(on_item_selected)
	auto_fill.item_tabbed.connect(on_item_tabbed)


func _unhandled_key_input(event):
	if has_focus() and event.is_action(key_direction) and 0 < auto_fill.item_count:
		auto_container.show()
		select_nearest()
		auto_fill.grab_focus()


func on_item_selected(item_text: String) -> void:
	text = item_text
	if close_n_clear_on_select:
		close_and_clear_items()
	else:
		caret_to_end()
	text_submitted.emit(text)


func on_item_tabbed(item_text: String) -> void:
	text = item_text
	caret_to_end()
	if hide_n_clear_on_autofill:
		close_and_clear_items()


func caret_to_end() -> void:
	caret_column = text.length()


func on_text_submitted(_ignored: String) -> void:
	if not timer.is_stopped():
		timer.stop()


func on_focus_lost() -> void:
	await get_tree().process_frame # Wait to see who grabs focus
	if not auto_fill.has_focus() and auto_container.visible:
		auto_container.visible = false


func on_item_list_focus_lost() -> void:
	await get_tree().process_frame # Wait to see who grabs focus
	if not has_focus() and auto_container.visible: # If the lineedit doesn't have focus
		auto_container.visible = false
	else:
		auto_fill.deselect_all()


func on_text_changed(_ignored: String) -> void:
	if not Tagger.autofill_enabled:
		return
	
	if auto_container.visible:
		auto_container.hide()
	
	timer.start()


func search_for_tags() -> void:
	var tag_to_search: String = text.strip_edges().to_lower()
	
	if tag_to_search.is_empty() or not has_focus():
		return
	
	var tags_found: Array[String] = Tagger.search_local(tag_to_search, 10, invert_list)
	
	auto_fill.clear()

	for item in tags_found:
		auto_fill.add_item(item)
	
	if 0 < tags_found.size():
		auto_container.show()


func search_for_type() -> void:
	var tag_to_search: String = text.strip_edges().to_lower()
	
	if tag_to_search.is_empty() or not has_focus():
		return
	
	var tags_found: Array[String] = Tagger.search_with_category(
			tag_to_search,
			tag_type_search,
			items_to_fetch,
			invert_list)
	
	auto_fill.clear()

	for item in tags_found:
		auto_fill.add_item(item)
	
	if 0 < tags_found.size():
		auto_container.show()


func select_nearest() -> void:
	if key_direction == "ui_up":
		auto_fill.select(auto_fill.item_count - 1)
	else:
		auto_fill.select(0)


func close_and_clear_items() -> void:
	auto_container.hide()
	auto_fill.clear()
	grab_focus()


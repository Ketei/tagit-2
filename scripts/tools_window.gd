class_name ToolsWindow
extends Control


@onready var tab_container: TabContainer = $MarginContainer/TabContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	if Tagger.AM_THE_THICC_SHIBE:
		var packing_tool: ToolPacker = preload("res://scenes/packer.tscn").instantiate()
		packing_tool.name = "Packing Tool"
		tab_container.add_child(packing_tool)
		var web_tool: WebsiteCreatorTool = preload("res://scenes/tool_website_create.tscn").instantiate()
		web_tool.name = "Website Creator Tool"
		tab_container.add_child(web_tool)


func switch_to_menu(menu_indx: int) -> void:
	tab_container.current_tab = clampi(menu_indx, 0, 1)


func on_exit_pressed() -> void:
	hide()

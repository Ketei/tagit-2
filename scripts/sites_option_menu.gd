class_name SitesOptionButton
extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready():
	load_sites()
	Tagger.websites_updated.connect(load_sites)


func load_sites() -> void:
	clear()
	var index: int = 0
	var default_index: int = 0
	for site in Tagger.loaded_sites:
		add_item(Tagger.loaded_sites[site]["name"])
		set_item_metadata(
				index,
				site)
		if site == Tagger.default_site:
			default_index = index
		index += 1
	select(default_index)


func select_with_key(site_key: String) -> void:
	for index in range(item_count):
		if get_item_metadata(index) == site_key:
			select(index)
			break


func get_selected_site_key() -> String:
	return get_item_metadata(selected)


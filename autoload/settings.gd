extends Node


signal image_view_toggled(is_toggled)
signal tag_updated(tag_name)
signal tag_registered(tag_name)
signal aliases_reloaded
signal tag_deleted(tag_name)
signal invalid_added(tag_name)
signal websites_updated
signal disabled_shortcuts(is_disabled: bool)
signal message_logged(message: String, level: LoggingLevel)
signal menus_disabled
signal menus_enabled


enum LoggingLevel {
	NORMAL,
	WARNING,
	ERROR,
}

enum Categories {
	GENERAL,
	ARTIST,
	COPYRIGHT,
	CHARACTER,
	SPECIES,
	GENDER,
	BODY_TYPES,
	ANATOMY,
	MARKINGS,
	POSES_AND_STANCES,
	ACTIONS_AND_INTERACTIONS,
	SEX_AND_POSITIONS,
	PENETRATION,
	FLUIDS,
	EXPRESSIONS,
	COLORS,
	OBJECTS,
	CLOTHING,
	ACCESSORIES,
	PROFESSION,
	META,
	LOCATION,
	FURNITURE,
	LORE,
}

enum AgeRange{
	YOUNG,
	ADULT,
	MATURE,
	OLD
}

enum E621_CATEGORY {
	ALL = -1,
	GENERAL = 0,
	ARTIST = 1,
	COPYRIHGT = 3,
	CHARACTER = 4,
	SPECIES = 5,
	INVALID = 6,
	META = 7,
	LORE = 8,
	}

const NOTIFICATION_DIALOG = preload("res://scenes/notification_dialog.tscn")
const CONFIRMATION_DIALOG = preload("res://scenes/confirmation_dialog.tscn")

const CategorySorting: Array = [
	{"name": "General", "index": Categories.GENERAL},
	{"name": "Artist", "index": Categories.ARTIST},
	{"name": "Copyright", "index": Categories.COPYRIGHT},
	{"name": "Character", "index": Categories.CHARACTER},
	{"name": "Species", "index": Categories.SPECIES},
	{"name": "Gender", "index": Categories.GENDER},
	{"name": "Body Type", "index": Categories.BODY_TYPES},
	{"name": "Anatomy", "index": Categories.ANATOMY},
	{"name": "Marking", "index": Categories.MARKINGS},
	{"name": "Pose/Stance", "index": Categories.POSES_AND_STANCES},
	{"name": "Action/Interaction", "index": Categories.ACTIONS_AND_INTERACTIONS},
	{"name": "Sex", "index": Categories.SEX_AND_POSITIONS},
	{"name": "Penetration", "index": Categories.PENETRATION},
	{"name": "Fluid", "index": Categories.FLUIDS},
	{"name": "Expression", "index": Categories.EXPRESSIONS},
	{"name": "Color", "index": Categories.COLORS},
	{"name": "Object", "index": Categories.OBJECTS},
	{"name": "Clothing", "index": Categories.CLOTHING},
	{"name": "Accessory", "index": Categories.ACCESSORIES},
	{"name": "Furniture", "index": Categories.FURNITURE},
	{"name": "Profession", "index": Categories.PROFESSION},
	{"name": "Location", "index": Categories.LOCATION},
	{"name": "Meta", "index": Categories.META},
	{"name": "Lore", "index": Categories.LORE},
]

const DEFAULT_SITES: Dictionary = {
	"e_six": {
		"name": "e621",
		"whitespace": "_",
		"separator": " "
	},
	"posty": {
		"name": "PostyBirb",
		"whitespace": " ",
		"separator": ", "
	}
}

const IMAGE_LIMIT: int = 128
const TAGS_PATH: String = "tags/"
const SAVES_PATH: String = "user://saves/"
const WILDCARD_CHAR: String = "*"
const TAG_SPLIT_CHAR: String = ","
const AM_THE_THICC_SHIBE: bool = false
const SOURCE_RUN: bool = false
# URLs

const E6_SEARCH_URL: String = "https://e621.net/wiki_pages/show_or_new?title="

# Endpoints
const WIKI: String = "https://e621.net/wiki_pages.json?limit=1&title=" # title
# search[name_matches] = String
# search[category] = enum
#	    0 general
#		1 artist
#		3 copyright
#		4 character
#		5 species
#		6 invalid
#		7 meta
#		8 lore
# search[order] = "date"|"count"|"name"
# search[has_wiki] = bool
# limit = int
const TAGS: String = "https://e621.net//tags.json?"
const ALIASES: String = "https://e621.net/tag_aliases.json?search[name_matches]="
const PARENTS: String = "https://e621.net/tag_implications.json?search[antecedent_name]="
const VERSION: String = "2.3.5"
const HEADER_FORMAT: String = "TaglistMaker/{0} (by Ketei)"
const AUTOFILL_TIME: float = 0.3
const GENDERS: Dictionary = {
	"male": {"name": "Male", "tag": "male", "is_female": false},
	"female": {"name": "Female", "tag": "female", "is_female": true},
	"amb": {"name": "Ambiguous", "tag": "ambiguous gender", "is_female": false},
	"andro": {"name": "Andromorph", "tag": "andromorph", "is_female": false},
	"gyno": {"name": "Gynomorph", "tag": "gynomorph", "is_female": true},
	"herm": {"name": "Hermaphrodite", "tag": "herm", "is_female": true},
	"maleherm": {"name": "Male Hermaphrodite", "tag": "maleherm", "is_female": false}
}
const BODY_TYPES: Dictionary = {
	"anthro": {"name": "Anthro", "tags": ["anthro"]},
	"semian": {"name": "Semi-anthro", "tags": ["anthro", "semi-anthro"]},
	"semife": {"name": "Semi-feral", "tags": ["feral", "semi-anthro"]},
	"stud": {"name": "Feral", "tags": ["feral"]},
	"hooman": {"name": "Human", "tags": ["human"]},
	"humanoid": {"name": "Humanoid", "tags": ["humanoid"]},
	"tahuff": {"name": "Taur", "tags": ["taur"]},
}
const AGES: Dictionary = {
	"old": {"name": "Elderly", "tag": "old", "cat": AgeRange.OLD},
	"mature": {"name": "Mature", "tag": "", "cat": AgeRange.MATURE},
	"adult": {"name": "Adult", "tag": "", "cat": AgeRange.ADULT},
	"young_adult": {"name": "Young Adult", "tag": "young adult", "cat": AgeRange.ADULT},
	"teen": {"name": "Adolescent", "tag": "adolescent", "cat": AgeRange.YOUNG},
	"child": {"name": "Child", "tag": "child", "cat": AgeRange.YOUNG},
	"todd": {"name": "Toddler", "tag": "toddler", "cat": AgeRange.YOUNG},
	"bab": {"name": "Baby", "tag": "baby", "cat": AgeRange.YOUNG}}

# Nodes
var notification_window: TaggerMainNotification

# Data
var header_data: Dictionary = {}

var custom_sites: Dictionary = {}

var loaded_sites: Dictionary = {}

# Used for the add_tag menu
var tag_map: Dictionary = {
	#"species": {
		#"name": "Species",
		#"desc": "Category of breeding/breedable subjects",
		#"categories": {
			#"canine": {
				#"name": "Canine",
				#"desc": "Woof woof bark woof",
				#"tags": {
					#"shibe": {
						#"name": "Shiba Inu",
						#"desc": "Stuffable, warm dogs",
						#"tag": "shiba inu"
					#}
				#}
			#}
		#}
	#}
}

# Run variables
var database_path: String = "":
	set(new_db):
		database_path = new_db.replace("\\", "/")
		if not database_path.ends_with("/"):
			database_path += "/"

# Basic Settings
var load_images: bool = false: # Hydrus Only
	set(new_load):
		load_images = new_load
		image_view_toggled.emit(load_images)
var autofill_enabled: bool = true
var open_e6_on_wiki_link: bool = true
var include_invalid: bool = false
var image_amount: int = 16
var hydrus_port: int = 0
var hydrus_key: String = ""

# List Settings
var invalid_tags: Dictionary = {}
var suggestion_blacklist: Array[String] = []
var constant_tags: Array[String] = []
var alias_list: Dictionary = {
	#"a": {"ass": "butt"}
}
var _loaded_aliases: Dictionary = {}
var custom_aliases: Dictionary = {}
var removed_aliases: Dictionary = {}
var prefixes: Dictionary = {}
var prefix_sorting: Array[String] = []
var remove_after_use: bool = false
var blacklist_after_remove: bool = false

# Tagger Settings
var default_site: String = ""
var suggestion_confidence: int = 45
var search_online_suggestions: bool = false

# Loaded tags {"a": {"asshole": "D:/tags/asshole.tres"}}
# Loaded tags {"a": {"asshole": {"path": "D:/tags/asshole.tres", "category": 0}}
var loaded_tags: Dictionary = {}

# Resources
#var backup_work: SessionSave
var templates: Array[Dictionary] = []
var saves: Array[Dictionary] = [
	#{
		#"title": "",
		#"data": {
			#"main":{
				#"vaporeon": {}
			#},
			#"suggs": ["",""],
			#"smart": {
				#"Nipples": {}
			#}
		#}
	#}
]

# Internal
var http_requests: int = 0
var shortcuts_disabled: bool = false :
	set(new_disabled):
		if new_disabled == shortcuts_disabled:
			return
		shortcuts_disabled = new_disabled
		disabled_shortcuts.emit(shortcuts_disabled)
var update_notified: bool = false
var version_notified: String = ""
var notifications_queue: Array[Dictionary] = []
var disable_shortcuts_count: int = 0:
	set(new_disable):
		disable_shortcuts_count = maxi(0, new_disable)
		if disable_shortcuts_count == 0 and shortcuts_disabled:
			shortcuts_disabled = false
		elif 0 < disable_shortcuts_count and not shortcuts_disabled:
			shortcuts_disabled = true
var queued_logs: Dictionary = {
	"INFO": [],
	"WARNING": [],
	"ERROR": []
}


func _ready():
	DisplayServer.window_set_min_size(Vector2i(1280, 720))
	DisplayServer.window_set_title("TagIt!")
	header_data["User-Agent"] = HEADER_FORMAT.format([VERSION])
	loaded_sites.merge(DEFAULT_SITES)
	
	var _load_settings = SettingsResource.get_settings()
	var _save_data := SaveSlots.get_save_data()
	
	if _load_settings.first_run:
		if SOURCE_RUN:
			database_path = ProjectSettings.globalize_path("user://")
		else:
			database_path = OS.get_executable_path().get_base_dir() + "/database/"
	else:
		database_path = _load_settings.database_path
	
	if _load_settings.version_notified.is_empty():
		version_notified = VERSION
		update_notified = false
	elif version_as_int_array(_load_settings.version_notified) < version_as_int_array(VERSION):
		version_notified = VERSION
		update_notified = false
	else:
		version_notified = _load_settings.version_notified
		update_notified = _load_settings.update_notified

	if not DirAccess.dir_exists_absolute(database_path):
		var _err = DirAccess.make_dir_recursive_absolute(database_path)
		
		if _err != OK:
			log_message(
					"Directory \"{0}\" couldn't be created. Using default.".format(
						[database_path]),
						LoggingLevel.ERROR,
						true
			)
			database_path = ProjectSettings.globalize_path("user://")
	
	if not DirAccess.dir_exists_absolute(database_path + TAGS_PATH):
		var _err = DirAccess.make_dir_absolute(database_path + TAGS_PATH)
		
		if _err != OK:
			log_message(
					"Directory \"{0}\" couldn't be created.".format(
						[database_path + TAGS_PATH]),
						LoggingLevel.ERROR,
						true)
	
	search_online_suggestions = _load_settings.search_online_suggestions
	loaded_sites.merge(_load_settings.custom_sites, true)
	custom_sites = _load_settings.custom_sites
	load_images = _load_settings.load_images
	image_amount = _load_settings.image_amount
	invalid_tags = _load_settings.invalid_tags.duplicate()
	suggestion_blacklist = _load_settings.suggestion_blacklist.duplicate()
	#templates = _load_settings.templates
	#saves = _load_settings.saves
	templates = _save_data.templates
	saves = _save_data.saves
	constant_tags = _load_settings.constant_tags
	hydrus_port = _load_settings.hydrus_port
	hydrus_key = _load_settings.hydrus_key
	tag_map = _load_settings.tag_map
	include_invalid = _load_settings.include_invalid
	remove_after_use = _load_settings.remove_after_use
	blacklist_after_remove = _load_settings.blacklist_after_remove
	
	if loaded_sites.has(_load_settings.default_site):
		default_site = _load_settings.default_site
	else:
		default_site = ""
	
	suggestion_confidence = _load_settings.suggestion_confidence
	prefixes = _load_settings.prefixes
	autofill_enabled = _load_settings.autofill_enabled

	var directories := DirAccess.get_directories_at(database_path + TAGS_PATH)

	for file in DirAccess.get_files_at(database_path + TAGS_PATH):
		if file.get_extension() != "tres":
			log_message(
					"File " + file +  " is not a resource file. Skipping -",
					LoggingLevel.WARNING,
					true
			)
			continue
		
		var tag: Resource = load(database_path + TAGS_PATH + file)
		
		if not tag is Tag:
			log_message(
					"File " + file +  " is not a Tag file. Skipping -",
					LoggingLevel.WARNING,
					true
			)
			continue
		
		if tag.file_name != file:
			tag.file_name = file
		for alias in tag.aliases:
			if not alias_list.has(alias.left(1)):
				alias_list[alias.left(1)] = {}
			alias_list[alias.left(1)][alias] = tag.tag
		register_tag(tag.tag, database_path + TAGS_PATH + file, true)
	
	for directory in directories:
		for tag_file in DirAccess.get_files_at(database_path + TAGS_PATH + directory + "/"):
			if tag_file.get_extension() != "tres":
				log_message(
						"File \"" + tag_file +  "\" is not a resource file. Skipping",
						LoggingLevel.WARNING,
						true
				)
				continue
			
			var tag: Resource = load(database_path + TAGS_PATH + directory + "/" + tag_file)
			
			if not tag is Tag:
				log_message(
						"File \"" + tag_file +  "\" is not a Tag file. Skipping",
						LoggingLevel.WARNING,
						true
				)
				continue
			
			if tag.file_name != tag_file:
				tag.file_name = tag_file
			
			for alias in tag.aliases:
				if not alias_list.has(alias.left(1)):
					alias_list[alias.left(1)] = {}
				alias_list[alias.left(1)][alias] = tag.tag
			register_tag(tag.tag, database_path + TAGS_PATH + directory + "/" + tag_file, true)
	
	_loaded_aliases = alias_list.duplicate(true)
	
	for custom_alias in _load_settings.custom_aliases:
		if not alias_list.has(custom_alias):
			alias_list[custom_alias] = {}
		
		alias_list[custom_alias].merge(_load_settings.custom_aliases[custom_alias], true)
	
	for removed_alias in _load_settings.removed_aliases:
		if not removed_aliases.has(removed_alias):
			removed_aliases[removed_alias] = {}
		
		removed_aliases[removed_alias].merge(_load_settings.removed_aliases[removed_alias], true)
	
	custom_aliases = _load_settings.custom_aliases
	removed_aliases = _load_settings.removed_aliases
	
	sort_prefixes()


func disable_shortcuts() -> void:
	disable_shortcuts_count += 1


func disable_menus() -> void:
	menus_disabled.emit()


func enable_menus() -> void:
	menus_enabled.emit()


func enable_shortcuts() -> void:
	disable_shortcuts_count -= 1
	

func force_enable_shortcuts() -> void:
	disable_shortcuts_count = 0


func version_as_int_array(version: String) -> Array[int]:
	var version_array: Array[int] = []
	for letter in version.split(".", false):
		version_array.append(int(letter))
	return version_array


func queue_notification(message: String, title: String = "Notification", ok_button: String = "OK") -> void:
	notifications_queue.append({"message": message, "title": title, "confirm": ok_button})
	
	if notification_window == null:
		notification_window = NOTIFICATION_DIALOG.instantiate()
		notification_window.notification_closed.connect(on_notification_closed)
		add_child(notification_window)
		show_next_notification()


func show_next_notification() -> void:
	var new_notification: Dictionary = notifications_queue.pop_front()
	
	notification_window.show_notification(
		new_notification["message"],
		new_notification["title"],
		new_notification["confirm"])


func on_notification_closed() -> void:
	if notifications_queue.is_empty():
		notification_window.queue_free()
		return
	show_next_notification()


func clear_tag_map() -> void:
	tag_map.clear()


func save_slot(save_data: Dictionary, save_title: String, save_index: int = -1) -> void:
	if save_index != -1:
		saves[save_index]["data"] = save_data
	else:
		saves.append({"title": save_title, "data": save_data})
	
	var existing_data = SaveSlots.get_save_data()
	existing_data.saves = saves
	existing_data.save()


func erase_slot(slot_index: int) -> void:
	saves.remove_at(slot_index)
	var existing_data = SaveSlots.get_save_data()
	existing_data.saves = saves
	existing_data.save()


func save_template(template_data: Dictionary, template_index: int = -1) -> void:
	if template_index != -1:
		templates[template_index] = template_data
	else:
		templates.append(template_data)
	var _existing_data := SaveSlots.get_save_data()
	_existing_data.templates = templates
	_existing_data.save()


func erase_template(template_index: int) -> void:
	templates.remove_at(template_index)
	var _existing_data := SaveSlots.get_save_data()
	_existing_data.templates = templates
	_existing_data.save()


func add_to_custom_aliases(from: String, to: String) -> void:
	if not custom_aliases.has(from.left(1)):
		custom_aliases[from.left(1)] = {}
	custom_aliases[from.left(1)][from] = to
	add_alias(from, to)


func remove_from_custom_aliases(from: String) -> void:
	#var to_custom: String = custom_aliases[from.left(1)][from]
	
	custom_aliases[from.left(1)].erase(from)
	
	if custom_aliases[from.left(1)].is_empty():
		custom_aliases.erase(from.left(1))
	
	if not has_load_alias(from):
		remove_alias(from)


func has_custom_alias(from: String) -> bool:
	if custom_aliases.has(from.left(1)):
		return custom_aliases[from.left(1)].has(from)
	return false


func add_to_removed_aliases(from: String, to: String) -> void:
	if not removed_aliases.has(from.left(1)):
		removed_aliases[from.left(1)] = {}
	removed_aliases[from.left(1)][from] = to


func remove_from_removed_aliases(from: String, to: String) -> void:
	if has_removed_alias(from, to):
		if removed_aliases[from.left(1)][from] == to:
			removed_aliases[from.left(1)].erase(from)
		if removed_aliases[from.left(1)].is_empty():
			removed_aliases.erase(from.left(1))


func has_removed_alias(from: String, to: String) -> bool:
	if removed_aliases.has(from.left(1)):
		return removed_aliases[from.left(1)][from] == to
	return false


func add_alias(from: String, to: String) -> void:
	if not alias_list.has(from.left(1)):
		alias_list[from.left(1)] = {}
	alias_list[from.left(1)][from] = to


func remove_alias(from: String) -> void:
	alias_list[from.left(1)].erase(from)
	if alias_list[from.left(1)].is_empty():
		alias_list.erase(from.left(1))


func has_load_alias(from: String) -> bool:
	if _loaded_aliases.has(from.left(1)):
		return _loaded_aliases[from.left(1)].has(from)
	return false


func has_alias(from: String) -> bool:
	if alias_list.has(from.left(1)):
		return alias_list[from.left(1)].has(from)
	return false


func add_invalid_tag(tag_name: String) -> void:
	var tag_key: String = tag_name.left(1)
	
	if not invalid_tags.has(tag_key):
		invalid_tags[tag_key] = []
	
	if invalid_tags[tag_key].has(tag_name):
		return
	
	invalid_tags[tag_key].append(tag_name)
	invalid_added.emit(tag_name)


func remove_invalid_tag(invalid_to_remove: String) -> void:
	var tag_key: String = invalid_to_remove.left(1)
	invalid_tags[tag_key].erase(invalid_to_remove)
	if invalid_tags[tag_key].is_empty():
		invalid_tags.erase(tag_key)


func has_invalid_tag(tag_name: String) -> bool:
	return invalid_tags.has(tag_name.left(1)) and invalid_tags[tag_name.left(1)].has(tag_name)


func sort_prefixes() -> void:
	prefix_sorting.clear()
	prefix_sorting.append_array(prefixes.keys())
	prefix_sorting.sort_custom(func(a, b): return b.length() < a.length())


func get_category_name(category: Categories) -> String:
	if category == Categories.GENERAL:
		return "General"
	elif category == Categories.ARTIST:
		return "Artist"
	elif category == Categories.COPYRIGHT:
		return "Copyright"
	elif category == Categories.CHARACTER:
		return "Character"
	elif category == Categories.SPECIES:
		return "Species"
	elif category == Categories.GENDER:
		return "Gender"
	elif category == Categories.BODY_TYPES:
		return "Body Type"
	elif category == Categories.ANATOMY:
		return "Anatomy"
	elif category == Categories.MARKINGS:
		return "Marking"
	elif category == Categories.POSES_AND_STANCES:
		return "Pose / Stance"
	elif category == Categories.ACTIONS_AND_INTERACTIONS:
		return "Actions / Interactions"
	elif category == Categories.SEX_AND_POSITIONS:
		return "Sex / Sexual Positions"
	elif category == Categories.PENETRATION:
		return "Penetration"
	elif category == Categories.FLUIDS:
		return "Fluids"
	elif category == Categories.EXPRESSIONS:
		return "Expression"
	elif category == Categories.COLORS:
		return "Color"
	elif category == Categories.OBJECTS:
		return "Object"
	elif category == Categories.CLOTHING:
		return "Clothing"
	elif category == Categories.ACCESSORIES:
		return "Accessory"
	elif category == Categories.PROFESSION:
		return "Profession"
	elif category == Categories.META:
		return "Meta"
	elif category == Categories.LOCATION:
		return "Location"
	elif category == Categories.FURNITURE:
		return "Furniture"
	elif category == Categories.LORE:
		return "Lore"
	else:
		return "UNKNOWN"


func reload_tags() -> void:
	log_message("Clearing tag database and reloading", LoggingLevel.NORMAL)
	
	loaded_tags.clear()
	alias_list.clear()
	
	for alias_key in custom_aliases:
		if not alias_list.has(alias_key):
			alias_list[alias_key] = {}
		for alias in custom_aliases[alias_key]:
			alias_list[alias_key][alias] = custom_aliases[alias_key][alias]
	
	var directories := DirAccess.get_directories_at(database_path + TAGS_PATH)
	
	for file in DirAccess.get_files_at(database_path + TAGS_PATH):
		
		if file.get_extension() != "tres":
			log_message(
					"File " + file +  " is not a resource file. Skipping -",
					LoggingLevel.WARNING
			)
			continue
		
		var tag: Resource = load(database_path + TAGS_PATH + file)
		
		if not tag is Tag:
			log_message(
					"File " + file +  " is not a Tag file. Skipping -",
					LoggingLevel.WARNING
			)
			continue

		if tag.file_name != file:
			tag.file_name = file
		
		register_tag(tag.tag, database_path + TAGS_PATH + file)
	
	for directory in directories:
		for tag_file in DirAccess.get_files_at(database_path + TAGS_PATH + directory + "/"):
			
			if tag_file.get_extension() != "tres":
				log_message(
						"File \"" + tag_file +  "\" is not a resource file. Skipping",
						LoggingLevel.WARNING
				)
				continue
			
			var tag: Resource = load(database_path + TAGS_PATH + directory + "/" + tag_file)
			
			if not tag is Tag:
				log_message(
						"File \"" + tag_file +  "\" is not a Tag file. Skipping",
						LoggingLevel.WARNING
				)
				continue
			
			if tag.file_name != tag_file:
				tag.file_name = tag_file
			
			register_tag(tag.tag, database_path + TAGS_PATH + directory + "/" + tag_file)
	
	# Prevents repeated/replaced tags from packs to be signaled.
	for tag_char in loaded_tags:
		for tag_name in loaded_tags[tag_char]:
			tag_updated.emit(tag_name)
	aliases_reloaded.emit()


func database_changed() -> void:
	log_message("Database change queued.")
	if not DirAccess.dir_exists_absolute(database_path):
		var _err = DirAccess.make_dir_recursive_absolute(database_path)
		
		if _err != OK:
			log_message(
				"Directory \"{0}\" couldn't be created. Using default.".format(
					[database_path]),
					LoggingLevel.WARNING
			)
			database_path = ProjectSettings.globalize_path("user://")
	
	if not DirAccess.dir_exists_absolute(database_path + TAGS_PATH):
		var _err = DirAccess.make_dir_absolute(database_path + TAGS_PATH)
		
		if _err != OK:
			log_message(
				"Directory \"{0}\" couldn't be created.".format(
					[database_path + TAGS_PATH]),
					LoggingLevel.WARNING
			)
	
	reload_tags()
	log_message("Database change finished.")


func get_wiki_request_url(tag_name: String) -> String:
	return WIKI + tag_name


func get_alias_request_url(tag_name: String) -> String:
	return ALIASES + tag_name


func get_parents_request_url(tag_name: String) -> String:
	return PARENTS + tag_name


func get_category_equivalent(e_six_category: E621_CATEGORY) -> Categories:
	if e_six_category == E621_CATEGORY.ARTIST:
		return Categories.ARTIST
	elif e_six_category == E621_CATEGORY.COPYRIHGT:
		return Categories.COPYRIGHT
	elif e_six_category == E621_CATEGORY.CHARACTER:
		return Categories.CHARACTER
	elif e_six_category == E621_CATEGORY.SPECIES:
		return Categories.SPECIES
	elif e_six_category == E621_CATEGORY.META:
		return Categories.META
	elif e_six_category == E621_CATEGORY.LORE:
		return Categories.LORE
	else:
		return Categories.GENERAL


func get_tag_request_url(tag_name: String, category := E621_CATEGORY.ALL, order := "date", limit: int = 75) -> String:
	var request_url: String = TAGS +\
			"search[name_matches]=" + tag_name +\
			"&search[order]=" + order +\
			"&limit=" + str(clampi(limit, 1, 320))
	
	if category != E621_CATEGORY.ALL:
		request_url += "&search[category]=" + str(category)
	
	return request_url


func get_headers() -> PackedStringArray:
	var _headers := PackedStringArray()
	
	for header in header_data.keys():
		_headers.append(header + ": " + header_data[header])
	
	return _headers


func get_online_wiki_url(tag_name: String) -> String:
	return E6_SEARCH_URL + tag_name.replace(" ", "_")


func register_tag(tag_string: String, path: String, log_msg := false):
	if not loaded_tags.has(tag_string.left(1)):
		loaded_tags[tag_string.left(1)] = {}
	
	var tag: Tag = load(path)
	
	if loaded_tags[tag_string.left(1)].has(tag_string) and loaded_tags[tag_string.left(1)][tag_string]["path"] != path:
		log_message(
			"Tag \"{0}\" is duplicate, tag file from {1} will be used".format(
				[
					tag_string, path
				]),
				LoggingLevel.NORMAL,
				log_msg
		)
	
	loaded_tags[tag_string.left(1)][tag_string] = {
		"path": path,
		"category": tag.category
	}
	for alias in tag.aliases: # Regsiter/update new aliases
		if custom_aliases.has(alias.left(1)) and custom_aliases[alias.left(1)].has(alias):
			continue # Only if they are not custom
		
		if not alias_list.has(alias.left(1)):
			alias_list[alias.left(1)] = {}
		alias_list[alias.left(1)][alias] = tag.tag
	
	#if signal_update:
		#tag_updated.emit(tag_string)


## Returns true if the tag file exists.
func has_tag(tag_name: String) -> bool:
	var tag_key: String = tag_name.left(1)
	if loaded_tags.has(tag_key):
		if loaded_tags[tag_key].has(tag_name):
			return FileAccess.file_exists(loaded_tags[tag_key][tag_name]["path"])
	return false


## Gets a tag file. Check with has_tag before using
func get_tag(tag_name: String) -> Tag:
	return load(loaded_tags[tag_name.left(1)][tag_name]["path"])


## Gets the alias of a tag or the tag unchanged
func get_alias(tag_string: String, _starting_alias: String = "") -> String:
	#tag_string = tag_string.strip_edges().to_lower()
	var tag_key: String = tag_string.left(1)
	var to_tag: String = ""
	
	if has_alias(tag_string):
		to_tag = alias_list[tag_key][tag_string]
	
	if to_tag.is_empty() or has_removed_alias(tag_string, to_tag):
		return tag_string
	else:
		if to_tag == _starting_alias:
			log_message(
				"Cyclic aliasing detected. From\"{0}\" to \"{1}\"".format(
						[_starting_alias, tag_string]),
				LoggingLevel.WARNING
			)
			return tag_string
		elif has_alias(to_tag):
			if _starting_alias.is_empty():
				return get_alias(to_tag, tag_string)
			else:
				return get_alias(to_tag, _starting_alias)
		else:
			return to_tag


## Searches for all tag matches. If limit is -1 it'll go through all entries
## if not it'll stop once if finds "limit" matches.
func search_local(search_string: String, limit: int = -1, invert := true) -> Array[String]:
	search_string = search_string.strip_edges().to_lower()
	var pre_wild: bool = search_string.begins_with(WILDCARD_CHAR) # ends with
	var suff_wild: bool = search_string.ends_with(WILDCARD_CHAR) # Begins with
	
	search_string = search_string.trim_prefix(WILDCARD_CHAR).trim_suffix(WILDCARD_CHAR).strip_edges()
	
	if pre_wild and suff_wild:
		return _search_local_with_any(search_string, limit, invert)
	elif pre_wild:
		return _search_local_with_suffix(search_string, limit, invert)
	else:
		return _search_local_with_prefix(search_string, limit, invert)


func search_with_category(search_string: String, category: Categories, limit: int = -1, invert := true) -> Array[String]:
	var tag_key: String = search_string.left(1)
	var return_array: Array[String] = []
	
	if has_alias(search_string):
		return_array.push_front(get_alias(search_string))
		limit -= 1
	elif has_tag(search_string):
		return_array.push_front(search_string)
		limit -= 1
	
	if loaded_tags.has(tag_key):
		for tag in loaded_tags[tag_key]:
			if limit == 0:
				break
			if tag.begins_with(search_string) and\
			not return_array.has(tag) and\
			loaded_tags[tag_key][tag]["category"] == category:
				if invert:
					return_array.push_front(tag)
				else:
					return_array.push_back(tag)
				limit -= 1
	
	return return_array


func get_tag_filepath(tag_name: String) -> String:
	if has_tag(tag_name):
		return loaded_tags[tag_name.left(1)][tag_name]["path"]
	else:
		return get_default_tag_filepath(tag_name)


func get_default_tag_filepath(tag_name: String) -> String:
	return database_path + TAGS_PATH + tag_name + ".tres"


func remove_tag(tag_name: String) -> void:
	loaded_tags[tag_name.left(1)].erase(tag_name)
	if loaded_tags[tag_name.left(1)].is_empty():
		loaded_tags.erase(tag_name.left(1))


func build_tag_meta(tag_resource: Tag) -> Dictionary:
	return {
		"parents": tag_resource.parents.duplicate(),
		"category": tag_resource.category,
		"priority": tag_resource.tag_priority,
		"suggestions": tag_resource.suggestions.duplicate(),
		"tooltip": tag_resource.tooltip,
		"valid": true}	


func get_empty_meta(is_valid_tag := true) -> Dictionary:
	return {
		"parents": [],
		"category": Categories.GENERAL,
		"priority": 0,
		"suggestions": [],
		"tooltip": "",
		"valid": is_valid_tag
		}


func get_parents(tag_name: String) -> Array[String]:
	var return_parents: Array[String] = []
	
	var unexplored_parents: Array[String] = []
	var explored_parents: Array[String] = []
	
	if not has_tag(tag_name):
		return return_parents
	
	var tag_file: Tag = get_tag(tag_name)
	unexplored_parents.append_array(tag_file.parents)

	while not unexplored_parents.is_empty():
		var tag: String = unexplored_parents.pop_front()
		#print("Exploring parents of: " + tag)
		explored_parents.append(tag) # Add the current to explored
		
		if not return_parents.has(tag): # And to the return ones if it wasn't
			return_parents.append(tag)
		
		if has_tag(tag): # If tag file exist, then add it's parents to list
			var quick: Tag = get_tag(tag)
			for parent in quick.parents:
				if not explored_parents.has(parent) and\
				not unexplored_parents.has(parent):
					unexplored_parents.append(parent)
					# But only if not on queue or already explored
		#print("Unexplored parents: " + str(unexplored_parents))
	
	return return_parents


func get_prioritized_parents(tag_name: String) -> Dictionary:
	var return_parents: Dictionary = {"0": []}
	
	var unexplored_parents: Array[String] = []
	var explored_parents: Array[String] = []
	
	if not has_tag(tag_name):
		return return_parents
	
	var tag_file: Tag = get_tag(tag_name)
	unexplored_parents.append_array(tag_file.parents)
	
	#print("Starting while loop.")
	
	while not unexplored_parents.is_empty():
		var tag: String = unexplored_parents.pop_front()
		#print("Exploring parents of: " + tag)
		
		explored_parents.append(tag) # Add the current to explored

		if has_tag(tag): # If tag file exist, then add it's parents to list
			var quick: Tag = get_tag(tag)
			if not return_parents.has(str(quick.tag_priority)):
				return_parents[str(quick.tag_priority)] = []
			
			return_parents[str(quick.tag_priority)].append(tag)
			
			for parent in quick.parents:
				if not explored_parents.has(parent) and\
				not unexplored_parents.has(parent):
					unexplored_parents.append(parent)
		else:
			return_parents["0"].append(tag)
		
		#print("Explored parents: " + str(explored_parents))
		#print("Unexplored parents: " + str(unexplored_parents))
	
	return return_parents


func get_suggestions(tags_array:Array[String]) -> Dictionary:
	var return_array: Dictionary = {
		"suggestions": [],
		"smart": {}
		}
	
	for tag in tags_array:
		if not has_tag(tag):
			continue
		
		var load_tag: Tag = get_tag(tag)
		for suggestion in load_tag.suggestions:
			if not return_array["suggestions"].has(suggestion):
				return_array["suggestions"].append(suggestion)
		for smart in load_tag.smart_tags:
			if not return_array["smart"].has(smart["title"]):
				return_array["smart"][smart["title"]] = smart

	return return_array


func convert_prefix(prefix: String, string_to_convert: String) -> String:
	var tag_args: Array[String] = split_and_strip(string_to_convert, TAG_SPLIT_CHAR)
	
	return prefixes[prefix].format(tag_args)


func split_and_strip(string_to_split: String, split_mark: String) -> Array[String]:
	var return_array:Array[String] = []
	
	for item in string_to_split.split(split_mark):
		return_array.append(item.strip_edges())
	
	return return_array


## Creates a new confirmation dialog and adds it to the tree. 
## REMEMBER to free it when done.
func create_confirmation_dialog() -> TaggerConfirmationDialog:
	var new_confirmation: TaggerConfirmationDialog = CONFIRMATION_DIALOG.instantiate()
	add_child(new_confirmation)
	return new_confirmation


func _search_local_with_prefix(prefix_search: String, limit: int = -1, invert := true) -> Array[String]:
	var tag_key: String = prefix_search.left(1)
	var return_array: Array[String] = []
	
	if has_alias(prefix_search):
		return_array.push_front(alias_list[tag_key][prefix_search])
		limit -= 1
	elif has_tag(prefix_search):
		return_array.push_front(prefix_search)
		limit -= 1
	
	if loaded_tags.has(tag_key):
		for tag in loaded_tags[tag_key]:
			if limit == 0:
				break
			if tag.begins_with(prefix_search) and not return_array.has(tag):
				if invert:
					return_array.push_front(tag)
				else:
					return_array.push_back(tag)
				limit -= 1
	
	return return_array


func _search_local_with_suffix(suffix_search: String, limit: int = -1, invert := true) -> Array[String]:
	var return_array: Array[String] = []
	
	for key in loaded_tags:
		for tag_name in loaded_tags[key]:
			if limit == 0:
				break
			if tag_name.ends_with(suffix_search) and not return_array.has(tag_name):
				if invert:
					return_array.push_front(tag_name)
				else:
					return_array.push_back(tag_name)
				limit -= 1
	
	return return_array


func _search_local_with_any(any_search: String, limit: int = -1, invert := true) -> Array[String]:
	var return_array: Array[String] = []
	
	for key in loaded_tags:
		for tag_name in loaded_tags[key]:
			if limit == 0:
				break
			if tag_name.contains(any_search) and not return_array.has(tag_name):
				if invert:
					return_array.push_front(tag_name)
				else:
					return_array.push_back(tag_name)
				limit -= 1
	
	return return_array


func save_settings() -> void:
	if not SOURCE_RUN:
		var new_settings := SettingsResource.new()
		#var new_saves := SaveSlots.new()
		
		new_settings.first_run = false
		new_settings.database_path = database_path
		new_settings.load_images = load_images
		new_settings.image_amount = image_amount
		new_settings.default_site = default_site
		new_settings.suggestion_confidence = suggestion_confidence
		new_settings.custom_sites = custom_sites
		new_settings.invalid_tags = invalid_tags
		new_settings.suggestion_blacklist = suggestion_blacklist
		new_settings.constant_tags = constant_tags
		new_settings.prefixes = prefixes
		
		#new_settings.templates = templates
		#new_settings.saves = saves
		#new_saves.saves = saves
		#new_saves.templates = templates
		
		new_settings.search_online_suggestions = search_online_suggestions
		new_settings.hydrus_port = hydrus_port
		new_settings.hydrus_key = hydrus_key
		new_settings.tag_map = tag_map
		new_settings.custom_aliases = custom_aliases
		new_settings.include_invalid = include_invalid
		new_settings.removed_aliases = removed_aliases
		new_settings.remove_after_use = remove_after_use
		new_settings.blacklist_after_remove = blacklist_after_remove
		new_settings.version_notified = version_notified
		new_settings.update_notified = update_notified
		new_settings.save()
	else:
		print("Running from source: Skipping saving settings.")


func log_message(message_to_log: String, message_class := LoggingLevel.NORMAL, queue := false) -> void:
	if message_class == LoggingLevel.NORMAL:
		print("INFO: " + message_to_log)
		message_logged.emit("INFO: " + message_to_log, message_class)
		if queue:
			queued_logs["INFO"].append("INFO: " + message_to_log)
	elif message_class == LoggingLevel.WARNING:
		push_warning(message_to_log)
		message_logged.emit("WARNING: " + message_to_log, message_class)
		if queue:
			queued_logs["WARNING"].append("WARNING: " + message_to_log)
	elif message_class == LoggingLevel.ERROR:
		push_error(message_to_log)
		message_logged.emit("ERROR: " + message_to_log, message_class)
		if queue:
			queued_logs["ERROR"].append("ERROR: " + message_to_log)


func get_queued_logs(log_level: LoggingLevel) -> Array[String]:
	var return_log: Array[String] = []
	
	if queued_logs.is_empty():
		return return_log
	
	if log_level == LoggingLevel.NORMAL:
		return_log.assign(queued_logs["INFO"])
	elif log_level == LoggingLevel.WARNING:
		return_log.assign(queued_logs["WARNING"])
	elif log_level == LoggingLevel.ERROR:
		return_log.assign(queued_logs["ERROR"])
	
	return return_log


func clear_queued_logs() -> void:
	queued_logs.clear()



func is_valid_age_id(age_id: String) -> bool:
	return AGES.has(age_id)


func is_valid_age_tag(age_tag: String) -> bool:
	for age_id in AGES:
		if AGES[age_id]["tag"] == age_tag:
			return true
	return false


func get_age_id(age_tag: String) -> String:
	for age_id in AGES:
		if AGES[age_id]["tag"] == age_tag:
			return age_id
	return "adult"


func get_body_id(body_tags: Array[String]) -> String:
	for body_id in BODY_TYPES:
		if BODY_TYPES[body_id]["tags"] == body_tags:
			return body_id
	return "anthro"


func is_valid_gender_id(gender_id: String) -> bool:
	return GENDERS.has(gender_id)


func is_valid_gender(gender_tag: String) -> bool:
	for gender_id in GENDERS:
		if GENDERS[gender_id]["tag"] == gender_tag:
			return true
	return false


func is_valid_body_tag(body_tag: String) -> bool:
	for body_id in BODY_TYPES:
		if BODY_TYPES[body_id]["tags"].has(body_tag):
			return true
	return false


func get_gender_id(gender_tag: String) -> String:
	for gender_id in GENDERS:
		if GENDERS[gender_id]["tag"] == gender_tag:
			return gender_id
	return "male"


func get_template_idx_with_title(template_title: String) -> int:
	var return_index: int = -1
	for idx in range(templates.size()):
		if templates[idx]["title"] == template_title:
			return_index = idx
			break
	return return_index



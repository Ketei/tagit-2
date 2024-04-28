class_name SettingsResource
extends Resource


# Run variables
@export var first_run: bool = true
@export var database_path: String = ""

# Basic Settings
@export var load_images: bool = false # Hydrus Only
@export var image_amount: int = 16
@export var search_online_suggestions: bool = false
@export var autofill_enabled: bool = true
@export var open_e6_on_wiki_link: bool = true

# Tagger Settings
@export var default_site: String = ""
@export var suggestion_confidence: int = 45:
	set(new_confidence):
		suggestion_confidence = clampi(new_confidence, 0, 100)

# Extra settings:
@export var custom_sites: Dictionary = {}
@export var include_invalid: bool = false

# List Settings
@export var invalid_tags: Array[String] = []
@export var suggestion_blacklist: Array[String] = []
@export var constant_tags: Array[String] = []
@export var custom_aliases: Dictionary = {} # "s": {"sperm": "cum"}
@export var removed_aliases: Dictionary = {} # "s": {"sperm": "cum"}
@export var remove_after_use: bool = false
@export var blacklist_after_remove: bool = false

# Resources | Holds test info for now
@export var prefixes: Dictionary = {"@": "{0} (character)"}
@export var tag_map: Dictionary = {
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
#@export var templates: Array[Dictionary] = [
	#{
		#"title": "Ketei and Wulfre",
		#"desc": "Some hot lewding going on here",
		#"main": ["ketei (character)", "wulfre (character)"],
		#"suggs": ["cum", "male/male"]
	#}
#]

# Saves | Holds test info for now
#@export var saves: Array[Dictionary] = [
	#{
		#"title": "Test Save",
		#"data": {
			#"main": {
				#"vaporeon": {"parents": ["loaded_parent"], "category": Tagger.Categories.GENERAL,	"priority": 0, "suggestions": ["This tag was saved and loaded"], "tooltip": "This is from a save"}
			#},
			#"suggs": ["file", "loaded"],
			#"smart": {"Nipples": {"type": "nbr", "format": "nipple", "min": 0, "max": 16}}
		#}
	#}
#]

# Hydrus
@export var hydrus_port: int = 0
@export var hydrus_key: String = ""


static func get_settings() -> SettingsResource:
	if FileAccess.file_exists("user://settings.tres"):
		return load("user://settings.tres")
	else:
		return SettingsResource.new()


func save() -> void:
	ResourceSaver.save(self, "user://settings.tres")



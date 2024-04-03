class_name SaveSlots
extends Resource


const LOCATION: String = "user://saves.tres"

@export var templates: Array[Dictionary] = [
	#{
		#"title": "Ketei and Wulfre",
		#"desc": "Some hot lewding going on here",
		#"main": ["ketei (character)", "wulfre (character)"],
		#"suggs": ["cum", "male/male"]
	#}
]

# Saves | Holds test info for now
@export var saves: Array[Dictionary] = [
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
]


func save() -> void:
	ResourceSaver.save(
			self,
			LOCATION)


static func get_save_data() -> SaveSlots:
	if FileAccess.file_exists(LOCATION):
		return load(LOCATION)
	else:
		return SaveSlots.new()



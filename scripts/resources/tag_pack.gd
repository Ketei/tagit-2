class_name TagPak
extends Resource

@export var pack_name: String = "Generic Tags"
@export var pack_author: String = "Ketei"
@export var pack_description: String = "Contains some tags"
@export var subfolder: String = "official"
#"species": {
	#"name": "Species",
		#"desc": "Breedable subjects",
		#"categories": {
			#"canine": {
				#"name": "Canine",
				#"desc": "Woof woof bark woof",
				#"tags": {
					#"shibe": {
						#"name": "Shiba Inu",
						#"desc": "Stuffable small warm dogs",
						#"tag": "shiba inu"
					#}
				#}
			#}
		#}
	#}
@export var invalid_tags: Array[String] = []
@export var pack_tag_map: Dictionary = {}

@export var included_tags: Array[Dictionary] = []

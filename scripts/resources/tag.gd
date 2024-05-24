extends Resource
class_name Tag
## A resource that holds all informationa bout a tag.   
## Characters shouldn't never hold the gender as a parent or the species as 
## parent if the character has multiple forms.

## The name of the tag. Please note that whitespaces in tags should be a
## whitespace and not any other symbol like "_" or "-".
@export var tag: String = "":
	set(new_name):
		tag = new_name.to_lower()

## ID user in e621 pages. Does nothing.
@export var tag_id: int = 0

## The name of the file the tag has. This is because some tags have symbols that
## are invalid in filenames like "?" and "<".
@export var file_name: String = "":
	set(new_file):
		file_name = new_file
		if not file_name.ends_with(".tres"):
			file_name += ".tres"

## The priority of the tag. A higher priority means it'll be added to the list
## earlier.
@export var tag_priority: int = 0

## Useful for searching tag types and warnings.
@export var category: Tagger.Categories = Tagger.Categories.GENERAL

## The tags that this tag SHOULD go along with. Ex. "male/male" should go with
## "male".
@export var parents: Array[String] = []

## The tags that this tag is likely to go along with. Ex. "Vaporeon"s USUALLY
## have "blue body"s.
@export var suggestions: Array[String] = []

## Forces aliases registration
@export var aliases: Array[String] = []

## A short description to be showed on hovering the tag on the tagger window.
@export var tooltip: String = ""

## Information about the tag. This is for people to read at review.
@export var wiki_entry: String = ""

# Types: opt: optionbutton, nbr: spinbox number
# opt: has "tags", nbr has "min", "max", "format"
@export var smart_tags: Array[Dictionary] = [ # Example
	#{
		#"title": "fur color", 
		#"data": {"type": "opt", "tags": ["blue fur", "white fur", "fur something"]},
		#}
]


## Saves the resource to user path.
func save() -> String:
	var path: String = Tagger.get_tag_filepath(tag)
	
	if file_name.is_empty():
		file_name = tag.validate_filename() + ".tres"
	
	ResourceSaver.save(
			self, 
			path)
	
	return path


func save_default() -> void:
	if file_name.is_empty():
		file_name = tag.validate_filename() + ".tres"
	
	ResourceSaver.save(
			self,
			Tagger.get_default_tag_filepath(tag))



extends Resource
class_name OldTag
## A resource that holds all informationa bout a tag.   
## Characters shouldn't never hold the gender as a parent or the species as 
## parent if the character has multiple forms.

## The name of the tag. Please note that whitespaces in tags should be a
## whitespace and not any other symbol like "_" or "-".
@export var tag: String = "":
	set(new_name):
		tag = new_name.to_lower()

## The name of the file the tag has. This is because some tags have symbols that
## are invalid in filenames like "?" and "<".
@export var file_name: String = ""

## The priority of the tag. A higher priority means it'll be added to the list
## earlier.
@export var tag_priority: int = 0

## Useful for searching tag types and warnings.
@export var category: Tagger.Categories = Tagger.Categories.GENERAL

## The tags that this tag SHOULD go along with. Ex. "male/male" should go with
## "male".
@export var parents: Array = []

## The tags that this tag SHOULDN'T be used along with. Ex. "solo" shouldn't go
## with "duo". This will only show on look-up.
@export var conflicts: Array[String] = []

## The tags that this tag is likely to go along with. Ex. "Vaporeon"s USUALLY
## have "blue body"s.
@export var suggestions: Array[String] = []

## If true the reviewer will look for pictures to load. If false it won't bother
## looking for files.
@export var has_pictures: bool = true

## Forces aliases registration
@export var aliases: PackedStringArray = []

## A short description to be showed on hovering the tag on the tagger window.
@export var tooltip: String = ""

## Information about the tag. This is for people to read at review.
@export var wiki_entry: String = ""

@export var has_prompt_data: bool = false

@export var prompt_category: String = "":
	set(category):
		prompt_category = just_capitalize(category)
@export var prompt_category_img_tag: String = "":
	set(tag):
		prompt_category_img_tag = tag.to_lower()
@export var prompt_category_desc: String = ""

@export var prompt_subcat: String = "":
	set(subcat):
		prompt_subcat = just_capitalize(subcat)
@export var prompt_subcat_img_tag: String = "":
	set(tag):
		prompt_subcat_img_tag = tag.to_lower()
@export var prompt_subcat_desc: String = ""

@export var prompt_title: String = "":
	set(title):
		prompt_title = just_capitalize(title)
@export var prompt_desc: String = ""
@export var tag_groups: Dictionary = {}


## Saves the resource to user path.
func save() -> String:
	if file_name.is_empty():
		file_name = tag + ".tres"
		if not file_name.is_valid_filename():
			file_name = file_name.validate_filename()
	
	ResourceSaver.save(self, Tagger.tags_path + file_name)
	return file_name


## Gets the tag name appropiate for the site selected. Will be removed most likely.
func get_tag() -> String:
	return tag


func just_capitalize(input_string: String) -> String:
	var building_string: String = input_string.left(1).to_upper()
	building_string += input_string.right(-1)
	return building_string


func get_tag_groups() -> Dictionary:
	for group in tag_groups.keys():
		if typeof(tag_groups[group]) != TYPE_DICTIONARY:
			tag_groups.erase(group)
		else:
			for _tag in tag_groups[group]["tags"]:
				if typeof(tag) != TYPE_STRING:
					tag_groups[group]["tags"].erase(_tag)
	return tag_groups


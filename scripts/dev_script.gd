extends Control


func _ready():
	look_for_repeats()


func look_for_repeats() -> void:
	var tag_dictionary: Dictionary = {}
	
	for tag_index in Tagger.loaded_tags:
		for tag_name in Tagger.loaded_tags[tag_index]:
			var tag_load: Tag = Tagger.get_tag(tag_name)
			for smart_tag in tag_load.smart_tags:
				if smart_tag["data"]["type"] == "nbr":
					continue
				
				for tag_option in smart_tag["data"]["tags"]:
					if not tag_dictionary.has(tag_option):
						tag_dictionary[tag_option] = {"title": smart_tag["title"], "setter": smart_tag["title"] + " | " + tag_name}
					else:
						if tag_dictionary[tag_option]["title"] != smart_tag["title"]:
							print(
								"Inconsistency found. Tag {0} puts \"{1}\" in \"{2}\" but that was placed before by: {3}".format(
									[tag_name, tag_option, smart_tag["title"], tag_dictionary[tag_option]["setter"]]
								)
							)
	#print(tag_dictionary)

func look_for_smart(smart_option: String) -> void:
	for tag_index in Tagger.loaded_tags:
		for tag_name in Tagger.loaded_tags[tag_index]:
			var tag_load: Tag = Tagger.get_tag(tag_name)
			for smart_tag in tag_load.smart_tags:
				if smart_tag["data"]["type"] == "nbr":
					continue
				
				for tag_option in smart_tag["data"]["tags"]:
					if tag_option == smart_option:
						print("Tag {0} with title {1} contains {2}".format(
								[tag_name, smart_tag["title"], smart_option]
						))


func clean_all_aliases() -> void:
	for tag_index in Tagger.loaded_tags:
		for tag_name in Tagger.loaded_tags[tag_index]:
			var tag_load: Tag = Tagger.get_tag(tag_name)
			
			var clean_array: Array[String] = []
			
			for alias in tag_load.aliases:
				var new_alias: String = alias.replace("_", " ")
				if not clean_array.has(new_alias):
					clean_array.append(new_alias)
			
			tag_load.aliases = clean_array.duplicate()
			tag_load.save()
	print("All tag aliases cleaned of the nasty underscore")


#func regrab_all_aliases() -> void:
	#for tag_index in Tagger.loaded_tags:
		#for tag_name in Tagger.loaded_tags[tag_index]:
			#await get_tree().create_timer(1.50).timeout
			#var tag_load: Tag = Tagger.get_tag(tag_name)
			#
			#if tag_load.category == Tagger.Categories.CHARACTER:
				#continue
			#
			#http_request.request(Tagger.get_alias_request_url(tag_name), Tagger.get_headers())
			#var response: Array = await http_request.request_completed
			#if response[0] != 0 or response[1] != 200:
				#print("{0} tag result: {1}, response code {2}".format([tag_load.tag, str(response[0]), str(response[1])]))
				#continue
			#
			#var json = JSON.new()
			#var json_error = json.parse(response[3].get_string_from_utf8())
			#
			#if json_error != OK:
				#print("Json error: {0}".format([str(json_error)]))
				#continue
			#
			#var json_data = json.get_data()
			#
			#if typeof(json_data) == TYPE_DICTIONARY:
				#print("This is a dictionary: {0}".format([tag_load.tag]))
				#continue
			#
			#var active_aliases: Array[String] = []
			#var inactive_aliases: Array[String] = []
			#
			#for entry in json_data:
				#var antecedent_name: String = entry["antecedent_name"]
				#antecedent_name = antecedent_name.replace("_", " ")
				#if entry["status"] == "active":
					#active_aliases.append(antecedent_name)
				#else:
					#inactive_aliases.append(antecedent_name)
			#
			# # We duplicate it to remove from the original without
			# # messing up the loop
			#for bad_alias in tag_load.aliases.duplicate():
				#if inactive_aliases.has(bad_alias):
					#tag_load.aliases.erase(bad_alias)
			#
			#for good_alias in active_aliases:
				#if not tag_load.aliases.has(good_alias):
					#tag_load.aliases.append(good_alias)
			#
			#tag_load.save()
			#
			#print("Tag \"{0}\" is done.".format([tag_load.tag]))
			#


func check_for_bad_suggestions() -> void:
	for tag_index in Tagger.loaded_tags:
		for tag_name in Tagger.loaded_tags[tag_index]:
			var tag_load: Tag = Tagger.get_tag(tag_name)
			if tag_load.suggestions.has("hi res"):
				print("Check tag {0} for uncleared fetches".format([tag_load.tag]))
			if 10 <= tag_load.suggestions.size():
				print("Check tag {0} for uncleared fetches".format([tag_load.tag]))
			for suggestion in tag_load.suggestions:
				if suggestion.begins_with("*") or suggestion.begins_with("#") or suggestion.begins_with("|"):
					print("Tag {0} has invalid suggestion".format([tag_load.tag]))


func summon_empty_tooltip() -> void:
	for tag_index in Tagger.loaded_tags:
		for tag_name in Tagger.loaded_tags[tag_index]:
			var tag_load: Tag = Tagger.get_tag(tag_name)
			if tag_load.tooltip.is_empty():
				print("Tag {0} has it's tooltip empty".format([tag_load.tag]))
 

func convert_tags() -> void:
	for tag_file in DirAccess.get_files_at("D:/Tagger/tags/new_tags/"):
		print("loading: " + "D:/Tagger/tags/new_tags/" + tag_file)
		var convert_tag: OldTag = ResourceLoader.load("D:/Tagger/tags/new_tags/" + tag_file)
		var new_tag: Tag = Tag.new()
		new_tag.tag = convert_tag.tag
		new_tag.file_name = tag_file
		new_tag.tag_priority = convert_tag.tag_priority
		new_tag.category = convert_tag.category
		new_tag.parents.assign(convert_tag.parents)
		new_tag.suggestions = convert_tag.suggestions.duplicate()
		new_tag.aliases.assign(convert_tag.aliases)
		new_tag.tooltip = convert_tag.tooltip
		new_tag.wiki_entry = convert_tag.wiki_entry
		ResourceSaver.save(new_tag, "D:/Tagger/tags/new_tags/convert_tags/" + tag_file)


extends Node

# ConfigRW is responsible for interfacing with the filesystem regarding settings
# and other configuration, as well as saving & loading the current state


@export var ConfigFilename = "settings.cfg"
@export var BackgroundImage: Sprite2D = null
@export var State: Node = null
@export var ResourceManager: Node = null
@export var UI: Node2D = null

func _ready():
	# Check (and possibly create) the required folders
	var dir = DirAccess.open(OS.get_executable_path().get_base_dir())
	if not dir.dir_exists("maps"):
		dir.make_dir("maps")
	if not dir.dir_exists("icons"):
		dir.make_dir("icons")
	if not dir.dir_exists("resources"):
		dir.make_dir("resources")
	
	var config = ConfigFile.new()
	
	# Check if config exists
	var err = config.load(OS.get_executable_path().get_base_dir() + "/" +ConfigFilename)
	if not err:
		# Load the settings from it
		LoadSettings(config)
	else:
		print("No config file found/Other config file error (" + str(err) + ")")

func LoadSettings(config):
	if not BackgroundImage:
		print("Background image nonexistant!")
		return
	
	BackgroundImage.LoadImage(config.get_value("Background", "Image"))
	RenderingServer.set_default_clear_color(
		Color.from_string(config.get_value("Background", "Color", Color.DARK_SLATE_GRAY), Color.BLACK)
	)
	
	# Load the variable sections (currently only maps)
	# Maps are Map + (number)
	var variable_sections = config.get_sections()
	for section in variable_sections:
		if section.begins_with("Map"):
			#It's a map - add it to the list
			var map_name = config.get_value(section, "Name")
			var map_config = config.get_value(section, "Config")
			UI.AddMap(map_name, map_config)

func LoadMapConfig(config):
	# Open the map config file
	var map_config = ConfigFile.new()
	map_config.load(OS.get_executable_path().get_base_dir() + "/" + config)
	
	return map_config

func LoadTokenSettings(config, token):
	var new_data = State.TokenData.new()
	new_data.id = State.GetNewTokenID()
	new_data.icon_filename = config.get_value(token, "Image")
	new_data.name = token	# Section name is treated as the token name too
	new_data.position = config.get_value(token, "Position")
	State.AddToken(new_data)

##########################

func WriteMapSettings(config, scale, tokens, image=null):
	var cfg = ConfigFile.new()
	cfg.set_value("General", "TokenScale", scale)
	
	if config != "":
		cfg.load(OS.get_executable_path().get_base_dir() + "/" + config)
		
		# Old file - keep the first section and rewrite the rest
		var sections = cfg.get_sections()
		sections.remove_at(0)
		for section in sections:
			cfg.erase_section(section)
	else:
		# New file - make the first section
		cfg.set_value("General", "Image", image)
		
	# Write tokens as sections
	for token in tokens:
		cfg.set_value(token.name, "Image", token.icon_filename)
		cfg.set_value(token.name, "Position", token.position)
	
	# Finally, write it to file
	cfg.save(OS.get_executable_path().get_base_dir() + "/" + config)

func _process(delta):
	pass

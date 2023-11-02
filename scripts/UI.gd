extends Node2D

# Handles miscellaneous UI actions, but also map switching

@export var ConfigRW: Node = null
@export var ResourceManager: Node = null
@export var MapDisplay: Sprite2D = null
@export var State: Node = null

@export var MapScaleFactor = 1.1

var new_map_selector_index = 0
var map_configs = []

func AddMap(map_name, map_config):
	# Move the (Add new map) button one place down, replacing it with the new map
	$MapSelector.get_popup().set_item_text(new_map_selector_index, map_name)
	AppendNewMapSelector()
	
	map_configs.append(map_config)

func AppendNewMapSelector():
	# The last item on the list should always be (Add new map)
	$MapSelector.get_popup().add_item("(Add new map)")
	new_map_selector_index += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$MapSelector.get_popup().connect("id_pressed", SwitchMap)
	AppendNewMapSelector()
	
	$MapSelector/MapZoomOut.connect("button_down", MapZoomOut)
	$MapSelector/MapZoomIn.connect("button_down", MapZoomIn)
	
	pass
	
func MapZoomOut():
	State.SetMapScale(State.map_scale / MapScaleFactor)
	
func MapZoomIn():
	State.SetMapScale(State.map_scale * MapScaleFactor)

func SwitchMap(index):
	State.ResetTokens()
	
	if (index == new_map_selector_index):
		print("TODO: Create a new map")
		return
	
	#Index 0 is Empty
	var map_config = ConfigRW.LoadMapConfig(map_configs[index - 1])
	#Configs should ideally be confined to ConfigRW
	#For ease of access, they are currently exposed to the UI
	
	# Basic data from the first section
	var map_image = map_config.get_value("General", "Image")
	State.map_scale = map_config.get_value("General", "IconScale", 1.0)	#TODO
	
	MapDisplay.texture = ResourceManager.GetTexture(map_image)
	State.current_map = map_image
	State.current_map_config = map_configs[index - 1]
	
	# Other sections are considered tokens - load them
	var variable_sections = map_config.get_sections()
	variable_sections.remove_at(0)	# This section was is General
	
	for token in variable_sections:
		ConfigRW.LoadTokenSettings(map_config, token)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

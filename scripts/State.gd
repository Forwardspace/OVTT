extends Node

# State is, of course, responsible for storing and managing Token and Map
# states and initiating redraws for each when neccessary

@export var Main: Node = null
@export var ConfigRW: Node = null
@export var NetworkManager: Node = null
@export var CurrentMap: Node2D = null
@export var ResourceManager: Node = null
@export var UI: Node = null

@export var IsServer: bool = true

var tokens = []
var next_token_id = 0

var current_map = ""
var current_map_config = ""
var current_map_index = 0
var map_scale = 1.0

class TokenData:
	var id = -1				#Internal - do not change outside State
	var icon_filename = ""
	var name = ""
	var position = Vector2(0, 0)
	var initiative = 0
	var relative_scale = 1.0

func AddToken(token):
	tokens.append(token)
	ForceTokenRedraw()
	
func RemoveToken(token):
	var i = 0
	
	# Find matching token and delete it
	for data in tokens:
		if data.id == token.id:
			tokens.remove_at(i)
			ForceTokenRedraw()
			return
			
		i += 1
		
func ResetTokens():
	tokens.clear()
	Main.RedrawTokens(tokens)
	
func ForceTokenRedraw():
	Main.RedrawTokens(tokens)

func FindTokenIndexByID(id):
	var idx = 0
	for token in tokens:
		if token.id == id:
			return idx
		idx += 1
	
	print("No token with ID (" + str(id) + ")")
	return -1

func GetNewTokenID():
	next_token_id += 1
	return next_token_id

func UpdateTokenPositionNoRedraw(token):
	var index = FindTokenIndexByID(token.id)
	
	tokens[index].position = token.position
	
	var meta = {}
	meta.event = "send-token-position"
	meta.token_id = index
	meta.position_x = token.position.x
	meta.position_y = token.position.y
	NetworkManager.SendJSON(meta)

func UpdateTokenPositionNetwork(meta):
	tokens[meta.token_id].position = Vector2(meta.position_x, meta.position_y)
	
	ForceTokenRedraw()
	
func UpdateTokenNameNoRedraw(token, name):
	var index = FindTokenIndexByID(token.id)
	
	tokens[index].name = name
	
	var meta = {}
	meta.event = "send-token-name"
	meta.token_id = index
	meta.name = name
	NetworkManager.SendJSON(meta)
	
func UpdateTokenNameNetwork(meta):
	tokens[meta.token_id].name = meta.name
	
	ForceTokenRedraw()

#######################

func SetMapScale(scale):
	map_scale = scale
	ForceTokenRedraw()

#######################

func SaveCurrentState():
	ConfigRW.WriteMapSettings(current_map_config, map_scale, tokens)

#######################

func SendMapStateToClients():
	if current_map == "":
		return # No need to send anything
	
	var meta = {}
	meta.event = "send-map-state"
	meta.map_name = current_map
	meta.map_index = current_map_index
	meta.map_scale = map_scale
	
	NetworkManager.SendJSON(meta)

func RecieveMapStateFromServer(state):
	UI.SwitchMap(state.map_index)
	SetMapScale(state.map_scale)

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

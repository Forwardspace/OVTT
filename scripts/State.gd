extends Node

# State is, of course, responsible for storing and managing Token and Map
# states and redrawing each when neccessary

@export var Main: Node = null
@export var ConfigRW: Node = null

@export var IsServer: bool = true

var tokens = []
var next_token_id = 0

var current_map = ""
var current_map_config = ""
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
	tokens[FindTokenIndexByID(token.id)].position = token.position
	
func UpdateTokenNameNoRedraw(token, name):
	tokens[FindTokenIndexByID(token.id)].name = name

#######################

func SetMapScale(scale):
	map_scale = scale
	ForceTokenRedraw()

#######################

func SaveCurrentState():
	ConfigRW.WriteMapSettings(current_map_config, map_scale, tokens)

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

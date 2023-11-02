extends Node2D

@export var TokenHolder: Node2D = null
@export var ResourceManager: Node = null
@export var State: Node = null

@export var TokenScene = ""

func RedrawTokens(data):
	# Remove all existing tokens
	for token in TokenHolder.get_children():
		token.queue_free()
	
	#Add all tokens from data
	for token in data:
		var new_token = load(TokenScene).instantiate()
		new_token.ResourceManager = ResourceManager
		new_token.State = State
		new_token.id = token.id
		
		new_token.SetName(token.name)
		new_token.SetIcon(token.icon_filename)
		
		new_token.scale *= State.map_scale
		new_token.position = token.position
		
		TokenHolder.add_child(new_token)

func _notification(notif):
	if notif == NOTIFICATION_WM_CLOSE_REQUEST:
		# Save current state
		State.SaveCurrentState()
		
		get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

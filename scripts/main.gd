extends Node2D

@export var TokenHolder: Node2D = null
@export var ResourceManager: Node = null
@export var State: Node = null

@export var TokenScene = ""

var redraw_cooldown = 0
var redraw_pending = false

func RedrawTokens(data, set_pending=true):
	# The idea is to limit token redraw to every n frames, as
	# redrawing is CPU and memory intensive
	if set_pending:
		redraw_pending = true
	
	if redraw_cooldown <= 0:
		if not redraw_pending:
			return
		else:
			redraw_cooldown = 20	# Reset to default cooldown
	else:
		redraw_cooldown -= 1		# Redraw at most every 20 frames
		return
		
	redraw_pending = false
	
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

# Handle quit notification - save current state
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
	RedrawTokens(State.tokens, false)	# Redraw only if needed

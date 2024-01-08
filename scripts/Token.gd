extends Sprite2D

# Token is a UI representation of an entry in State's "tokens" array

@export var ResourceManager: Node = null
@export var State: Node = null

var id = -1

var dragging = false

func SetName(name):
	$Name.text = name

func SetIcon(filename):
	if filename == "" or filename == null:
		return
	
	texture = ResourceManager.GetTexture(filename)	

func _unhandled_input(event):
	# Check for drag events
	if event is InputEventMouseButton:
		if event.pressed:
			if get_rect().has_point(get_local_mouse_position()):
				# Mouse pressed on sprite
				dragging = true
				get_viewport().set_input_as_handled()
		else:
			dragging = false
	elif event is InputEventMouseMotion:
		if dragging:
			global_position += event.relative
			State.UpdateTokenPositionNoRedraw(self)
			get_viewport().set_input_as_handled()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Name.connect("text_changed", UpdateName)

func UpdateName(text):
	State.UpdateTokenNameNoRedraw(self, text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

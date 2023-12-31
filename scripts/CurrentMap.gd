extends Sprite2D

@export var ScaleFactor = 1.10

var dragging = false

func _unhandled_input(event):
	if event.is_action_pressed("ZoomIn"):
		ZoomIn()
	elif event.is_action("ZoomOut"):
		ZoomOut()
	elif event is InputEventMouseButton:
		dragging = event.pressed
	elif event is InputEventMouseMotion:
		if dragging:
			position += event.relative
	else:
		return

	get_viewport().set_input_as_handled()

func ZoomIn():
	scale *= ScaleFactor
	
func ZoomOut():
	scale /= ScaleFactor

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Sprite2D

@export var ResourceManager: Node = null

func LoadImage(filename):
	texture = ResourceManager.GetTexture(filename)


func _ready():
	pass

func _process(delta):
	# Center the background in the middle of the screen
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y

	position = Vector2(viewportWidth / 2, viewportHeight / 2)

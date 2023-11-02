extends Node2D

@export var State: Node = null

@export var AvailableDice = [4, 6, 8, 10, 12, 20]
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AddButton.connect("button_down", AddPressed)
	
	#Set up the dice rolling menu
	var popup = $DiceRollButton.get_popup()
	for dice in AvailableDice:
		popup.add_item("D" + str(dice))
		
	popup.connect("id_pressed", DiceRollPressed)

func AddPressed():
	# Adds a new, default, token
	var token = State.TokenData.new()
	token.id = State.GetNewTokenID()
	token.name = "New Token"
	
	State.AddToken(token)

func DiceRollPressed(id):
	# Rolls the specified die!
	$DiceRollButton/DieResult.text = str(rng.randi_range(1, AvailableDice[id]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

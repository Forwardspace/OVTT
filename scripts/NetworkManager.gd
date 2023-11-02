extends Node

@export var ServerURL = "192.168.100.30:4174"
@export var State: Node = null
@export var ResourceManager: Node = null

var client = WebSocketPeer.new()
var connected = false

func Connect():
	ConnectToServer()
	
func SendBroadcast(msg):
	client.put_packet(("B" + msg).to_utf8_buffer())
	
func SendInitialTransfer(msg):
	client.put_packet(("I" + msg).to_utf8_buffer())

func EndInitialTransfer(msg):
	client.put_packet("E".to_utf8_buffer())
	
func ConnectToServer():
	var err = client.connect_to_url(ServerURL, TLSOptions.client_unsafe())
	if err != OK:
		print("Unable to connect to server!")

func ReceiveData():
	var msg = client.get_packet().get_string_from_utf8()
	if msg[0] == "A":
		# New peer connected
		ResourceManager.TransferInitialResourcesToClients()
	else:
		var data = JSON.parse_string(msg)
		print(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	Connect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	client.poll()
	if client.get_available_packet_count():
		ReceiveData()

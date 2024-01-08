extends Node

@export var ServerURL = ""
@export var State: Node = null
@export var ResourceManager: Node = null
@export var Port = 4174

var IsServer = false

var client = WebSocketPeer.new()
var max_packet_length = 1024 * 16
var max_decompress_buffer_length = max_packet_length
var connected = false

var package_buffer = []

func Connect():
	ConnectToServer()
	
func SendJSON(json):
	client.send_text(JSON.stringify(json))
	
func ConnectToServer():
	var err = client.connect_to_url(ServerURL, TLSOptions.client_unsafe())
	client.set_inbound_buffer_size(max_packet_length * 768)
	client.set_outbound_buffer_size(max_packet_length * 768)
	if err != OK:
		print("Unable to connect to server!")

var recieving_data = false
var reciever_function = null

var num_packages = 0
var data_recieved = null

func ReceiveData():
	if recieving_data:
		reciever_function.call()
	else:
		var msg = client.get_packet().get_string_from_ascii()
		if IsServer and msg == "A":
			# New peer connected
			print("Sending initial resources...")
			ResourceManager.TransferInitialResourcesToClients()
		else:
			# Some complex data was sent
			# It must start with a JSON header
			var meta = JSON.parse_string(msg)
			if meta == null:
				return
			
			if meta["event"] == "send-image":
				#TODO: resource transfer over network
				pass
			elif meta["event"] == "send-map-state":
				State.RecieveMapStateFromServer(meta)
			elif meta["event"] == "send-token-position":
				State.UpdateTokenPositionNetwork(meta)
			elif meta["event"] == "send-token-name":
				State.UpdateTokenNameNetwork(meta)

# Called when the node enters the scene tree for the first time.
func _ready():
	Connect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	client.poll()
	if client.get_available_packet_count():
		ReceiveData()

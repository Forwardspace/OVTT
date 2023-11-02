extends Node

# Manages (mostly image) resources by eliminating duplicate loading
# and automatically transferring resources to connected peers
# Main purpose is to keep clients and servers fully synchronized

@export var State: Node = null
@export var NetworkManager: Node = null

var resources = []

class TextureResource:
	var filename = ""
	var resource = null

func GetTexture(filename):
	# Find resource among existing ones
	var existingResource = GetTextureOrNull(filename)
	if existingResource:
		# Great, no need to load anything
		return existingResource
		
	# None found - are we a server?
	if State.IsServer:
		#Yes - simply load it from disk
		var newResource = LoadTextureResourceFromFile(filename)
		
		return newResource.resource
	else:
		#Uhhhh... something failed to transfer
		print("Resource missing (" + filename + ")")

func GetTextureOrNull(filename):
	for resource in resources:
		if resource.filename == filename:
			return resource.resource
	return null

func LoadTextureResourceFromFile(filename):
	var path_prefix = OS.get_executable_path().get_base_dir() + "/"
	var image = Image.load_from_file(path_prefix + filename)
	
	print(path_prefix + filename)
	
	var resource = TextureResource.new()
	resource.resource = ImageTexture.create_from_image(image)
	resource.filename = filename
	resources.append(resource)
	
	SendImageToClients(resource.filename, image)
	
	return resource
	
func LoadTextureResourceFromData(image):
	var resource = TextureResource.new()
	resource.filename = image["filename"]
	resource.resource = Image.create_from_data(image["width"], image["height"], false, Image.FORMAT_RGB8, image["data"])
	resources.append(resource)
	
	return	# This should not need to return anything; loading should happen in advance

func CopyDroppedIcon(path):
	var file = "/icons/" + path.get_file()
	DirAccess.copy_absolute(path, OS.get_executable_path().get_base_dir() + file)

func CopyDroppedMap(path):
	var file = "/maps/" + path.get_file()
	DirAccess.copy_absolute(path, OS.get_executable_path().get_base_dir() + file)

#################### NETWORKING

func SendImageToClients(filename, image):
	# The transfer is done like this:
	# Image -> dictionary -> JSON -> Bytes over network
	var data = image.data
	data["filename"] = filename
	NetworkManager.SendBroadcast(JSON.stringify(data))
	
func SendImageToClientsInitial(filename, image):
	var data = image.data
	data["filename"] = filename
	NetworkManager.SendInitialTransfer(JSON.stringify(data))
	
func TransferInitialResourcesToClients():
	# Image data is not stored after loading (only texures are, which store data in the GPU)
	# Therefore, we have to load the images again
	var path_prefix = OS.get_executable_path().get_base_dir() + "/"
	
	for resource in resources:
		var image = Image.load_from_file(path_prefix + resource.filename)
		SendImageToClientsInitial(resource.filename, image)	
		
	NetworkManager.EndInitialTransfer()
			
func ReceiveTextureResourceFromServer(data):
	var dict = JSON.parse_string(data)
	for res in resources:
		if res.filename == dict["filename"]:
			return 	# We already have this resource
			
	LoadTextureResourceFromData(dict)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

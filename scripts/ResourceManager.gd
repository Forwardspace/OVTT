extends Node

# Manages (mostly image) resources by eliminating duplicate loading
# and automatically transferring resources to connected peers (WIP)
# Main purpose is to keep clients and servers fully synchronized

@export var State: Node = null
@export var NetworkManager: Node = null

var resources = []
var raw_data = []

class TextureResource:
	var filename = ""
	var resource = null

func GetTexture(filename):
	# Find resource among existing ones
	var existingResource = GetTextureOrNull(filename)
	if existingResource:
		# Great, no need to load anything
		return existingResource
	else:
		# Simply load it from disk
		var newResource = LoadTextureResourceFromFile(filename)
		return newResource.resource

func GetTextureOrNull(filename):
	for resource in resources:
		if resource.filename == filename:
			return resource.resource
	return null

func LoadTextureResourceFromFile(filename):
	var path_prefix = OS.get_executable_path().get_base_dir() + "/"
	
	var image = Image.new()
	var err = image.load(path_prefix + filename)
	if err != OK:
		print("Error in loading resource from file (" + str(err) +")")
		
	var data = image.data
	# Augment the data structure by adding filename and format metadata to it
	data.filename = filename
	data.format_int = image.get_format()		# This is useful later when sending it over network
	raw_data.append(data)
	
	var resource = TextureResource.new()
	resource.resource = ImageTexture.create_from_image(image)
	resource.filename = filename
	resources.append(resource)
	
	#SendImageToClients(data) WIP
	
	return resource
	
func LoadTextureResourceFromData(image):
	var resource = TextureResource.new()
	resource.filename = image["filename"]
	resource.resource = Image.create_from_data(image["width"], image["height"], false, image["format_int"], image["data"])
	resources.append(resource)
	
	print("Added " + resource.filename)
	print("Size: " + str(resource.resource.data.size()))
	
	return	# This should not need to return anything; loading should happen in advance

# Dropped icons should be copied to icons directory
func CopyDroppedIcon(path):
	var file = "/icons/" + path.get_file()
	DirAccess.copy_absolute(path, OS.get_executable_path().get_base_dir() + file)

# Dropped maps should be copied to maps directory
func CopyDroppedMap(path):
	var file = "/maps/" + path.get_file()
	DirAccess.copy_absolute(path, OS.get_executable_path().get_base_dir() + file)

#################### NETWORKING

#func SendImageToClients(image):
#	NetworkManager.SendImageResource(image)
	
func TransferInitialResourcesToClients():
	# Note: Network resource transfer is currently WIP
	# Just send map state (map, tokens, ...) for now
	
	# Image data is not stored after loading (only texures are, which store data in the GPU)
	# Therefore, we have to load the images again
#	var path_prefix = OS.get_executable_path().get_base_dir() + "/"
	
#	for data in raw_data:
#		SendImageToClients(data)
		
	State.SendMapStateToClients()
			
#func ReceiveTextureResourceFromServer(data):
#	for res in resources:
#		if res.filename == data["filename"]:
#			return 	# We already have this resource
			
#	LoadTextureResourceFromData(data)
#	print("Added: " + data["filename"])

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

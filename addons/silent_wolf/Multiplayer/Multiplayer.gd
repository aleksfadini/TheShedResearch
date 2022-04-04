extends Node

onready var WSClient = Node.new()
var ws_client_script = load("res://addons/silent_wolf/Multiplayer/ws/WSClient.gd")

func _ready():
	pass


func init_mp_session():
	WSClient.set_script(ws_client_script)
	add_child(WSClient)


func send(data: Dictionary):
	# First check that WSClient is in tree
	print("Attempting to send data to web socket server")
	if WSClient.is_inside_tree():
		# TODO: check if data is properly formatted (should be dictionary?)
		print("Sending data to web socket server...")
		WSClient.send_to_server(data)

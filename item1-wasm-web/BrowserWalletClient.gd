extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


var _wallet_connected = JavaScript.create_callback(self, "walletConnected")


func _on_Button_pressed():
	if OS.has_feature('JavaScript'):
		if JavaScript.eval("window.solana && window.solana.isPhantom"):
			print("cb: ", _wallet_connected)
			
			var provider = JavaScript.get_interface("solana")
			print("provider: ", provider)
			
			var promise = provider.connect()
			print("promise: ", promise)
			print("then: ", promise.then)
			
			var after_then = promise.then(_wallet_connected)
			print("after then: ", after_then)
	else:
		print("A browser's JavaScript is not accessible from a game engine")


func walletConnected(args):
	var resp = args[0]
	print("resp: ", resp)
	print("wallet address: ", resp.publicKey.toString())
	var provider = JavaScript.get_interface("solana")
	print("pk1: ", provider.publicKey)
	print("pk2: ", provider.publicKey.toString())

extends Node


var provider = null
var wallet_address = null

onready var messages = $Messages
onready var connectBtn = $Connect
onready var disconnectBtn = $Dissconect
onready var signMessageBtn = $SignMessage

var _wallet_connected = JavaScript.create_callback(self, "walletConnected")
var _wallet_disconnected = JavaScript.create_callback(self, "walletDisconnected")
var _wallet_message_signed = JavaScript.create_callback(self, "walletMessageSigned")

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature('JavaScript'):
		if JavaScript.eval("window.solana && window.solana.isPhantom"):
			provider = JavaScript.get_interface("solana")
			if provider != null:
				messages.append_bbcode("Phantom wallet exists in the browser\n")
				setButtonsState(false)

				provider.connect({ onlyIfTrusted = true }).then(_wallet_connected)
	else:
		print("A browser's JavaScript is not accessible from a game engine")


func setButtonsState(connected):
	connectBtn.disabled = connected
	disconnectBtn.disabled = !connected
	signMessageBtn.disabled = !connected


func walletConnected(args):
	var resp = args[0]
	wallet_address = resp.publicKey.toString()
	
	messages.add_text("Wallet connected\n")
	print("wallet address: ", wallet_address)	
	messages.add_text("Wallet address: " + wallet_address + "\n")
	setButtonsState(true)


func walletDisconnected(_args):
	print("wallet disconnected")
	print("is connected: ", isWalletConnected())
	messages.append_bbcode("Wallet disconnected\n")
	wallet_address = null
	setButtonsState(false)


func walletMessageSigned(args):
	var resp = args[0]

	var pubkey = resp.publicKey.toString()
	var raw_signature = resp.signature.toString()
	var signature = raw_signature.to_ascii()
	
	print("pubkey: ", pubkey)
	print("signature: ", signature)
	messages.append_bbcode("Pubkey: {pubkey}\nSignature: {signature}\n".format({
		pubkey = pubkey,
		signature = signature.hex_encode()
	}))
	

func isWalletConnected():
	return JavaScript.eval("window.solana.isConnected")


func _on_Connect_pressed():
	print("connect pressed")
	if provider == null:
		return
	provider.connect().then(_wallet_connected)


func _on_Dissconect_pressed():
	print("disconnect pressed")
	if provider == null and wallet_address == null:
		return
	provider.disconnect().then(_wallet_disconnected)
	print("disconnect preformed")


func _on_SignMessage_pressed():
	print("sign message pressed")
	if provider == null and wallet_address == null:
		return
	if isWalletConnected():		
		var message = "To avoid digital dognappers, sign below to authenticate with TheShed"
		var TextEncoder = JavaScript.create_object("TextEncoder")
		var encodedMessage = TextEncoder.encode(message)
		provider.signMessage(encodedMessage, "utf8").then(_wallet_message_signed)


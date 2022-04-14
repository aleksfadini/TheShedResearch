extends Node


var provider = null
var wallet_address = null

onready var messages = $Messages
onready var connectBtn = $Connect
onready var autoConnect = $Autoconnect

var _wallet_connected = JavaScript.create_callback(self, "walletConnected")
var _wallet_disconnected = JavaScript.create_callback(self, "walletDisconnected")
var _wallet_message_signed = JavaScript.create_callback(self, "walletMessageSigned")

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("_ready")

#	if OS.has_feature('JavaScript'):
#		if isWalletAvailable():
#			provider = JavaScript.get_interface("solana")
#			if provider != null:
#				messages.append_bbcode("Phantom wallet exists in the browser\n")
#				setButtonsState(false)
#				autoConnect.disabled = false
#
#				stateRestore()
#				if state.get("autoconnect") != null:
#					autoConnect.pressed = state.autoconnect
#	else:
#		var msg = "A browser's JavaScript is not accessible from a game engine"
#		messages.append_bbcode(msg)
#		print(msg)
#	messages.append_bbcode("\nconnect your wallet or press play to play without wallet connection")

	update_buttons()

func setButtonsState(connected):
	connectBtn.disabled = connected


#func walletConnect(onlyIfTrusted = false):
#	provider.connect({ onlyIfTrusted = onlyIfTrusted }).then(_wallet_connected)

#
#func walletDisconnect():
#	provider.disconnect().then(_wallet_disconnected)

#
#func walletConnected(args):
#	var resp = args[0]
#	wallet_address = resp.publicKey.toString()
#
#	messages.add_text("Wallet connected\n")
#	print("wallet address: ", wallet_address)	
#	messages.add_text("Wallet address: " + wallet_address + "\n")
#	setButtonsState(true)


#func walletDisconnected(_args):
#	print("wallet disconnected")
#	print("is connected: ", isWalletConnected())
#	messages.append_bbcode("Wallet disconnected\n")
#	wallet_address = null
#	setButtonsState(false)


#func walletMessageSigned(args):
#	var resp = args[0]
#
#	var pubkey = resp.publicKey.toString()
#	var raw_signature = resp.signature.toString()
#	var signature = raw_signature.to_ascii()
#
#	print("pubkey: ", pubkey)
#	print("signature: ", signature)
#	messages.append_bbcode("Pubkey: {pubkey}\nSignature: {signature}\n".format({
#		pubkey = pubkey,
#		signature = signature.hex_encode()
#	}))
	

#func isWalletConnected():
#	return JavaScript.eval("window.solana.isConnected")


func isWalletAvailable():
	if OS.has_feature('JavaScript'):
		if JavaScript.eval("window.solana && window.solana.isPhantom"):
			return true
	return false


func _on_Connect_pressed():
	print("connect pressed")
	if WalletConnectionApi.provider == null:
		return
	WalletConnectionApi.walletConnect()
	update_buttons()


func _on_Dissconect_pressed():
	print("disconnect pressed")
	if provider == null and wallet_address == null:
		return
	WalletConnectionApi.walletDisconnect()
	update_buttons()
	print("disconnect preformed")


func _on_SignMessage_pressed():
	WalletConnectionApi._on_SignMessage_pressed()
	update_buttons()
#	print("sign message pressed")
#	if provider == null and wallet_address == null:
#		return
#	if isWalletConnected():		
#		var message = "To avoid digital dognappers, sign below to authenticate with TheShed"
#		var TextEncoder = JavaScript.create_object("TextEncoder")
#		var encodedMessage = TextEncoder.encode(message)
#		provider.signMessage(encodedMessage, "utf8").then(_wallet_message_signed)

#
#var statePath = "user://godot.state"
#var state = {}
#
#
#func stateSave(new_state):
#	var storage = File.new()
#	storage.open(statePath, File.WRITE)
#	storage.store_line(to_json(new_state))
#	storage.close()
#
#
#func stateRestore():
#	var storage = File.new()
#	storage.open(statePath, File.READ)
#	state = JSON.parse(storage.get_line()).result
#	storage.close()
#
#	if !state:
#		state = {}
#
#	return state


func _on_Autoconnect_toggled(button_pressed):
	WalletConnectionApi._on_Autoconnect_toggled(button_pressed)


func _on_Play_pressed():
#	print("play pressed")
#	get_parent().get_parent().get_parent().launch_game()
	get_parent().get_parent().launch_game()
	pass # Replace with function body.

func update_buttons():
	if WalletConnectionApi.wallet_connected:
		setButtonsState(true)
	else:
		setButtonsState(false)
	if WalletConnectionApi.autoconnect_active:
		autoConnect.pressed=true
	else:
		autoConnect.pressed=false

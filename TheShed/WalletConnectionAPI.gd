extends Node


var provider = null
var wallet_address = null

signal wallet_messages_updated

onready var messages:= ""
#onready var connectBtn = $Connect
#onready var disconnectBtn = $Dissconect
#onready var signMessageBtn = $SignMessage
#onready var autoConnect = $Autoconnect

var wallet_connected:= false
var autoconnect_active:= false

var _wallet_connected = JavaScript.create_callback(self, "walletConnected")
var _wallet_disconnected = JavaScript.create_callback(self, "walletDisconnected")
var _wallet_message_signed = JavaScript.create_callback(self, "walletMessageSigned")

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("_ready")

	if OS.has_feature('JavaScript'):
		if isWalletAvailable():
			provider = JavaScript.get_interface("solana")
			if provider != null:
				append_message("Phantom wallet exists in the browser\n")
				setConnectionGlobalVar(false)
				autoconnect_active = false

				stateRestore()
				if state.get("autoconnect") != null:
					autoconnect_active = state.autoconnect
	else:
		var msg = "A browser's JavaScript is not accessible from a game engine"
		append_message("\n"+msg)
		print(msg)
	append_message("\nconnect your wallet or press play to play without wallet connection")

func setConnectionGlobalVar(connected):
	wallet_connected=connected
#	connectBtn.disabled = connected
#	disconnectBtn.disabled = !connected
#	signMessageBtn.disabled = !connected

func walletConnect(onlyIfTrusted = false):
	provider.connect({ onlyIfTrusted = onlyIfTrusted }).then(_wallet_connected)

func walletDisconnect():
	provider.disconnect().then(_wallet_disconnected)

func walletConnected(args):
	var resp = args[0]
	wallet_address = resp.publicKey.toString()
	
	append_message("\nWallet connected\n")
	print("wallet address: ", wallet_address)	
	append_message("\nWallet address: " + wallet_address + "\n")
	setConnectionGlobalVar(true)

func walletDisconnected(_args):
	print("wallet disconnected")
	print("is connected: ", isWalletConnected())
	append_message("Wallet disconnected\n")
	wallet_address = null
	setConnectionGlobalVar(false)

func walletMessageSigned(args):
	var resp = args[0]

	var pubkey = resp.publicKey.toString()
	var raw_signature = resp.signature.toString()
	var signature = raw_signature.to_ascii()
	
	print("pubkey: ", pubkey)
	print("signature: ", signature)
	append_message("Pubkey: {pubkey}\nSignature: {signature}\n".format({
		pubkey = pubkey,
		signature = signature.hex_encode()
	}))

func isWalletConnected():
	return JavaScript.eval("window.solana.isConnected")

func isWalletAvailable():
	if OS.has_feature('JavaScript'):
		if JavaScript.eval("window.solana && window.solana.isPhantom"):
			return true
	return false

func _on_Connect_pressed():
	print("connect pressed")
	if provider == null:
		return
	walletConnect()

func _on_Dissconect_pressed():
	print("disconnect pressed")
	if provider == null and wallet_address == null:
		return
	walletDisconnect()
	print("disconnect preformed")


# Ask To Confirm Wallet Transaction / Sign Message

func _on_SignMessage_pressed():
	print("sign message pressed")
	if provider == null and wallet_address == null:
		return
	if isWalletConnected():		
		var message = "Sign with your wallet to authenticate TheShed Score"
		var TextEncoder = JavaScript.create_object("TextEncoder")
		var encodedMessage = TextEncoder.encode(message)
		provider.signMessage(encodedMessage, "utf8").then(_wallet_message_signed)

# Save Connected State

var statePath = "user://godot.state"
var state = {}

func stateSave(new_state):
	var storage = File.new()
	storage.open(statePath, File.WRITE)
	storage.store_line(to_json(new_state))
	storage.close()

func stateRestore():
	var storage = File.new()
	storage.open(statePath, File.READ)
	state = JSON.parse(storage.get_line()).result
	storage.close()

	if !state:
		state = {}

	return state

# auto connect check if autoconnect toggled

func _on_Autoconnect_toggled(button_pressed):
	state["autoconnect"] = button_pressed
	stateSave(state)

	if isWalletAvailable() && !isWalletConnected() && button_pressed:
		walletConnect()

func append_message(added_text:=""):
	messages+=added_text
	emit_signal("wallet_messages_updated")

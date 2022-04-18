extends Node2D

var player_name := ""
func _ready():
	$Instructions/InstructionsAnim.play("show")
	$Instructions/Arrows/score.text=str(Globals.score)
	update_connection_status()
	connect("wallet_messages_updated",self,"update_connection_status")

#	update_leaderboard()
func update_connection_status():
	if WalletConnectionApi.wallet_connected:
		player_name=WalletConnectionApi.wallet_address
		$Instructions/Arrows/wallet.self_modulate=Color(0,1,0)
		$Instructions/Arrows/wallet.text=WalletConnectionApi.conv_wallet_to_short_string_hr(player_name)
	else:
		player_name=""
		$Instructions/Arrows/wallet.self_modulate=Color(1,0,0)
		$Instructions/Arrows/wallet.text="NOT CONNECTED"
		
#func _process(delta):
#	delta_sum += delta
#	if delta_sum >=1.0:
#		if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_accept"):
#			Globals.next_stage=1	

func open_tweet():
	OS.shell_open("https://twitter.com/intent/tweet?text=I%20just%20scored%20"+str(Globals.score)+"%20on%20The%20Shed%20by%20@Sol_Tunes%21%20%20%0a%0aFull%20version%20coming%20soon%2C%20where%20you%20can%20compete%20for%20WL%20spots%21%20Think%20you%20can%20beat%20me%3F%0a%0a&hashtags=SolanaNFTs%2CSolana%2CNFT%2CGameFi%2CSolTunes%2CTheShedScore%0a&url=https%3A%2F%2Fshed.soltunes.io%0a%0a")
#	OS.shell_open("https://twitter.com/intent/tweet?url=https%3A%2F%2Fsoltunes.io%2Ftheshed&text=I%20just%20scored%20"+str(Globals.score)+"%20on%20The%20Shed%20by%20@Sol_Tunes%21%20%20%0a%0aFull%20version%20coming%20soon%2C%20where%20you%20can%20compete%20for%20WL%20spots%21Think%20you%20can%20beat%20me%3F%0a&hashtags=SolanaNFTs%2CSolana%2CNFT%2CGameFi%2CSolTunes%2CTheShedScore")

func save_and_tweet():
#	if player_name =="":
#		flash_overlay("noWallet")
#	elif not Globals.competition_active:
#		flash_overlay("epochEnded")
#	else:
#		SilentWolf.Scores.persist_score(player_name, Globals.score)
	open_tweet()
	Globals.next_stage=1
	Globals.reset_score()
	get_tree().change_scene("res://TitleScreen.tscn")
	
func update_leaderboard():
	yield(SilentWolf.Scores.get_high_scores(7), "sw_scores_received")
	for score in SilentWolf.Scores.scores:
		pass
	pass
	

func flash_overlay(type_of_error:="noWallet"):
	if type_of_error=="noWallet":
		$EmptyNameOverlay/Label.text="WALLET NOT CONNECTED!"
	elif type_of_error=="epochEnded":
		$EmptyNameOverlay/Label.text="EPOCH ENDED!\nCannot submit score."
		$EmptyNameOverlay/Arrow.hide()
		$EmptyNameOverlay/Arrow2.hide()
		$EmptyNameOverlay/Arrow3.hide()
	else:
		$EmptyNameOverlay/Label.text="Error 1069!"
	$EmptyNameOverlay/errorEmpty.play("show")
	pass

func _on_Button_pressed():
	print("PRESSED")
	save_and_tweet()
	pass # Replace with function body.


func _on_LineEdit_text_entered(new_text):
	player_name=new_text
	pass # Replace with function body.


func _on_LineEdit_text_changed(new_text):
	player_name=new_text
	pass # Replace with function body.

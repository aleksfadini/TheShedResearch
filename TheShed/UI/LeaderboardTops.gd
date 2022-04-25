tool
extends Node2D

const ScoreItem = preload("res://UI/ScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var list_index = 0
# Replace the leaderboard name if you're not using the default leaderboard
var ld_name = "main"

var tot_scores_displayed=30

var array_of_existent_score_names=[]
var playernames_hidden=["@composableintrn","@Composableinrn","@ComposableInrn", "@yaevin"]

var top_displayed=10
var display_count=0
var secret_wallets_array=[]
var secret_top = 5

func _ready():
#	print("SilentWolf.Scores.leaderboards: " + str(SilentWolf.Scores.leaderboards))
#	print("SilentWolf.Scores.ldboard_config: " + str(SilentWolf.Scores.ldboard_config))
	#var scores = SilentWolf.Scores.scores
	var scores = []
	if ld_name in SilentWolf.Scores.leaderboards:
		scores = SilentWolf.Scores.leaderboards[ld_name]
	var local_scores = SilentWolf.Scores.local_scores
	
	if len(scores) > 0: 
		render_board(scores, local_scores)
	else:
		# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
		add_loading_scores_message()
		yield(SilentWolf.Scores.get_high_scores(tot_scores_displayed), "sw_scores_received")
		hide_message()
		render_board(SilentWolf.Scores.scores, local_scores)
	var time=Globals.epoch_deadline
#	var display_string : String = "%d/%02d/%02d %02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute];
	var display_string : String = "2022/4/23 11:59PM - midnight EST"
	$TitleContainer/EpochEnd.text="Epoch Ends: " + display_string
	$TitleContainer/TimeLeft.text="Time Left: " + Globals.time_left_as_string
		


func render_board(scores, local_scores):
	var all_scores = scores
	if ld_name in SilentWolf.Scores.ldboard_config and is_default_leaderboard(SilentWolf.Scores.ldboard_config[ld_name]):
		all_scores = merge_scores_with_local_scores(scores, local_scores)
		if !scores and !local_scores:
			add_no_scores_message()
	else:
		if !scores:
			add_no_scores_message()
	if !all_scores:
		for score in scores:
			add_item(score.player_name, str(int(score.score)))
	else:
		for score in all_scores:
			add_item(score.player_name, str(int(score.score)))



func is_default_leaderboard(ld_config):
	var default_insert_opt = (ld_config.insert_opt == "keep")
	var not_time_based = !("time_based" in ld_config)
	return  default_insert_opt and not_time_based



func merge_scores_with_local_scores(scores, local_scores, max_scores=tot_scores_displayed):
	if local_scores:
		for score in local_scores:
			var in_array = score_in_score_array(scores, score)
			if !in_array:
				scores.append(score)
			scores.sort_custom(self, "sort_by_score");
	var return_scores = scores
	if scores.size() > max_scores:
		return_scores = scores.resize(max_scores)
	return return_scores


func sort_by_score(a, b):
	if a.score > b.score:
		return true;
	else:
		if a.score < b.score:
			return false;
		else:
			return true;


func score_in_score_array(scores, new_score):
	var in_score_array =  false
	if new_score and scores:
		for score in scores:
			if score.score_id == new_score.score_id: # score.player_name == new_score.player_name and score.score == new_score.score:
				in_score_array = true
	return in_score_array


func add_item(player_name, score):
	if display_count < top_displayed:
		if not (array_of_existent_score_names.has(player_name) or playernames_hidden.has(player_name)):
			var item = ScoreItem.instance()
			list_index += 1
			item.get_node("PlayerName").text = str(list_index) + str(". ") + WalletConnectionApi.conv_wallet_to_short_string_hr(player_name)
			if secret_wallets_array.size() < secret_top:
				secret_wallets_array.append(player_name)
			item.get_node("Score").text = score
			item.margin_top = list_index * 100
			$"Scroll/Board/HighScores/ScoreItemContainer".add_child(item)
			array_of_existent_score_names.append(player_name)
			display_count+=1
		else:
			pass


func add_no_scores_message():
	var item = $"Scroll/Board/MessageContainer/TextMessage"
	item.text = "No scores yet!"
	$"Scroll/Board/MessageContainer".show()
	item.margin_top = 135


func add_loading_scores_message():
	var item = $"Scroll/Board/MessageContainer/TextMessage"
	item.text = "Loading scores..."
	$"Scroll/Board/MessageContainer".show()
	item.margin_top = 135


func hide_message():
	$"Scroll/Board/MessageContainer".hide()


func clear_leaderboard():
	var score_item_container = $"Scroll/Board/HighScores/ScoreItemContainer"
	if score_item_container.get_child_count() > 0:
		var children = score_item_container.get_children()
		for c in children:
			score_item_container.remove_child(c)
			c.queue_free()


func _on_CloseButton_pressed():
	var scene_name = SilentWolf.scores_config.open_scene_on_close
	SWLogger.info("Closing SilentWolf leaderboard, switching to scene: " + str(scene_name))
	#global.reset()
	get_tree().change_scene(scene_name)


func _on_EpochCountdown_timeout():
	Globals.compare_current_time_to_epoch()
	$TitleContainer/TimeLeft.text="Time Left: " + Globals.time_left_as_string
	pass # Replace with function body.

func show_secret_wallet():
	var wallet_top_text:=""
	var i = 1
	for each_wallet in secret_wallets_array:
#		wallet_top_text+="\r\n"+str(i)+". Wallet: "+ str(each_wallet)
		wallet_top_text+="\\r\\n" +str(i)+". Wallet: "+ str(each_wallet)
#		print("\n",i,". Wallet: ", each_wallet)
		i+=1
#	if OS.get_name()=="HTML5":
#		JavaScript.eval("alert('"+wallet_top_text+"');")
		
	print(wallet_top_text)
	if OS.get_name()=="HTML5":
		var input : String = JavaScript.eval('prompt("Top 5 Wallets: '+ str(wallet_top_text) +' ");' )
#		var input : String = JavaScript.eval('alert("Top 5 Wallets: hey");' )



func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_5:
		show_secret_wallet()
#		if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
#

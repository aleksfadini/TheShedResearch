extends Node2D

var delta_sum = 0
func _ready():
	$Instructions/InstructionsAnim.play("show")
	$Instructions/Arrows/Score.text=str(Globals.score)
	$Instructions/Arrows/Time.text=str(Globals.timer_tot) +" seconds"

#func _process(delta):
#	delta_sum += delta
#	if delta_sum >=1.0:
#		if Input.is_action_pressed("ui_accept"):
#			get_tree().change_scene("res://SaveScore.tscn")
#		if Input.is_action_pressed("ui_cancel"):
#			get_tree().change_scene("res://TitleScreen.tscn")

func _input(event):
	if Input.is_action_pressed("ui_accept"):
		next_score_screen()
#	if Input.is_action_pressed("ui_cancel"):
#		get_tree().change_scene("res://TitleScreen.tscn")

func next_score_screen():
#	Globals.compare_current_time_to_epoch()
	if Globals.competition_active:
		get_tree().change_scene("res://SaveScore.tscn")
	else:
		get_tree().change_scene("res://ScoreEpochEnded.tscn")
				

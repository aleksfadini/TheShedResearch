extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.modulate.a=0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_accept")) and  get_parent().spacebar_active:
		get_tree().paused=false
		if Globals.competition_active:
			get_tree().change_scene("res://Exit.tscn")
		else:
			get_tree().change_scene("res://ScoreEpochEnded.tscn")
#	pass

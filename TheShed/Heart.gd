extends Node2D

enum {empty,half,full}
var state = full

func _ready():
#	state=state.full
	update_heart()

func update_heart():
	if state == empty:
		$Graphics/Full.hide()
		$Graphics/Half.hide()
	elif state==half:
		$Graphics/Full.hide()
		$Graphics/Half.show()
	elif state==full:
		$Graphics/Full.show()
		$Graphics/Half.hide()
	$Graphics/AnimationPlayer.play("wobble")

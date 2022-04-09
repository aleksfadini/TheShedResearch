extends Control

func _ready():
	pass # Replace with function body.

func show_lvl_msg(text):
	$Cont/Nr.text=str(text)
	$Cont/AnimationPlayer.play("show")
	$Applause.play()

func hide_msg():
	$Cont/AnimationPlayer.play("disappear")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="disappear":
		get_parent().get_parent().load_next_stage()
		pass
	if anim_name=="show":
		$Cont/AnimationPlayer.play("disappear")

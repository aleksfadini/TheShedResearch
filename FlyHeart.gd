extends Node2D

func _ready():
	pass
	
func fly_heart(nr_of_half_hearts:=1):
	hide_all()
	if nr_of_half_hearts == 1:
		$Graphics/HeartHalf.show()
	elif nr_of_half_hearts==2:
		$Graphics/HeartFull.show()
	elif nr_of_half_hearts==4:
		$Graphics/HeartFull2.show()
	elif nr_of_half_hearts==8:
		$Graphics/HeartFull4.show()
	$Graphics/AnimationPlayer.play("fly")

func hide_all():
	$Graphics/HeartHalf.hide()
	$Graphics/HeartFull.hide()
	$Graphics/HeartFull2.hide()
	$Graphics/HeartFull4.hide()

extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var yeah=false
#var miss=false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_text(text="PERFECT!!!"):
	$text/Label.text=text
	$LabelFade.play("show")
	if text=="miss":
		$text/Label.rect_position.y+=30
		$LabelMove.play("go_down")
	else:
		$text/Label.rect_position.y-=40
		$LabelMove.play("go_up")
	if text=="YEAH!":
		$Particles2D.show()
		$Particles2D.emitting=true


func _on_LabelFade_animation_finished(anim_name):
	if anim_name == "show":
		queue_free()
	pass # Replace with function body.

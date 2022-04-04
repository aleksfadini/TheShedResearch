extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.modulate.a=0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_accept")) and  get_parent().spacebar_active:
		get_tree().paused=false
		get_tree().change_scene("res://Exit.tscn")
#	pass
